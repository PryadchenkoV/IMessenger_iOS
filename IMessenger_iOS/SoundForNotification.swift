//
//  SoundForNotification.swift
//  IMessenger_iOS
//
//  Created by Ivan Pryadchenko on 10.12.16.
//  Copyright © 2016 Ivan Pryadchenko. All rights reserved.
//

import Foundation
import AVFoundation

var player: AVAudioPlayer?

func playSound() {
    let url = Bundle.main.url(forResource: "soundName", withExtension: "mp3")!
    
    do {
        player = try AVAudioPlayer(contentsOf: url)
        guard let player = player else { return }
        
        player.prepareToPlay()
        player.play()
    } catch let error {
        print(error.localizedDescription)
    }
}
