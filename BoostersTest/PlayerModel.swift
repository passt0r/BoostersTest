//
//  PlayerModel.swift
//  BoostersTest
//
//  Created by Dmytro Pasinchuk on 20.07.2020.
//  Copyright © 2020 Dmytro Pasinchuk. All rights reserved.
//

import Foundation

public class PlayerModel {
    public let possibleSoundTimers: [Duration] = [
        Duration(readableDuration: "off", durationInSeconds: 0),
        Duration(readableDuration: "1 min", durationInSeconds: 60),
        Duration(readableDuration: "5 min", durationInSeconds: 60*5),
        Duration(readableDuration: "10 min", durationInSeconds: 60*10)
    ]
    
    public let possibleRecordingTimers: [Duration] = [
        Duration(readableDuration: "off", durationInSeconds: 0),
        Duration(readableDuration: "1 min", durationInSeconds: 60),
        Duration(readableDuration: "5 min", durationInSeconds: 60*5),
        Duration(readableDuration: "1 hour", durationInSeconds: 60*60)
    ]
}
