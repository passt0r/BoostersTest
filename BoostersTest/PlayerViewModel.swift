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
        guard selectedSoundTimer != 0 || selectedRecordingTimer != 0 else {
            stopAudioPlaying()
            stopAudioRecording()
            self.playerState = .idle
            return
        }
        switch playerState {
        case .idle:
            playerState = .playing
            loadAudioForPlaying()
        case .playing:
            playerState = .pausedFromPlaying
            soundAudioPlayer?.pause()
        case .recording:
            playerState = .pausedFromRecording
        case .pausedFromPlaying:
            playerState = .playing
            soundAudioPlayer?.play()
        case .pausedFromRecording:
            playerState = .recording
        }
        loadAudioForPlaying()
    }
    
}

//MARK: - Audio player
extension PlayerViewModel {
    private func stopAudioPlaying() {
        soundAudioPlayer?.stop()
        soundAudioPlayer = nil
    }
    
    private func loadAudioForPlaying() {
        guard let path = Bundle.main.path(forResource: "nature.m4a", ofType: nil) else { return }
        let url = URL(fileURLWithPath: path)

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is active")
            soundAudioPlayer = try AVAudioPlayer(contentsOf: url)
            soundAudioPlayer?.numberOfLoops = -1
            soundAudioPlayer?.prepareToPlay()
            soundAudioPlayer?.play()
            print("Player starts to play")
        } catch {
            print(error.localizedDescription)
        }
    }
}

//MARK: - Audio recorder
extension PlayerViewModel {
    private func stopAudioRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        recordingSession = nil
    }
    
    private func startAudioRecording() {
        requestRecording()
    }
    
    private func requestRecording() {
        
    }
    
    private func startRecording() {
        
    }
}
