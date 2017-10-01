//
//  MusicPlayerManager.swift
//  Scrapbooks
//
//  Created by Alan Li on 2017-09-30.
//  Copyright © 2017 Alan Li. All rights reserved.
//

import Foundation
import MediaPlayer

struct MusicPlayerManager {
    
    private init() {}
    
    private static let player = MPMusicPlayerController.applicationQueuePlayer
    
    static func play() {
        player.setQueue(with: MPMediaQuery.songs())
        player.play()
    }
}
