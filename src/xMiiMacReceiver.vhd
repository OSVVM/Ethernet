--
--  File Name:         xMiiMacReceiver.vhd
--  Design Unit Name:  xMiiMacReceiver
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

entity xMiiMacReceiver is
  generic (
    MODEL_ID_NAME  : string := "" ;
    DEFAULT_DELAY  : time := 1 ns ;
    tpd            : time := DEFAULT_DELAY 
  ) ;
  port (
    -- Configured by MDIO - it can change during operation based on PHY negotiation
    xMiiInterface : in xMiiInterfaceType := GMII ;
    xMiiBps       : in xMiiBpsType       := BPS_1G ;
    
    -- xMiiMacTransmitter Receiver Interface
    Rx_Clk        : in std_logic ; 
    RxD           : in std_logic_vector(0 to 7) ; 
    Rx_Dv         : in std_logic ; 
    Rx_Er         : in std_logic ; 
    Rx_Ctl        : in std_logic ; 
    Crs           : in std_logic ; 
    Col           : in std_logic ; 

    -- Testbench Transaction Interface
    TransRec      : inout StreamRecType    -- Information inbound to this VC
  ) ;

  -- Use MODEL_ID_NAME Generic if set, otherwise,
  -- use model instance label (preferred if set as entityname_1)
  constant MODEL_INSTANCE_NAME : string :=
    IfElse(MODEL_ID_NAME'length > 0, MODEL_ID_NAME, 
      to_lower(PathTail(xMiiMacReceiver'PATH_NAME))) ;

end entity xMiiMacReceiver ;
architecture behavioral of xMiiMacReceiver is

--  signal tperiod_xClk : time := CalcPeriod(BPS_1G, GMII) ; 
  signal iRxClk   : std_logic ;   
  signal iRxD     : std_logic_vector(0 to 7) ; 
  signal iRx_Dv   : std_logic ; 
  signal iRx_Er   : std_logic ; 
  signal iRx_Ctl  : std_logic ; 
  signal iCrs     : std_logic ; 
  signal iCol     : std_logic ; 
  signal Enable       : std_logic ; 

  signal ModelID  : AlertLogIDType ;

  signal DataFifo : osvvm.ScoreboardPkg_slv.ScoreboardIDType ;
  signal MetaFifo : osvvm.ScoreboardPkg_int.ScoreboardIDType ;

  signal PacketReceiveCount      : integer := 0 ;

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


--  ------------------------------------------------------------
--  ClkProc : process
--  ------------------------------------------------------------
--  begin
--    wait for 0 ns ;  -- calc init value on tperiod_xClk
--    loop 
--      RefGtxClk <= not RefGtxClk after tperiod_xClk ; 
--      wait on RefGtxClk ; 
--    end loop ; 
--  end process ; 
--
--  tperiod_xClk <= CalcPeriod(xMiiBps, xMiiInterface) ; 

  -- Internal timing reference - caution:  shifted by delta cycle
  iRxClk <= Rx_Clk when xMiiInterface /= RMII else
--!!TODO resolve source of RMII Clk
            Rx_Clk ; -- Source of RMII
  -- Since iRxClk is delayed, all input signals must be delayed 
  -- or RTL signals may not be sampled correctly.
  iRxD     <= RxD   ; 
  iRx_Dv   <= Rx_Dv ;
  iRx_Er   <= Rx_Er ;
  iRx_Ctl  <= Rx_Ctl;
  iCrs     <= Crs   ;
  iCol     <= Col   ;


  ------------------------------------------------------------
  TransactionDispatcher : process
  ------------------------------------------------------------
    variable NumberTransfers     : integer ;
    variable PacketTransferCount : integer := 0 ;
  begin
    wait for 0 ns ; 
    TransRec.BurstFifo <= NewID("BurstFifo", ModelId, ReportMode => DISABLED, Search => PRIVATE_NAME) ;
    
    DispatchLoop : loop 
      WaitForTransaction(
         Clk      => iRxClk,
         Rdy      => TransRec.Rdy,
         Ack      => TransRec.Ack
      ) ;

      case TransRec.Operation is
        when WAIT_FOR_CLOCK =>
          WaitForClock(iRxClk, TransRec.IntToModel) ;

        when WAIT_FOR_TRANSACTION =>
--!! TODO:  Does this wait until a transaction is received?
--!!          if PacketTransferCount /= PacketReceiveCount then
--!!            wait until PacketTransferCount = PacketReceiveCount ;
--!!          end if ;

        when GET_TRANSACTION_COUNT =>
          TransRec.IntFromModel <= PacketReceiveCount ;
          wait for 0 ns ;

        when GET_ALERTLOG_ID =>
          TransRec.IntFromModel <= integer(ModelId) ;
          wait for 0 ns ;

        when GET_BURST | TRY_GET_BURST =>
          if (PacketReceiveCount - PacketTransferCount) = 0 and IsTry(TransRec.Operation) then
            -- No data for TryGetBurst, so return
            TransRec.BoolFromModel  <= FALSE ;
            wait for 0 ns ;
          else
            -- Get data
            TransRec.BoolFromModel <= TRUE ;
            if (PacketReceiveCount - PacketTransferCount) = 0 then
              -- Wait for data
              WaitForToggle(PacketReceiveCount) ;
            end if ;
            NumberTransfers := Pop(MetaFifo) ; 
            TransRec.IntFromModel <= NumberTransfers ; 
-- Do we need a separate DataFifo or 
-- is it ok to put values directly into the BurstFifo?
-- For now, could assign DataFifo to TransRec.BurstFifo 
            for i in 1 to NumberTransfers loop
              Push(TransRec.BurstFifo, Pop(DataFifo)) ;
            end loop ; 
            PacketTransferCount := Increment(PacketTransferCount) ; 
            
            Log(ModelId,
              "Received Packet# " & to_string (PacketTransferCount),
              INFO, TransRec.BoolToModel or IsLogEnabled(ModelId, PASSED)
            ) ;
            wait for 0 ns ;
          end if ;
         
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

  Enable <= xMiiEnable (
              xMiiInterface => xMiiInterface, 
              iEnDv         => iRx_Dv, 
              iCtl          => iRx_Ctl ) ;

  ------------------------------------------------------------
  MacRxHandler : process
  --  MAC receives data on receiver Interface
  ------------------------------------------------------------
    variable PacketLength : integer ; 
    variable ErrorLoc     : integer ; 
    variable oData        : std_logic_vector(0 to 7) ;
    variable oDv, oEr     : std_logic ; 
    
    procedure GetByte (
      variable oData         : out std_logic_vector(0 to 7);  
      variable oDv           : out std_logic ; 
      variable oEr           : out std_logic 
    ) is 
    begin
      GetByte (
        Clk           => iRxClk,
        oData         => oData,  
        oEnDv         => oDv,
        oEr           => oEr,
        Tpd           => Tpd,
        xMiiInterface => xMiiInterface,
        iData         => iRxD,  
        iEnDv         => iRx_Dv,
        iEr           => iRx_Er,
        iCtl          => iRx_Ctl
      ) ;
    end procedure GetByte ;

  begin
    wait for 0 ns ; -- Allow DataFifo to initialize 

    GetLoop : loop
    
      wait on iRxClk until Enable = '1' and rising_edge(iRxClk) ;

      -- Find SFD
      while oData /= X"AB" loop 
        GetByte(oData, oDv, oEr) ;
        if oDv /= '1' then
          Alert(ModelId, "Incomplete Preamble and SFD") ;
          next GetLoop ;
        end if ; 
      end loop ; 
      
      -- Get A Packet of Data
      ErrorLoc     := 0 ; 
      PacketLength := MaxPacketLength ;
      for i in 1 to MaxPacketLength loop 
        GetByte(oData, oDv, oEr) ;
        if oEr = '1' then 
          ErrorLoc := i ; 
        end if ; 
        if oDv = '1' then 
          Push(DataFifo, oData) ; 
        else
          PacketLength := i - 1 ; 
          exit ;
        end if ;
      end loop ;
      Push(MetaFifo, PacketLength) ;
      Increment(PacketReceiveCount) ;
      
      if PacketLength = MaxPacketLength then
        GetByte(oData, oDv, oEr) ;
        if oDv = '1' then 
          Alert(ModelId, "PacketLength = " & to_string(PacketLength) & 
              ".  Packet truncated due to exceeding maximum length = " & 
              to_string(MaxPacketLength)) ; 
          while oDv = '1' loop
            GetByte(oData, oDv, oEr) ;
          end loop ;
        end if ; 
      end if ; 

      wait for 0 ns ;
    end loop GetLoop ;
  end process MacRxHandler ;
end architecture behavioral ;
