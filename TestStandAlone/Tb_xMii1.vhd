--
--  File Name:         Tb_xMii1.vhd
--  Design Unit Name:  Architecture of TestCtrl
--  Revision:          OSVVM MODELS STANDARD VERSION
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--      GetBurst with no last, just ID and Dest changes
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
architecture xMii1 of TestCtrl is

  signal   TestDone : integer_barrier := 1 ;
  
 
begin

  ------------------------------------------------------------
  -- ControlProc
  --   Set up AlertLog and wait for end of test
  ------------------------------------------------------------
  ControlProc : process
  begin
    -- Initialization of test
    SetTestName("Tb_xMii1") ;
    SetLogEnable(PASSED, TRUE) ;    -- Enable PASSED logs
    SetLogEnable(INFO, TRUE) ;    -- Enable INFO logs

    -- Wait for testbench initialization 
    wait for 0 ns ;  wait for 0 ns ;
    TranscriptOpen("Tb_xMii1.txt") ;
    SetTranscriptMirror(TRUE) ; 

    -- Wait for Design Reset
--    wait until nReset = '1' ;  
    ClearAlerts ;

    -- Wait for test to finish
    WaitForBarrier(TestDone, 5 ms) ;
    AlertIf(now >= 5 ms, "Test finished due to timeout") ;
    AlertIf(GetAffirmCount < 1, "Test is not Self-Checking");
    
    TranscriptClose ; 
--    AffirmIfNotDiff("Tb_xMii1.txt", OSVVM_PATH_TO_TESTS & "/validated_results/TestStandAlone/Tb_xMii1.txt", "") ; 
    
    EndOfTestReports ; 
    std.env.stop ; 
    wait ; 
  end process ControlProc ; 

  
  ------------------------------------------------------------
  MacTxProc : process
  ------------------------------------------------------------
    variable CoverID : CoverageIdType ; 
  begin
    WaitForClock(MacTxRec, 2) ; 
    
-- SendBurstIncrement and CheckBurstIncrement    
    log("SendBurstIncrement 16 word burst") ;
    PushBurstIncrement(MacTxRec.BurstFifo, X"00", 1024) ; 
    SendBurst(MacTxRec, 16) ; 
    
    SendBurst(MacTxRec, 16) ; 

    SendBurst(MacTxRec, 256) ; 

    SendBurst(MacTxRec, 32) ; 
    
    SendBurst(MacTxRec, 64) ; 

    SendBurst(MacTxRec, 128) ; 

    SendBurst(MacTxRec, 256) ; 
    SendBurst(MacTxRec, 256) ; 
   
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(MacTxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process MacTxProc ;


  ------------------------------------------------------------
  PhyTxProc : process
  ------------------------------------------------------------
    variable PacketLength : integer ; 
  begin
    WaitForClock(PhyTxRec, 2) ; 
    
    GetBurst(PhyTxRec, PacketLength) ;
    AffirmIfEqual(PacketLength, 16, "Tx Packet 1 Length") ; 
    CheckBurstIncrement(PhyTxRec.BurstFifo, X"00", 16) ; 
    
    GetBurst(PhyTxRec, PacketLength) ;
    AffirmIfEqual(PacketLength, 16, "Tx Packet 2 Length") ; 
    CheckBurstIncrement(PhyTxRec.BurstFifo, X"10", 16) ; 

    GetBurst(PhyTxRec, PacketLength) ;
    AffirmIfEqual(PacketLength, 256, "Tx Packet 3 Length") ; 
    CheckBurstIncrement(PhyTxRec.BurstFifo, X"20", 256) ; 

    GetBurst(PhyTxRec, PacketLength) ;
    AffirmIfEqual(PacketLength, 32, "Tx Packet 4 Length") ; 
    CheckBurstIncrement(PhyTxRec.BurstFifo, X"20", 32) ; 
    
    GetBurst(PhyTxRec, PacketLength) ;
    AffirmIfEqual(PacketLength, 64, "Tx Packet 5 Length") ; 
    CheckBurstIncrement(PhyTxRec.BurstFifo, X"40", 64) ; 

    GetBurst(PhyTxRec, PacketLength) ;
    AffirmIfEqual(PacketLength, 128, "Tx Packet 6 Length") ; 
    CheckBurstIncrement(PhyTxRec.BurstFifo, X"80", 128) ; 

    GetBurst(PhyTxRec, PacketLength) ;
    AffirmIfEqual(PacketLength, 256, "Tx Packet 7 Length") ; 
    CheckBurstIncrement(PhyTxRec.BurstFifo, X"00", 256) ; 

    GetBurst(PhyTxRec, PacketLength) ;
    AffirmIfEqual(PacketLength, 256, "Tx Packet 8 Length") ; 
    CheckBurstIncrement(PhyTxRec.BurstFifo, X"00", 256) ; 
    
    WaitForClock(PhyTxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process PhyTxProc ;
  
  ------------------------------------------------------------
  PhyRxProc : process
  ------------------------------------------------------------
    variable CoverID : CoverageIdType ; 
  begin
    WaitForClock(PhyRxRec, 2) ; 
    
-- SendBurstIncrement and CheckBurstIncrement    
    log("SendBurstIncrement 16 word burst") ;
    PushBurstIncrement(PhyRxRec.BurstFifo, X"80", 1024) ; 
    SendBurst(PhyRxRec, 128) ; 

    SendBurst(PhyRxRec, 128) ; 

    SendBurst(PhyRxRec, 16) ; 
    
    SendBurst(PhyRxRec, 16) ; 

    SendBurst(PhyRxRec, 32) ; 
    
    SendBurst(PhyRxRec, 64) ; 

    SendBurst(PhyRxRec, 128) ; 

    SendBurst(PhyRxRec, 256) ; 
    SendBurst(PhyRxRec, 256) ; 
   
    -- Wait for outputs to propagate and signal TestDone
    WaitForClock(PhyRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process PhyRxProc ;


  ------------------------------------------------------------
  MacRxProc : process
  ------------------------------------------------------------
    variable PacketLength : integer ; 
  begin
    WaitForClock(MacRxRec, 2) ; 
    
    GetBurst(MacRxRec, PacketLength) ;
    AffirmIfEqual(PacketLength, 128, "Rx Packet 1 Length") ; 
    CheckBurstIncrement(MacRxRec.BurstFifo, X"80", 128) ; 
    
    GetBurst(MacRxRec, PacketLength) ;
    AffirmIfEqual(PacketLength, 128, "Rx Packet 2 Length") ; 
    CheckBurstIncrement(MacRxRec.BurstFifo, X"00", 128) ; 

    GetBurst(MacRxRec, PacketLength) ;
    AffirmIfEqual(PacketLength, 16, "Rx Packet 3 Length") ; 
    CheckBurstIncrement(MacRxRec.BurstFifo, X"80", 16) ; 

    GetBurst(MacRxRec, PacketLength) ;
    AffirmIfEqual(PacketLength, 16, "Rx Packet 4 Length") ; 
    CheckBurstIncrement(MacRxRec.BurstFifo, X"90", 16) ; 

    GetBurst(MacRxRec, PacketLength) ;
    AffirmIfEqual(PacketLength, 32, "Rx Packet 5 Length") ; 
    CheckBurstIncrement(MacRxRec.BurstFifo, X"A0", 32) ; 
    
    GetBurst(MacRxRec, PacketLength) ;
    AffirmIfEqual(PacketLength, 64, "Rx Packet 6 Length") ; 
    CheckBurstIncrement(MacRxRec.BurstFifo, X"C0", 64) ; 

    GetBurst(MacRxRec, PacketLength) ;
    AffirmIfEqual(PacketLength, 128, "Rx Packet 7 Length") ; 
    CheckBurstIncrement(MacRxRec.BurstFifo, X"00", 128) ; 

    GetBurst(MacRxRec, PacketLength) ;
    AffirmIfEqual(PacketLength, 256, "Rx Packet 8 Length") ; 
    CheckBurstIncrement(MacRxRec.BurstFifo, X"80", 256) ; 

    GetBurst(MacRxRec, PacketLength) ;
    AffirmIfEqual(PacketLength, 256, "Rx Packet 9 Length") ; 
    CheckBurstIncrement(MacRxRec.BurstFifo, X"80", 256) ; 
    
    WaitForClock(MacRxRec, 2) ;
    WaitForBarrier(TestDone) ;
    wait ;
  end process MacRxProc ;
end xMii1 ;

Configuration Tb_xMii1 of TbStandAlone is
  for TestHarness
    for TestCtrl_1 : TestCtrl
      use entity work.TestCtrl(xMii1) ; 
    end for ; 
  end for ; 
end Tb_xMii1 ; 