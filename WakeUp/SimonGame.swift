//
//  Game.swift
//  WakeUp
//

import Foundation
import UIKit

class SimonGame {
    var score: Int
    var sequence: [UIButton]
    var sequenceCount: Int
    var playerCount: Int
    var lastButton: UIButton?
    
    init(score: Int, sequence: [UIButton], sequenceCount: Int, playerCount: Int, lastButton: UIButton?) {
        self.score = score
        self.sequence = sequence
        self.sequenceCount = sequenceCount
        self.playerCount = playerCount
        self.lastButton = lastButton
    }
}
