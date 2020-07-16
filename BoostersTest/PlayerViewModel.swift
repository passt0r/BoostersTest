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
      case idle = "Idle", playing = "Playing", recording = "Recording", paused = "Paused"
    }
    
    @Published public var playerState: PlayerState = .idle
    public var possibkeSoundTimers = ["off", "1 min", "5 min", "10 min"]
    public var possibkeRecordingTimers = ["off", "1 min", "5 min", "1 hour"]
    
    func toggleAudioFlow(withSoundTimer selectedSoundTimer: Int, withRecordingTimer selectedRecordingTimer: Int) {
        
    }
    
}
