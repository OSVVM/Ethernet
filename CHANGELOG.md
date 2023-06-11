# DpRam Behavioral and Verification Component Change Log

| Revision  |  Release Summary | 
------------|----------- 
| 2023.05   | Bug Fix:  Updated looping in receivers 
| 2022.10   | Initial release

## 2023.05  May 2022
- Bug Fix:  updated receivers to use repeat until loop instead of while loop to avoid issues with using old value in first check of loop

## 2022.10 October 2022
- New repository with 
    - xMiiPhy.vhd  - Phy VC that supports GMII/RGMII/MII/RMII
    -   xMiiPhyRxTransmitter.vhd - Handles TX interface for Phy
    -   xMiiPhyTxReceiver.vhd - Handles RX interface for Phy
    - xMiiMac.vhd  - Mac VC that supports GMII/RGMII/MII/RMII
    -   xMiiMacTransmitter.vhd - Handles TX interface for MAC
    -   xMiiMacReceiver.vhd - Handles RX interface for MAC
    - xMiiTbPkg.vhd - Package with Types, Constants, and Subprograms supporting xMiiPhy and xMiiMac
    - xMiiComponentPkg.vhd - package with component declaration for xMiiPhy and xMiiMac
    - xMiiContext.vhd - Package references for xMiiPhy and xMiiMac

 
## Copyright and License
Copyright (C) 2022 by [SynthWorks Design Inc.](http://www.synthworks.com/)   
Copyright (C) 2022 by [OSVVM contributors](CONTRIBUTOR.md)   

This file is part of OSVVM.

    Licensed under Apache License, Version 2.0 (the "License")
    You may not use this file except in compliance with the License.
    You may obtain a copy of the License at

  [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
