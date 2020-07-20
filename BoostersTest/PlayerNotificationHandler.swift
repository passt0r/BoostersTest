//
//  PlayerNotificationHandler.swift
//  BoostersTest
//
//  Created by Dmytro Pasinchuk on 20.07.2020.
//  Copyright © 2020 Dmytro Pasinchuk. All rights reserved.
//

import Combine
import AVFoundation
import Dispatch
import MediaPlayer

protocol PlayerStateHandlerInteractionProtocol: AnyObject {
    var playerState: PlayerState { get set }
    
    func resumeAudioPlay()
    func resumeAudioRecording()
    func pauseAudioPlaying()
    func pauseAudioRecording()
    func stopAudioPlaying()
    func finishRecording()
}

class PlayerNotificationHandler {
    private weak var playerDelegate: PlayerStateHandlerInteractionProtocol?
    
    init(playerDelegate: PlayerStateHandlerInteractionProtocol) {
        self.playerDelegate = playerDelegate
    }
    
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
            guard let playerDelegate = self.playerDelegate else { return .commandFailed }
            switch playerDelegate.playerState {
            case .pausedFromPlaying:
                playerDelegate.resumeAudioPlay()
                return .success
            case .pausedFromRecording:
                playerDelegate.resumeAudioRecording()
                return .success
            case .idle:
                return .noActionableNowPlayingItem
            case .playing, .recording:
                return .commandFailed
            }
        }
        mediaPlayerCenter.pauseCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
            guard let playerDelegate = self.playerDelegate else { return .commandFailed }
            switch playerDelegate.playerState {
            case .playing:
                playerDelegate.pauseAudioPlaying()
                return .success
            case .recording:
                playerDelegate.pauseAudioRecording()
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
        guard let playerDelegate = self.playerDelegate else { return }
        
        // Switch over the interruption type.
        switch type {
        case .began:
            switch playerDelegate.playerState {
            case .playing:
                playerDelegate.pauseAudioPlaying()
            case .recording:
                playerDelegate.pauseAudioRecording()
            default:
                break
            }
        case .ended:
           // An interruption ended. Resume playback, if appropriate.
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                // Interruption ended. Playback should resume.
                switch playerDelegate.playerState {
                case .pausedFromPlaying:
                    playerDelegate.resumeAudioPlay()
                case .pausedFromRecording:
                    playerDelegate.resumeAudioRecording()
                default:
                    break
                }
            } else {
                // Interruption ended. Playback should not resume.
                playerDelegate.stopAudioPlaying()
                playerDelegate.finishRecording()
            }

        default: ()
        }
    }
}
