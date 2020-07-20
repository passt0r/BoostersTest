//
//  PlayerState.swift
//  BoostersTest
//
//  Created by Dmytro Pasinchuk on 20.07.2020.
//  Copyright © 2020 Dmytro Pasinchuk. All rights reserved.
//

import Foundation

public enum PlayerState: String {
  case idle = "Idle", playing = "Playing", recording = "Recording", pausedFromPlaying = "Playing paused", pausedFromRecording = "Recording paused"
}
