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
    
    let playerModel: PlayerModel
    var playerNotificationHandler: PlayerNotificationHandler?
    
    private var subscriptions = Set<AnyCancellable>()
    
    private var soundAudioPlayer: AVAudioPlayer?
    private var audioSession: AVAudioSession?
    private var audioRecorder: AVAudioRecorder?
    
    private let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    @Published var soundPlayingRemainingTime: TimeInterval = 0
    @Published var recordingRemainingTime: TimeInterval = 0
    
    @Published public var playerState: PlayerState = .idle
    
    init() {
        self.playerModel = PlayerModel()
        defer {
            self.playerNotificationHandler = PlayerNotificationHandler(playerDelegate: self)
        }
    }
    
    func toggleAudioFlow(withSoundTimer selectedSoundTimerPosition: Int, withRecordingTimer selectedRecordingTimerPosition: Int) {
        let selectedSoundDuration = playerModel.possibleSoundTimers[selectedSoundTimerPosition].durationInSeconds
        let selectedRecordingDuration = playerModel.possibleRecordingTimers[selectedRecordingTimerPosition].durationInSeconds
        guard selectedSoundDuration != 0 || selectedRecordingDuration != 0 else {
            stopAudioPlaying()
            finishRecording()
            return
        }
        
        switch playerState {
        case .idle:
            playerState = .playing
            setRemainingTimersDuration(withPlayingTimeInterval: selectedSoundDuration, withRecordingTimeInterval: selectedRecordingDuration)
            startAudioCycle()
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
    
    private func setRemainingTimersDuration(withPlayingTimeInterval: TimeInterval, withRecordingTimeInterval: TimeInterval) {
        self.soundPlayingRemainingTime = withPlayingTimeInterval
        self.recordingRemainingTime = withRecordingTimeInterval
    }
    
    private func checkPlayerStatus() {
        switch playerState {
        case .playing:
            let remainingPlayingTime = soundPlayingRemainingTime - 1
            print("Remaining playing time: \(remainingPlayingTime)")
            if remainingPlayingTime <= 0 {
                soundPlayingRemainingTime = 0
                stopAudioPlaying()
                startAudioRecording()
            } else {
                soundPlayingRemainingTime = remainingPlayingTime
            }
        case .recording:
            let remainingRecordingTime = recordingRemainingTime - 1
            print("Remaining recording time: \(remainingRecordingTime)")
            if remainingRecordingTime <= 0 {
                recordingRemainingTime = 0
                finishRecording()
            } else {
                recordingRemainingTime = remainingRecordingTime
            }
        default:
            break
        }
    }
}

//MARK: - Audio player
extension PlayerViewModel: PlayerStateHandlerInteractionProtocol {
    func stopAudioPlaying() {
        soundAudioPlayer?.stop()
        soundAudioPlayer = nil
    }
    
    func pauseAudioPlaying() {
        soundAudioPlayer?.pause()
        playerState = .pausedFromPlaying
    }
    
    func resumeAudioPlay() {
        soundAudioPlayer?.play()
        playerState = .playing
    }
    
    private func startAudioCycle() {
        requestRecordingPrivelegies { [unowned self] in
            self.loadAudioForPlaying()
        }
    }
    
    private func loadAudioForPlaying() {
        let playedAudioFilename = "nature.m4a"
        guard let path = Bundle.main.path(forResource: playedAudioFilename, ofType: nil) else { return }
        let url = URL(fileURLWithPath: path)
        
        timer.sink { [unowned self] (_) in
            self.checkPlayerStatus()
        }.store(in: &subscriptions)
        
        playerNotificationHandler?.setupNotifications()
        
        do {
            try audioSession?.setCategory(.playback, mode: .default)
            print("Playback OK")
            try audioSession?.setActive(true)
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
    func stopAudioRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
    }
    
    func pauseAudioRecording() {
        audioRecorder?.pause()
        playerState = .pausedFromRecording
    }
    
    func resumeAudioRecording() {
        audioRecorder?.record()
        playerState = .recording
    }
    
    private func startAudioRecording() {
        setupRecording()
    }
    
    private func requestRecordingPrivelegies(and performTask: @escaping ()->Void ) {
        self.audioSession = AVAudioSession.sharedInstance()
        audioSession?.requestRecordPermission() { allowed in
            DispatchQueue.main.async {
                if allowed {
                    performTask()
                } else {
                   print("Could not allowed to record audio")
                }
            }
        }
    }
    
    private func setupRecording() {
        do {
            try audioSession?.setCategory(.playAndRecord, mode: .default)
            try audioSession?.setActive(true)
            self.startRecording()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func startRecording() {
        let recordedAudioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: recordedAudioFilename, settings: settings)
            audioRecorder?.record()
            self.playerState = .recording
        } catch {
            finishRecording()
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func finishRecording() {
        stopAudioRecording()
        self.playerState = .idle
        audioSession = nil
        self.subscriptions.removeAll()
    }
}
