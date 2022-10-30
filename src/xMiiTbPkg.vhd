--
--  File Name:         xMiiTbPkg.vhd
--  Design Unit Name:  xMiiTbPkg
--  OSVVM Release:     OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Defines types, constants, and subprograms used by
--      OSVVM Axi4 Transaction Based Models (aka: TBM, TLM, VVC)
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

  use std.textio.all ;

library OSVVM ; 
  context OSVVM.OsvvmContext ;  

library osvvm_common ;
  context osvvm_common.OsvvmCommonContext ;
  
package xMiiTbPkg is 

  subtype EthernetRecType is StreamRecType(
      DataToModel   (7 downto 0),
      DataFromModel (7 downto 0),
      ParamToModel  (0 downto 1),
      ParamFromModel(0 downto 1)
    ) ;  

  type xMiiPhyOrMacType is (PHY, MAC) ; 
  type xMiiInterfaceType is (MII, RMII, GMII, RGMII) ; 
  type xMiiBpsType is (BPS_10M, BPS_100M, BPS_1G) ; 

  constant CLK_1G_PERIOD        : time := 1 Sec / 125E6 ;
  constant CLK_100M_MII_PERIOD  : time := 1 Sec / 25E6 ;
  constant CLK_100M_RMII_PERIOD : time := 1 Sec / 50E6 ;
  constant CLK_10M_MII_PERIOD   : time := 1 Sec / 25E5 ;
  constant CLK_10M_RMII_PERIOD  : time := 1 Sec / 5E6 ;
  
  constant MaxPacketLength : integer := 1600 ;

  ------------------------------------------------------------
  function CalcPeriod (
    Bps           : xMiiBpsType ;
    xMiiInterface : xMiiInterfaceType
  ) return time ; 

  ------------------------------------------------------------
  procedure SendByte (
  ------------------------------------------------------------
    signal   Clk           : in  std_logic ; 
    constant iData         : in  std_logic_vector(0 to 7);  
    constant iEnDv         : in  std_logic ; 
    constant iEr           : in  std_logic ;
    constant Tpd           : in  time ; 
    constant xMiiInterface : in  xMiiInterfaceType ;
    signal   oData         : out std_logic_vector(0 to 7);  
    signal   oEnDv         : out std_logic ; 
    signal   oEr           : out std_logic ;
    signal   oCtl          : out std_logic  
  ) ; 

  ------------------------------------------------------------
  procedure GetByte (
  ------------------------------------------------------------
    signal   Clk           : in  std_logic ; 
    variable oData         : out std_logic_vector(0 to 7);  
    variable oEnDv         : out std_logic ; 
    variable oEr           : out std_logic ;
    constant Tpd           : in  time ; 
    constant xMiiInterface : in  xMiiInterfaceType ;
    signal   iData         : in  std_logic_vector(0 to 7);  
    signal   iEnDv         : in  std_logic ; 
    signal   iEr           : in  std_logic ;
    signal   iCtl          : in  std_logic  
  ) ;
end package xMiiTbPkg ;

package body xMiiTbPkg is 

  ------------------------------------------------------------
  function CalcPeriod (
  ------------------------------------------------------------
    Bps           : xMiiBpsType ;
    xMiiInterface : xMiiInterfaceType
  ) return time is 
  begin
    if Bps = BPS_1G then             -- 1 Gb/s
      return CLK_1G_PERIOD ; 
    elsif Bps = BPS_100M then        -- 100 Mb/s
      if xMiiInterface /= RMII then
        return CLK_100M_MII_PERIOD ;
      else
        return CLK_100M_RMII_PERIOD ;
      end if ; 
    else                             -- 10 Mb/s
      if xMiiInterface /= RMII then  
        return CLK_10M_MII_PERIOD ;
      else
        return CLK_10M_RMII_PERIOD ;
      end if ; 
    end if ;  
  end function CalcPeriod ; 


  ------------------------------------------------------------
  procedure SendByte (
  ------------------------------------------------------------
    signal   Clk           : in  std_logic ; 
    constant iData         : in  std_logic_vector(0 to 7);  
    constant iEnDv         : in  std_logic ; 
    constant iEr           : in  std_logic ;
    constant Tpd           : in  time ; 
    constant xMiiInterface : in  xMiiInterfaceType ;
    signal   oData         : out std_logic_vector(0 to 7);  
    signal   oEnDv         : out std_logic ; 
    signal   oEr           : out std_logic ;
    signal   oCtl          : out std_logic  
  ) is
    variable Error : std_logic ; 
  begin
    Error := '1' when is_x(iData) else iEr ; 
    
    case xMiiInterface is
      when GMII =>
        -- Data is Source Synchronous - no delays on data
        oData   <= iData ;
        oEnDv   <= iEnDv ; 
        oEr     <= Error ; 
        oCtl    <= iEnDv ; -- 'X' ; 
        wait until Rising_Edge(Clk) ; 
      
      when RGMII =>
        -- Data is Source Synchronous - no delays on data
        oData   <= iData(0 to 3) & "XXXX" ; 
        oEnDv   <= iEnDv ; -- 'X' ; 
        oEr     <= Error ; -- 'X' ; 
        oCtl    <= iEnDv ; 
        wait until Falling_Edge(Clk) ;
        
        oData   <= iData(4 to 7) & "XXXX" ; 
        oCtl    <= Error ; 
        wait until Rising_Edge(Clk) ;
        
      when MII =>
        -- Common Clock, data has a propagation delay
        oData   <= iData(0 to 3) & "XXXX" after Tpd ; 
        oEnDv   <= iEnDv   after Tpd ; 
        oEr     <= Error   after Tpd ; 
        oCtl    <= iEnDv   after Tpd ;  -- 'X'     after Tpd ; 
        wait until Rising_Edge(Clk) ; 
        
        oData   <= iData(4 to 7) & "XXXX" after Tpd ; 
        wait until Rising_Edge(Clk) ; 
      
      when RMII =>
        oData   <= iData(0 to 1) & "XXXXXX" after Tpd ; 
        oEnDv   <= iEnDv after Tpd ; 
        oEr     <= Error after Tpd ; 
        oCtl    <= iEnDv after Tpd ; -- 'X' ; 
        wait until Rising_Edge(Clk) ; 
        oData   <= iData(2 to 3) & "XXXXXX" after Tpd ; 
        wait until Rising_Edge(Clk) ; 
        oData   <= iData(4 to 5) & "XXXXXX" after Tpd ; 
        wait until Rising_Edge(Clk) ; 
        oData   <= iData(6 to 7) & "XXXXXX" after Tpd ; 
        wait until Rising_Edge(Clk) ; 
    end case ; 
  end procedure SendByte ; 

  ------------------------------------------------------------
  procedure GetByte (
  ------------------------------------------------------------
    signal   Clk           : in  std_logic ; 
    variable oData         : out std_logic_vector(0 to 7);  
    variable oEnDv         : out std_logic ; 
    variable oEr           : out std_logic ;
    constant Tpd           : in  time ; 
    constant xMiiInterface : in  xMiiInterfaceType ;
    signal   iData         : in  std_logic_vector(0 to 7);  
    signal   iEnDv         : in  std_logic ; 
    signal   iEr           : in  std_logic ;
    signal   iCtl          : in  std_logic  
  ) is
  begin
    case xMiiInterface is
      when GMII =>
        -- Data is Source Synchronous - no delays on data
        oData := iData  ;           
        oEnDv := iEnDv ; 
        oEr   := iEr ; 
        wait until Rising_Edge(Clk) ; 
      
      when RGMII =>
        oData(0 to 3) := iData(0 to 3) ; 
        oEnDv := iCtl ; 
        wait until Falling_Edge(Clk) ;
        
        oData(4 to 7) := iData(0 to 3) ; 
        oEr   := iCtl ; 
        wait until Rising_Edge(Clk) ;
        
      when MII =>
        oData(0 to 3) := iData(0 to 3) ; 
        oEnDv := iEnDv ; 
        oEr   := iEr ; 
        wait until Rising_Edge(Clk) ; 
        
        oData(4 to 7) := iData(0 to 3) ; 
        wait until Rising_Edge(Clk) ; 
      
      when RMII =>
        oData(0 to 1)  := iData(0 to 1) ; 
        oEnDv          := iEnDv ; 
        oEr            := iEr ; 
        wait until Rising_Edge(Clk) ; 
        oData(2 to 3)  := iData(0 to 1) ; 
        wait until Rising_Edge(Clk) ; 
        oData(4 to 5)  := iData(0 to 1) ; 
        wait until Rising_Edge(Clk) ; 
        oData(6 to 7)  := iData(0 to 1) ; 
        wait until Rising_Edge(Clk) ; 
    end case ; 
  end procedure GetByte ; 

end package body xMiiTbPkg ;
