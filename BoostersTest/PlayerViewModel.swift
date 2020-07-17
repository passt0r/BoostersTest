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
import MediaPlayer

public final class PlayerViewModel: ObservableObject {
    public enum PlayerState: String {
      case idle = "Idle", playing = "Playing", recording = "Recording", pausedFromPlaying = "Playing paused", pausedFromRecording = "Recording paused"
    }
    private var subscriptions = Set<AnyCancellable>()
    
    private var soundAudioPlayer: AVAudioPlayer?
    private var recordingSession: AVAudioSession?
    private var audioRecorder: AVAudioRecorder?
    
    private let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    @Published var playingRemainingPlayingTime: TimeInterval = 0
    @Published var recordingRemainingPlayingTime: TimeInterval = 0
    
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
            setRemainingTimeIntervals(withPlayingTimeIntervalPosition: selectedSoundTimer, withRecordingTimeIntervalPosition: selectedRecordingTimer)
            loadAudioForPlaying()
        case .playing:
            pauseAudioPlaying()
        case .recording:
            pauseAudioRecording()
        case .pausedFromPlaying:
            resumeAudioPlay()
        case .pausedFromRecording:
            resumeAudioRecording()
        }
    }
    
    private func setRemainingTimeIntervals(withPlayingTimeIntervalPosition: Int, withRecordingTimeIntervalPosition: Int) {
        setPlayingRemainingTimeInterval(withPlayingTimeIntervalPosition: withPlayingTimeIntervalPosition)
        setRecordingRemainingTimeInterval(withRecordingTimeIntervalPosition: withRecordingTimeIntervalPosition)
    }
    
    private func setPlayingRemainingTimeInterval(withPlayingTimeIntervalPosition: Int) {
        switch withPlayingTimeIntervalPosition {
        case 0:
            self.playingRemainingPlayingTime = 0
        case 1:
            self.playingRemainingPlayingTime = 60
        case 2:
            self.playingRemainingPlayingTime = 60 * 5
        case 3:
            self.playingRemainingPlayingTime = 60 * 60
        default:
            self.playingRemainingPlayingTime = 0
        }
    }
    
    private func setRecordingRemainingTimeInterval(withRecordingTimeIntervalPosition: Int) {
        switch withRecordingTimeIntervalPosition {
        case 0:
            self.recordingRemainingPlayingTime = 0
        case 1:
            self.recordingRemainingPlayingTime = 60
        case 2:
            self.recordingRemainingPlayingTime = 60 * 5
        case 3:
            self.recordingRemainingPlayingTime = 60 * 10
        default:
            self.recordingRemainingPlayingTime = 0
        }
    }
    
    @objc private func checkPlayerStatus() {
        switch playerState {
        case .playing:
            let remainingPlayingTime = playingRemainingPlayingTime - 1
            print("Remaining playing time: \(remainingPlayingTime)")
            if remainingPlayingTime <= 0 {
                playingRemainingPlayingTime = 0
                stopAudioPlaying()
                startAudioRecording()
            } else {
                playingRemainingPlayingTime = remainingPlayingTime
            }
        case .recording:
            let remainingRecordingTime = recordingRemainingPlayingTime - 1
            print("Remaining recording time: \(remainingRecordingTime)")
            if remainingRecordingTime <= 0 {
                recordingRemainingPlayingTime = 0
                finishRecording()
            } else {
                recordingRemainingPlayingTime = remainingRecordingTime
            }
        default:
            break
        }
    }
}

//MARK: - Audio player
extension PlayerViewModel {
    private func stopAudioPlaying() {
        soundAudioPlayer?.stop()
        soundAudioPlayer = nil
    }
    
    private func pauseAudioPlaying() {
        soundAudioPlayer?.pause()
        playerState = .pausedFromPlaying
    }
    
    private func resumeAudioPlay() {
        soundAudioPlayer?.play()
        playerState = .playing
    }
    
    private func startAudioCycle() {
        requestRecording()
    }
    
    private func loadAudioForPlaying() {
        guard let path = Bundle.main.path(forResource: "nature.m4a", ofType: nil) else { return }
        let url = URL(fileURLWithPath: path)
        timer.sink { [unowned self] (_) in
            self.checkPlayerStatus()
        }.store(in: &subscriptions)
        
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

//MARK: - Handle background audio session
extension PlayerViewModel {
    private func setupNotifications() {
        // Get the default notification center instance.
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                       selector: #selector(handleInterruption),
                       name: AVAudioSession.interruptionNotification,
                       object: nil)
        
        setupMediaPlayerNotifications()
    }
    
    private func setupMediaPlayerNotifications() {
        let mediaPlayerCenter = MPRemoteCommandCenter.shared()
        mediaPlayerCenter.playCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
            switch self.playerState {
            case .pausedFromPlaying:
                self.resumeAudioPlay()
                return .success
            case .pausedFromRecording:
                self.resumeAudioRecording()
                return .success
            case .idle:
                return .noActionableNowPlayingItem
            case .playing, .recording:
                return .commandFailed
            }
        }
        mediaPlayerCenter.pauseCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
            switch self.playerState {
            case .playing:
                self.pauseAudioPlaying()
                return .success
            case .recording:
                self.pauseAudioRecording()
                return .success
            case .idle:
                return .noActionableNowPlayingItem
            case .pausedFromPlaying, .pausedFromRecording:
                return .commandFailed
            }
        }
    }

    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }

        // Switch over the interruption type.
        switch type {
        case .began:
            switch self.playerState {
            case .playing:
                self.playerState = .pausedFromPlaying
                self.soundAudioPlayer?.pause()
            case .recording:
                self.playerState = .pausedFromRecording
                self.audioRecorder?.pause()
            default:
                break
            }
        case .ended:
           // An interruption ended. Resume playback, if appropriate.
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                // Interruption ended. Playback should resume.
                switch self.playerState {
                case .pausedFromPlaying:
                    self.playerState = .playing
                    self.soundAudioPlayer?.play()
                case .pausedFromRecording:
                    self.playerState = .recording
                    self.audioRecorder?.record()
                default:
                    break
                }
            } else {
                // Interruption ended. Playback should not resume.
                self.playerState = .idle
                self.stopAudioPlaying()
                self.stopAudioRecording()
            }

        default: ()
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
    
    private func pauseAudioRecording() {
        audioRecorder?.pause()
        playerState = .pausedFromRecording
    }
    
    private func resumeAudioRecording() {
        audioRecorder?.record()
        playerState = .recording
    }
    
    private func startAudioRecording() {
        requestRecording()
    }
    
    private func requestRecording() {
        self.recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default)
            try recordingSession?.setActive(true)
            recordingSession?.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.startRecording()
                    } else {
                       print("Could not allowed to record audio")
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.record()
            self.playerState = .recording
        } catch {
            finishRecording()
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func finishRecording() {
        stopAudioRecording()
        self.playerState = .idle
    }
}
