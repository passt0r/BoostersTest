//
//  BoostersTestTests.swift
//  BoostersTestTests
//
//  Created by Dmytro Pasinchuk on 09.07.2020.
//  Copyright © 2020 Dmytro Pasinchuk. All rights reserved.
//

import XCTest
import Combine
@testable import BoostersTest

class BoostersTestTests: XCTestCase {
    
    private var playerViewModel: PlayerViewModel!
    private var subscriptions: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        playerViewModel = PlayerViewModel()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        subscriptions = []
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPlaybackStarts() throws {
        //Given
        let statusBeforeStarting = playerViewModel.playerState
        let expectation = self.expectation(description: #function)
        playerViewModel.soundPlayingRemainingTime = 2
        playerViewModel.recordingRemainingTime = 2
        var result: PlayerState? = nil
        
        //When
        playerViewModel.$playerState.sink { (receivedState) in
            result = receivedState
            expectation.fulfill()
        }.store(in: &subscriptions)
        
        playerViewModel.startAudioCycle()
        
        //Then
        waitForExpectations(timeout: 2, handler: nil)
        
        XCTAssert(statusBeforeStarting != result, "Results expected to be: \(PlayerState.playing), but was: \(result)")
    }
    
    func testStatusChanging() throws {
        //Given
        let statusBeforeStarting = playerViewModel.playerState
        let expectation = self.expectation(description: #function)
        let soundTimerInDataBasePosition = 1
        let recordTimerInDataBasePosition = 1
        var result: PlayerState? = nil
        
        //When
        playerViewModel.$playerState.sink { (receivedState) in
            result = receivedState
            expectation.fulfill()
        }.store(in: &subscriptions)
        
        playerViewModel.toggleAudioFlow(withSoundTimerDuration: soundTimerInDataBasePosition, withRecordingTimerDuration: recordTimerInDataBasePosition)
        
        //Then
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssert(statusBeforeStarting != result, "Results expected to be: \(PlayerState.playing), but was: \(result)")
    }

}
