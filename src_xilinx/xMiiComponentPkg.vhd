--
--  File Name:         xMiiComponentPkg.vhd
--  Design Unit Name:  xMiiComponentPkg
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Package with component declarations for AxiStreamTransmitter and AxiStreamReceiver
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

library osvvm ;
  context osvvm.OsvvmContext ;
  use osvvm.ScoreboardPkg_slv.all ;
  
library osvvm_common ;
  context osvvm_common.OsvvmCommonContext ;

  use work.xMiiTbPkg.all ;
    
package xMiiComponentPkg is

  component xMiiPhyRxTransmitter is
    generic (
      MODEL_ID_NAME  : string := "" ;
      DEFAULT_DELAY  : time := 1 ns ;
      tpd            : time := DEFAULT_DELAY 
    ) ;
    port (
      -- Configured by MDIO - it can change during operation based on PHY negotiation
      xMiiInterface : in xMiiInterfaceType := GMII ;
      xMiiBps       : in xMiiBpsType       := BPS_1G ;
      
      -- xMiiPhyRxTransmitter Receiver Interface
      Rx_Clk    : out std_logic ; 
      RxD       : out std_logic_vector(0 to 7) ; 
      Rx_Dv     : out std_logic ; 
      Rx_Er     : out std_logic ; 
      Rx_Ctl    : out std_logic ; 
      Crs       : out std_logic ; 
      Col       : out std_logic ; 
      
      -- Testbench Transaction Interface
      TransRec   : inout StreamRecType   -- Information outbound of this VC
    ) ;
  end component xMiiPhyRxTransmitter ;

  component xMiiPhyTxReceiver is
    generic (
      MODEL_ID_NAME  : string := "" ;
      DEFAULT_DELAY  : time := 1 ns ;
      tpd            : time := DEFAULT_DELAY 
    ) ;
    port (
      -- Configured by MDIO - it can change during operation based on PHY negotiation
      xMiiInterface : in xMiiInterfaceType := GMII ;
      xMiiBps       : in xMiiBpsType       := BPS_1G ;
      
      -- xMiiPhyTxReceiver Transmitter Functional Interface
      GTx_Clk   : in  std_logic ;  -- GMII, RGMII
      Tx_Clk    : out std_logic ;  -- MII
      TxD       : in  std_logic_vector(0 to 7) ; 
      Tx_En     : in  std_logic ; 
      Tx_Er     : in  std_logic ; 
      Tx_Ctl    : in  std_logic ; 
      
      -- Testbench Transaction Interface
      TransRec  : inout StreamRecType    -- Information inbound to this VC
    ) ;
  end component xMiiPhyTxReceiver ;
  
  component xMiiMacReceiver is
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
      Rx_Clk    : in std_logic ; 
      RxD       : in std_logic_vector(0 to 7) ; 
      Rx_Dv     : in std_logic ; 
      Rx_Er     : in std_logic ; 
      Rx_Ctl    : in std_logic ; 
      Crs       : in std_logic ; 
      Col       : in std_logic ; 

      -- Testbench Transaction Interface
      TransRec  : inout StreamRecType    -- Information inbound to this VC
    ) ;
  end component xMiiMacReceiver ;

  component xMiiMacTransmitter is
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
  end component xMiiMacTransmitter ;

  component xMiiPhy is
    generic (
      MODEL_ID_NAME  : string := "" ;
      MII_INTERFACE  : xMiiInterfaceType := GMII ;
      MII_BPS        : xMiiBpsType       := BPS_1G ;
      DEFAULT_DELAY  : time := 1 ns ;
      tpd            : time := DEFAULT_DELAY 
    ) ;
    port (
      -- xMii Transmitter Functional Interface
      GTx_Clk   : in  std_logic ;  -- GMII, RGMII
      Tx_Clk    : out std_logic ;  -- MII
      TxD       : in  std_logic_vector(0 to 7) ; 
      Tx_En     : in  std_logic ; 
      Tx_Er     : in  std_logic ; 
      Tx_Ctl    : in  std_logic ; 
      
      -- xMii Receiver Interface
      Rx_Clk    : out std_logic ; 
      RxD       : out std_logic_vector(0 to 7) ; 
      Rx_Dv     : out std_logic ; 
      Rx_Er     : out std_logic ; 
      Rx_Ctl    : out std_logic ; 
      Crs       : out std_logic ; 
      Col       : out std_logic ; 
      
      -- Testbench Transaction Interface
      PhyTxRec     : inout StreamRecType ;  -- Information inbound to this VC
      PhyRxRec     : inout StreamRecType    -- Information outbound of this VC
    ) ;
  end component xMiiPhy ;

  component xMiiMac is
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
  end component xMiiMac ;

end package xMiiComponentPkg ;