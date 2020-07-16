//
//  PlayerViewModel.swift
//  BoostersTest
//
//  Created by Dmytro Pasinchuk on 16.07.2020.
//  Copyright © 2020 Dmytro Pasinchuk. All rights reserved.
//

import Combine
import AVFoundation
import Dispatch

public final class PlayerViewModel: ObservableObject {
    public enum PlayerState: String {
      case idle = "Idle", playing = "Playing", recording = "Recording", pausedFromPlaying = "Playing paused", pausedFromRecording = "Recording paused"
    }
    
    private var soundAudioPlayer: AVAudioPlayer?
    private var recordingSession: AVAudioSession?
    private var audioRecorder: AVAudioRecorder?
    
    @Published public var playerState: PlayerState = .idle
    public var possibkeSoundTimers = ["off", "1 min", "5 min", "10 min"]
    public var possibkeRecordingTimers = ["off", "1 min", "5 min", "1 hour"]
    
    func toggleAudioFlow(withSoundTimer selectedSoundTimer: Int, withRecordingTimer selectedRecordingTimer: Int) {
        switch playerState {
        case .idle:
            playerState = .playing
        case .playing:
            playerState = .pausedFromPlaying
        case .recording:
            playerState = .pausedFromRecording
        case .pausedFromPlaying:
            playerState = .playing
        case .pausedFromRecording:
            playerState = .recording
        }
        loadAudioForPlaying()
    }
    
    private func loadAudioForPlaying() {
        let path = Bundle.main.path(forResource: "nature.m4a", ofType: nil)!
        let url = URL(fileURLWithPath: path)

        do {
            soundAudioPlayer = try AVAudioPlayer(contentsOf: url)
            soundAudioPlayer?.numberOfLoops = 10
            soundAudioPlayer?.play()
        } catch {
            // couldn't load file :(
        }
    }
    
}
