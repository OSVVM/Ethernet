--
--  File Name:         TbStandAlone.vhd
--  Design Unit Name:  TbStandAlone
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Top level testbench for AxiStreamTransmitter and AxiStreamReceiver
--
--
--  Developed by:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date      Version    Description
--    10/2011   2022.10    Initial revision
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

library osvvm ;
    context osvvm.OsvvmContext ;
    
library osvvm_ethernet ;
    context osvvm_ethernet.xMiiContext ;
    
entity TbStandAlone is
  generic (
    MII_INTERFACE : xMiiInterfaceType := GMII ;
    MII_BPS       : xMiiBpsType       := BPS_1G 
  ) ;
end entity TbStandAlone ; 
architecture TestHarness of TbStandAlone is

  constant tpd : time := 1 ns ; 

  component TestCtrl is
    port (
      -- Transaction Interfaces
      MacTxRec     : inout StreamRecType ;  -- Output from MAC
      MacRxRec     : inout StreamRecType ;  -- Input to MAC

      PhyTxRec     : inout StreamRecType ;  -- Input to Phy
      PhyRxRec     : inout StreamRecType    -- Output from Phy
    ) ;
  end component TestCtrl ;

  -- xMii Transmitter Functional Interface
  signal GTx_Clk   : std_logic ;  -- GMII, RGMII
  signal Tx_Clk    : std_logic ;  -- MII
  signal TxD       : std_logic_vector(0 to 7) ; 
  signal Tx_En     : std_logic ; 
  signal Tx_Er     : std_logic ; 
  signal Tx_Ctl    : std_logic ; 
  
  -- xMii Receiver Interface
  signal Rx_Clk    : std_logic ; 
  signal RxD       : std_logic_vector(0 to 7) ; 
  signal Rx_Dv     : std_logic ; 
  signal Rx_Er     : std_logic ; 
  signal Rx_Ctl    : std_logic ; 
  signal Crs       : std_logic ; 
  signal Col       : std_logic ; 
  
  -- Testbench Transaction Interface
  signal PhyTxRec     : EthernetRecType ;  -- input to Phy
  signal PhyRxRec     : EthernetRecType ;  -- output from Phy
  signal MacRxRec     : EthernetRecType ;  -- input to MAC
  signal MacTxRec     : EthernetRecType ;  -- output from MAC

begin

  process 
  begin
    log("Generic settings.  MII_INTERFACE = " & to_string(MII_INTERFACE) & ".   MII_BPS = " & to_string(MII_BPS)) ; 
    wait ; 
  end process ; 
 
  xMiiPhy_1 : xMiiPhy 
    generic map (
      MII_INTERFACE  => MII_INTERFACE,
      MII_BPS        => MII_BPS, 
      DEFAULT_DELAY  => tpd
    ) 
    port map (
      -- xMii Transmitter Functional Interface
      GTx_Clk       => GTx_Clk      ,
      Tx_Clk        => Tx_Clk       ,
      TxD           => TxD          ,
      Tx_En         => Tx_En        ,
      Tx_Er         => Tx_Er        ,
      Tx_Ctl        => Tx_Ctl       ,
      
      -- xMii Receiver Interface
      Rx_Clk        => Rx_Clk       ,
      RxD           => RxD          ,
      Rx_Dv         => Rx_Dv        ,
      Rx_Er         => Rx_Er        ,
      Rx_Ctl        => Rx_Ctl       ,
      Crs           => Crs          ,
      Col           => Col          ,
      
      -- Testbench Transaction Interface
      PhyTxRec     => PhyTxRec    ,
      PhyRxRec     => PhyRxRec
    ) ;

  xMiiMac_1 : xMiiMac 
    generic map (
      MII_INTERFACE  => MII_INTERFACE,
      MII_BPS        => MII_BPS, 
      DEFAULT_DELAY  => tpd
    ) 
    port map (
      -- xMii Transmitter Functional Interface
      GTx_Clk       => GTx_Clk      ,
      Tx_Clk        => Tx_Clk       ,
      TxD           => TxD          ,
      Tx_En         => Tx_En        ,
      Tx_Er         => Tx_Er        ,
      Tx_Ctl        => Tx_Ctl       ,
      
      -- xMii Receiver Interface
      Rx_Clk        => Rx_Clk       ,
      RxD           => RxD          ,
      Rx_Dv         => Rx_Dv        ,
      Rx_Er         => Rx_Er        ,
      Rx_Ctl        => Rx_Ctl       ,
      Crs           => Crs          ,
      Col           => Col          ,
      
      -- Testbench Transaction Interface
      MacTxRec     => MacTxRec    ,
      MacRxRec     => MacRxRec
    ) ;
  
  
  TestCtrl_1 : TestCtrl
  port map ( 
    -- Testbench Transaction Interfaces
      MacTxRec     => MacTxRec,
      MacRxRec     => MacRxRec,

      PhyTxRec     => PhyTxRec,
      PhyRxRec     => PhyRxRec
  ) ; 

end architecture TestHarness ;