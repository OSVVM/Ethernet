#  File Name:         testbench.pro
#  Revision:          STANDARD VERSION
#
#  Maintainer:        Jim Lewis      email:  jim@synthworks.com
#  Contributor(s):
#     Jim Lewis      jim@synthworks.com
#
#
#  Description:
#        Script to run one Axi Stream test  
#
#  Developed for:
#        SynthWorks Design Inc.
#        VHDL Training Classes
#        11898 SW 128th Ave.  Tigard, Or  97223
#        http://www.SynthWorks.com
#
#  Revision History:
#    Date      Version    Description
#    10/2022   2022.10    Initial Release
#
#
#  This file is part of OSVVM.
#
#  Copyright (c) 2022 by SynthWorks Design Inc.
#  
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#  
#      https://www.apache.org/licenses/LICENSE-2.0
#  
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#  

TestSuite Ethernet
library Ethernet_TestStandAlone

analyze OsvvmTestCommonPkg.vhd

analyze TestCtrl_e.vhd
analyze TbStandAlone.vhd

RunTest Tb_xMii1.vhd [generic MII_INTERFACE RMII]  [generic MII_BPS BPS_100M]

#RunTest Tb_xMii1.vhd [generic MII_INTERFACE RGMII] [generic MII_BPS BPS_1G]
#RunTest Tb_xMii1.vhd [generic MII_INTERFACE MII]   [generic MII_BPS BPS_100M]

#simulate Tb_xMii1 [generic MII_INTERFACE RGMII] [generic MII_BPS BPS_1G]
#simulate Tb_xMii1 [generic MII_INTERFACE MII]   [generic MII_BPS BPS_100M]
#simulate Tb_xMii1 [generic MII_INTERFACE MII]   [generic MII_BPS BPS_10M]
#simulate Tb_xMii1 [generic MII_INTERFACE RMII]  [generic MII_BPS BPS_100M]
#simulate Tb_xMii1 [generic MII_INTERFACE RMII]  [generic MII_BPS BPS_10M]
