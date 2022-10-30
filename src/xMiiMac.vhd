--
--  File Name:         xMiiMac.vhd
--  Design Unit Name:  xMiiMac
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

library osvvm_common ;
  context osvvm_common.OsvvmCommonContext ;

  use work.xMiiComponentPkg.all ;
  use work.xMiiTbPkg.all ;

entity xMiiMac is
  generic (
    MODEL_ID_NAME  : string := "" ;
    MII_INTERFACE  : xMiiInterfaceType := GMII ;
    MII_BPS        : xMiiBpsType       := BPS_1G ;
    DEFAULT_DELAY  : time := 1 ns ;
    tpd            : time := DEFAULT_DELAY 
  ) ;
  port (
    -- xMii Transmitter Functional Interface
    Gtx_Clk   : out std_logic ;  -- out for GMII/RGMII, in for MII
    Tx_Clk    : in  std_logic ;  -- out for GMII/RGMII, in for MII
    TxD       : out std_logic_vector(0 to 7) ; 
    Tx_En     : out std_logic ; 
    Tx_Er     : out std_logic ; 
    Tx_Ctl    : out std_logic ; 
    
    -- xMii Receiver Interface
    Rx_Clk    : in std_logic ; 
    RxD       : in std_logic_vector(0 to 7) ; 
    Rx_Dv     : in std_logic ; 
    Rx_Er     : in std_logic ; 
    Rx_Ctl    : in std_logic ; 
    Crs       : in std_logic ; 
    Col       : in std_logic ; 
    
    -- Testbench Transaction Interface
    MacTxRec     : inout StreamRecType ;  -- Information outbound of this VC
    MacRxRec     : inout StreamRecType    -- Information inbound to this VC
  ) ;

  -- Use MODEL_ID_NAME Generic if set, otherwise,
  -- use model instance label (preferred if set as entityname_1)
  constant MODEL_INSTANCE_NAME : string :=
    IfElse(MODEL_ID_NAME'length > 0, MODEL_ID_NAME, 
      to_lower(PathTail(xMiiMac'PATH_NAME))) ;

end entity xMiiMac ;
architecture behavioral of xMiiMac is

  -- MDIO settings
  signal xMiiInterface : xMiiInterfaceType := MII_INTERFACE ;
  signal xMiiBps       : xMiiBpsType       := MII_BPS ;

begin


--!! TODO - Add MDIO interface to drive 
--!!      xMiiInterface : in xMiiInterfaceType := GMII ;
--!!      xMiiBps       : in xMiiBpsType       := BPS_1G ;



  xMiiMacReceiver_1 : xMiiMacReceiver 
    generic map (
      MODEL_ID_NAME  => MODEL_INSTANCE_NAME & ".Rx",
      DEFAULT_DELAY  => DEFAULT_DELAY
    ) 
    port map (
      -- Configured by MDIO - it can change during operation based on PHY negotiation
      xMiiInterface => xMiiInterface,
      xMiiBps       => xMiiBps      ,
      
      -- xMiiPhyRxTransmitter Receiver Interface
      Rx_Clk        => Rx_Clk       ,
      RxD           => RxD          ,
      Rx_Dv         => Rx_Dv        ,
      Rx_Er         => Rx_Er        ,
      Rx_Ctl        => Rx_Ctl       ,
      Crs           => Crs          ,
      Col           => Col          ,
      
      -- Testbench Transaction Interface
      TransRec      => MacRxRec
    ) ;

  xMiiMacTransmitter_1 : xMiiMacTransmitter 
    generic map (
      MODEL_ID_NAME  => MODEL_INSTANCE_NAME & ".Tx",
      DEFAULT_DELAY  => DEFAULT_DELAY
    ) 
    port map (
      -- Configured by MDIO - it can change during operation based on PHY negotiation
      xMiiInterface => xMiiInterface,
      xMiiBps       => xMiiBps      ,
      
      -- xMiiPhyTxReceiver Transmitter Functional Interface
      GTx_Clk       => GTx_Clk      ,
      Tx_Clk        => Tx_Clk       ,
      TxD           => TxD          ,
      Tx_En         => Tx_En        ,
      Tx_Er         => Tx_Er        ,
      Tx_Ctl        => Tx_Ctl       ,
      
      -- Testbench Transaction Interface
      TransRec      => MacTxRec
    ) ;
end architecture behavioral ;
