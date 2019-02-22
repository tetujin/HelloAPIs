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
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector (self.didTapTextView(_:)))
        self.textView.addGestureRecognizer(gesture)
        
    }
    
    @IBAction func speechButtonTapped(_ sender: UIButton) {
        let utterance = AVSpeechUtterance(string: textView.text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        talker.stopSpeaking(at: .immediate )
        talker.speak(utterance)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        talker.stopSpeaking(at: .immediate )
    }
    
    @objc func didTapTextView(_ sender:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
}

extension TTSViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                           didFinish utterance: AVSpeechUtterance) {
         // synthesizer.stopSpeaking(at: .immediate )
        
    }
}
