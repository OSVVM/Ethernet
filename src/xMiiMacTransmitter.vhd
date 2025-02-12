--
--  File Name:         xMiiMacTransmitter.vhd
--  Design Unit Name:  xMiiMacTransmitter
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Ethernet GMII/RGMII/MII/RMII VC
--      First target is to support PHY
--      Later on need basis consider supporting MAC
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    10/2022   2022.10    Initial Release
--
--
--  This file is part of OSVVM.
--
--  Copyright (c) 2022 by SynthWorks Design Inc.
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      https://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
--

library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.numeric_std.all ;
  use ieee.numeric_std_unsigned.all ;
  use ieee.math_real.all ;

library osvvm ;
  context osvvm.OsvvmContext ;
  use osvvm.ScoreboardPkg_slv.all ;
  use osvvm.ScoreboardPkg_int.all ;

library osvvm_common ;
  context osvvm_common.OsvvmCommonContext ;

  use work.xMiiTbPkg.all ;

entity xMiiMacTransmitter is
  generic (
    MODEL_ID_NAME  : string := "" ;
    DEFAULT_DELAY  : time := 1 ns ;
    tpd            : time := DEFAULT_DELAY 
  ) ;
  port (
    -- Configured by MDIO - it can change during operation based on PHY negotiation
    xMiiInterface : in xMiiInterfaceType := GMII ;
    xMiiBps       : in xMiiBpsType       := BPS_1G ;
    
    -- xMiiMacReceiver Transmitter Functional Interface
    Gtx_Clk   : out std_logic ;  -- out for GMII/RGMII, in for MII
    Tx_Clk    : in  std_logic ;  -- out for GMII/RGMII, in for MII
    TxD       : out std_logic_vector(0 to 7) ; 
    Tx_En     : out std_logic ; 
    Tx_Er     : out std_logic ; 
    Tx_Ctl    : out std_logic ; 
    
    -- Testbench Transaction Interface
    TransRec   : inout StreamRecType   -- Information outbound of this VC
  ) ;

  -- Use MODEL_ID_NAME Generic if set, otherwise,
  -- use model instance label (preferred if set as entityname_1)
  constant MODEL_INSTANCE_NAME : string :=
    IfElse(MODEL_ID_NAME'length > 0, MODEL_ID_NAME, 
      to_lower(PathTail(xMiiMacTransmitter'PATH_NAME))) ;

end entity xMiiMacTransmitter ;
architecture behavioral of xMiiMacTransmitter is

  signal tperiod_xClk : time := CalcPeriod(BPS_1G, GMII) ; 
  signal RefGtxClk    : std_logic := '0' ; 
  signal iTxClk       : std_logic := '0' ; 
    
  signal ModelID      : AlertLogIDType ;

  signal DataFifo     : osvvm.ScoreboardPkg_slv.ScoreboardIDType ;
  signal MetaFifo     : osvvm.ScoreboardPkg_int.ScoreboardIDType ;

  signal TransmitRequestCount, TransmitDoneCount      : integer := 0 ;

--!! TODO - NumGapLength should be a function of frequency
  signal NumGapLength : integer := 7 ;

begin

  ------------------------------------------------------------
  --  Initialize alerts
  ------------------------------------------------------------
  Initialize : process
    variable ID : AlertLogIDType ;
  begin
    -- Alerts
    ID           := NewID(MODEL_INSTANCE_NAME) ;
    ModelID      <= ID ;
    DataFifo     <= NewID("DataFifo",  ID, ReportMode => DISABLED, Search => PRIVATE_NAME) ; 
    MetaFifo     <= NewID("MetaFifo",  ID, ReportMode => DISABLED, Search => PRIVATE_NAME) ; 
    wait ;
  end process Initialize ;

  ------------------------------------------------------------
  ClkProc : process
  ------------------------------------------------------------
  begin
    wait for 0 ns ;  -- calc init value on tperiod_xClk
    loop 
      RefGtxClk <= not RefGtxClk after tperiod_xClk ; 
      wait on RefGtxClk ; 
    end loop ; 
  end process ; 

  tperiod_xClk <= CalcPeriod(xMiiBps, xMiiInterface) ; 
  
  -- Internal timing reference - caution:  shifted by delta cycle
  iTxClk <= RefGtxClk when xMiiInterface = GMII or xMiiInterface = RGMII 
            else Tx_Clk when xMiiInterface = MII else
--!!TODO resolve source of RMII Clk
            Tx_Clk ; -- Source of RMII
  
  -- source synchronous clock delay.  Typically done by board traces.
  Gtx_Clk <= RefGtxClk after tpd ; 


  ------------------------------------------------------------
  TransactionDispatcher : process
  ------------------------------------------------------------
    variable NumberTransfers : integer ;
  begin
    wait for 0 ns ;  -- Wait for ModelId
    TransRec.BurstFifo <= NewID("BurstFifo", ModelId, ReportMode => DISABLED, Search => PRIVATE_NAME) ;
    
    DispatchLoop : loop 
      WaitForTransaction(
         Clk      => iTxClk,
         Rdy      => TransRec.Rdy,
         Ack      => TransRec.Ack
      ) ;

      case TransRec.Operation is
        when WAIT_FOR_CLOCK =>
          WaitForClock(iTxClk, TransRec.IntToModel) ;

        when WAIT_FOR_TRANSACTION =>
          if TransmitRequestCount /= TransmitDoneCount then
            wait until TransmitRequestCount = TransmitDoneCount ;
          end if ;

        when GET_TRANSACTION_COUNT =>
          TransRec.IntFromModel <= TransmitDoneCount ;
          wait for 0 ns ;

        when GET_ALERTLOG_ID =>
          TransRec.IntFromModel <= integer(ModelId) ;
          wait for 0 ns ;

        when SEND_BURST | SEND_BURST_ASYNC =>
          NumberTransfers := TransRec.IntToModel ;
          Push(MetaFifo, NumberTransfers) ;
          Increment(TransmitRequestCount) ; 
-- Any reason not to just use the BurstFifo directly?
-- Limits BurstFifo editing capability when ASYNC and 
          for i in 1 to NumberTransfers loop
            Push(DataFifo, Pop(TransRec.BurstFifo)) ;
          end loop ; 
          
          wait for 0 ns ;
          if IsBlocking(TransRec.Operation) then
            wait until TransmitRequestCount = TransmitDoneCount ;
          end if ;
          Log(ModelId,
            "Sent Packet# " & to_string (TransmitRequestCount),
            INFO, TransRec.BoolToModel or IsLogEnabled(ModelId, PASSED)
          ) ;

        when SET_MODEL_OPTIONS | GET_MODEL_OPTIONS =>
          Alert(ModelId, "Configuration done via MDIO Interface." & 
                         "  Transaction # " & to_string(TransRec.Rdy), FAILURE) ;

        when MULTIPLE_DRIVER_DETECT =>
          Alert(ModelId, "Multiple Drivers on Transaction Record." & 
                         "  Transaction # " & to_string(TransRec.Rdy), FAILURE) ;

        -- The End -- Done
        when others =>
          Alert(ModelId, "Unimplemented Transaction: " & to_string(TransRec.Operation), FAILURE) ;
      end case ;

      -- Wait for 1 delta cycle, required if a wait is not in all case branches above
      wait for 0 ns ;
    end loop DispatchLoop ;
  end process TransactionDispatcher ;



  ------------------------------------------------------------
  MacTxHandler : process
  --  MAC sends data on Transmitter Interface
  ------------------------------------------------------------
    variable PreambleLength : integer := 7 ; -- requirement to send 7
    variable PacketLength   : integer ;
    
    ------------------------------------------------------------
    procedure SendByte (
      iData : std_logic_vector(0 to 7);  
      iEn   : std_logic := '1'; 
      iEr   : std_logic := '0' 
    ) is
    ------------------------------------------------------------
    begin
      SendByte(
        Clk           => iTxClk,
        iData         => iData, 
        iEnDv         => iEn,
        iEr           => iEr,
        Tpd           => tpd, 
        xMiiInterface => xMiiInterface,
        oData         => TxD,
        oEnDv         => Tx_En,
        oEr           => Tx_Er,
        oCtl          => Tx_Ctl
      ) ; 
    end procedure SendByte ; 

  begin
  
    TxD       <= (others => '0') ;
    Tx_En     <= '0' ;
    Tx_Er     <= '0' ;
    Tx_Ctl    <= '0' ;

    wait for 0 ns ; -- Allow DataFifo and MetaFifo to initialize 

    SendLoop : loop
      if IsEmpty(MetaFifo) then
         WaitForToggle(TransmitRequestCount) ;
      end if ;
      FindRisingEdge(iTxClk) ;
      PacketLength := Pop(MetaFifo) ; 

      -- Send Preamble Bytes 
      for i in 1 to PreambleLength loop
        SendByte(X"AA") ; 
      end loop ;

      -- Send SFD
      SendByte(X"AB") ; 

      for i in 1 to PacketLength loop  
        SendByte(Pop(DataFifo)) ; 
      end loop ; 

      -- Send Inter-frame gap
      for i in 1 to NumGapLength loop 
        SendByte(X"0F", '0', '0') ; 
      end loop ;

      -- Signal completion
      Increment(TransmitDoneCount) ;
      wait for 0 ns ;
    end loop SendLoop ;
  end process MacTxHandler ;
    
end architecture behavioral ;
