//
//  Duration.swift
//  BoostersTest
//
//  Created by Dmytro Pasinchuk on 20.07.2020.
//  Copyright © 2020 Dmytro Pasinchuk. All rights reserved.
//

import Foundation

public class Duration: Identifiable, Equatable {
    public static func == (lhs: Duration, rhs: Duration) -> Bool {
        return lhs.readableDuration == rhs.readableDuration
    }
    
    let readableDuration: String
    let durationInSeconds: TimeInterval
    
    init(readableDuration: String, durationInSeconds: TimeInterval) {
        self.readableDuration = readableDuration
        self.durationInSeconds = durationInSeconds
    }
}
