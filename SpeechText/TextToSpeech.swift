//
//  TextToSpeech.swift
//  SpeechText
//
//  Created by Emily Jewik on 9/22/18.
//  Copyright © 2018 Emily Jewik. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
class TextToSpeech : UIViewController , UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var speakButton: UIButton!
    
    //let string = "Hello, World!"
    var utterance : AVSpeechUtterance?
   
    
    let synth = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        utterance?.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        textView.delegate = self
       
        
    }
    
    
    @IBAction func speakButtonTapped(_ sender: UIButton) {
        utterance = AVSpeechUtterance(string: textView.text)
        synth.speak(utterance!)
    }
    

}
