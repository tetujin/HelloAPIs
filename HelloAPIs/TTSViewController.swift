//
//  TTSViewController.swift
//  HelloAPIs
//
//  Created by Yuuki Nishiyama on 2019/02/19.
//  Copyright © 2019 Yuuki Nishiyama. All rights reserved.
//

import UIKit
import AVFoundation

class TTSViewController: UIViewController {

    let talker = AVSpeechSynthesizer()
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.talker.delegate = self
    
    }
    
    @IBAction func speechButtonTapped(_ sender: UIButton) {
        let utterance = AVSpeechUtterance(string: textView.text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        talker.speak(utterance)
    }
    
}

extension TTSViewController: AVSpeechSynthesizerDelegate {
//    func speechSynthesizer(synthesizer: AVSpeechSynthesizer,
//                           didFinishSpeechUtterance utterance: AVSpeechUtterance) {
//         synthesizer.stopSpeaking(at: .word)
//    }
}
