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
    
    func testStatusChanging() throws {
        //Given
        let statusBeforeStarting = playerViewModel.playerState
        let expected = PlayerState.playing
        let expectation = self.expectation(description: #function)
        let soundTimerInDataBasePosition = 1
        let recordTimerInDataBasePosition = 1
        var result: PlayerState? = nil
        
        //When
        playerViewModel.toggleAudioFlow(withSoundTimerDuration: soundTimerInDataBasePosition, withRecordingTimerDuration: recordTimerInDataBasePosition)
        
        playerViewModel.$playerState.sink { (receivedState) in
            result = receivedState
            expectation.fulfill()
        }.store(in: &subscriptions)
        
        //Then
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssert(statusBeforeStarting != result, "Results expected to be: \(expected), but was: \(String(describing: result))")
    }
    
    func testPausePlayingStatus() throws {
        //Given
        let statusBeforeStarting = playerViewModel.playerState
        let expected = PlayerState.pausedFromPlaying
        let expectation = self.expectation(description: #function)
        let soundTimerInDataBasePosition = 1
        let recordTimerInDataBasePosition = 1
        var result: PlayerState? = nil
        
        //When
        playerViewModel.toggleAudioFlow(withSoundTimerDuration: soundTimerInDataBasePosition, withRecordingTimerDuration: recordTimerInDataBasePosition)
        playerViewModel.pauseAudioPlaying()
        
        playerViewModel.$playerState.sink { (receivedState) in
            result = receivedState
            expectation.fulfill()
        }.store(in: &subscriptions)
        
        //Then
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssert(statusBeforeStarting != result, "Results expected to be: \(expected), but was: \(String(describing: result))")
    }
    
    func testPauseRecordStatus() throws {
        //Given
        let statusBeforeStarting = playerViewModel.playerState
        let expected = PlayerState.pausedFromRecording
        let expectation = self.expectation(description: #function)
        let soundTimerDuration: TimeInterval = 1
        let recordTimerDuration: TimeInterval = 6
        var result: PlayerState? = nil
        
        //When
        playerViewModel.toggleAudioFlow(with: soundTimerDuration, and: recordTimerDuration)
        
        
        playerViewModel.$playerState.sink { (receivedState) in
            result = receivedState
            expectation.fulfill()
        }.store(in: &subscriptions)
        
        //Then
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssert(statusBeforeStarting != result, "Results expected to be: \(expected), but was: \(String(describing: result))")
    }
    
    func testStopStatus() throws {
        //Given
        let expected = PlayerState.idle
        let expectation = self.expectation(description: #function)
        let soundTimerInDataBasePosition = 1
        let recordTimerInDataBasePosition = 1
        let zeroSoundDuration: TimeInterval = 0
        let zeroRecordDuration: TimeInterval = 0
        var result: PlayerState? = nil
        
        //When
        playerViewModel.toggleAudioFlow(withSoundTimerDuration: soundTimerInDataBasePosition, withRecordingTimerDuration: recordTimerInDataBasePosition)
        playerViewModel.toggleAudioFlow(with: zeroSoundDuration,and: zeroRecordDuration)
        
        playerViewModel.$playerState.sink { (receivedState) in
            result = receivedState
            expectation.fulfill()
        }.store(in: &subscriptions)
        
        //Then
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssert(result == expected, "Results expected to be: \(expected), but was: \(String(describing: result))")
    }

}
