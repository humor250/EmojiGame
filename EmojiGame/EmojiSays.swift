//
//  EmojiSays.swift
//  EmojiGame
//
//  Created by joanthan liu on 2018/9/8.
//  Copyright © 2018年 Butterfly Tech. All rights reserved.
//

import AVFoundation

class EmojiSays: NSObject {
    static let shared = EmojiSays()
    
    let synth = AVSpeechSynthesizer()
    let audioSession = AVAudioSession.sharedInstance()
    
    override init() {
        super.init()
        
        synth.delegate = self
    }
    
    func say(sentence: NSAttributedString) {
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.duckOthers)
            
            let utterance = AVSpeechUtterance(string: sentence.string)
            //utterance.pitchMultiplier = -2.0
            try audioSession.setActive(true)
            
            synth.speak(utterance)
        } catch {
            print("Uh oh!")
        }
    }
}

extension EmojiSays: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        do {
            try audioSession.setActive(false)
        } catch {
            print("Uh oh!")
        }
    }
}
