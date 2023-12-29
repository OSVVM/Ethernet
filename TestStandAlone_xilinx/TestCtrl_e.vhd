--
--  File Name:         TestCtrl_e.vhd
--  Design Unit Name:  TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      Test transaction source
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
  
library OSVVM ; 
  context OSVVM.OsvvmContext ; 
  use osvvm.ScoreboardPkg_slv.all ;

library osvvm_ethernet ;
    context osvvm_ethernet.xMiiContext ;

use work.OsvvmTestCommonPkg.all ;

entity TestCtrl is
  port (
    -- Transaction Interfaces
    MacTxRec     : inout StreamRecType ;  -- Output from MAC
    MacRxRec     : inout StreamRecType ;  -- Input to MAC

    PhyTxRec     : inout StreamRecType ;  -- Input to Phy
    PhyRxRec     : inout StreamRecType    -- Output from Phy
  ) ;
end entity TestCtrl ;
