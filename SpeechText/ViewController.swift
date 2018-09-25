//
//  ViewController.swift
//  Siri
//
//  Created by Sahand Edrisian on 7/14/16.
//  Copyright © 2016 Sahand Edrisian. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
	
	
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var speakField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var messages = [Message]() {
        didSet {
            tableView.reloadData()
        }
    }//didSet?
    
    var message : Message!
    
    
	
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
	override func viewDidLoad() {
        super.viewDidLoad()
        self.messages.append(Message(message: "hey", sender: "test")) // okee so new messages don't dequeue at all...
        self.tableView.register(MessagesCell.self, forCellReuseIdentifier: "Message")
        
        tableView.delegate = self
        
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.estimatedRowHeight = 300
        //make sure you load data
        tableView.reloadData()
        
        microphoneButton.isEnabled = false
        
        speechRecognizer.delegate = self
        
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
        
        //gesture recognizer code
        
//        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
//        swipeRight.direction = UISwipeGestureRecognizerDirection.right
//        
//        self.view.addGestureRecognizer(swipeRight)
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
//        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
//        self.view.addGestureRecognizer(swipeLeft)
	}

	@IBAction func microphoneTapped(_ sender: AnyObject) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            microphoneButton.isEnabled = false
            microphoneButton.setTitle("Start Recording", for: .normal)
        } else {
            let message = Message(message: "message", sender: "sender") //need to have message be the current text
            
            self.messages.append(message)
            startRecording(message: message )
            microphoneButton.setTitle("Stop Recording", for: .normal)
        }
	}

    func startRecording(message: Message) {
        
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        
        let inputNode = audioEngine.inputNode 
        
//        guard let inputNode = audioEngine.inputNode else {
//            fatalError("Audio engine has no input node")
//        }  //4
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = true  //6
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            
            if result != nil {
                
                //self.textView.text = result?.bestTranscription.formattedString  //9
                
                //this should only execute once...
                //self.tableView.insertRows(at: [IndexPath(row: self.messages.count-1, section: 0)], with: .automatic)
                //self.tableView.reloadData()
                //self.tableView.cellForRow(at: IndexPath(row: self.messages.count-1, section: 0))?.textLabel?.text = result?.bestTranscription.formattedString
                //self.tableView.reloadData()
                
                //this sort of works
//                self.messages.append(Message(message: (result?.bestTranscription.formattedString)!, sender: ""))
//                self.tableView.reloadData()
                
                self.tableView.cellForRow(at: IndexPath(row: self.messages.count-1, section: 0))?.textLabel?.text = result?.bestTranscription.formattedString
                self.tableView.reloadData() //IT WORKS
               
                message._message = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.microphoneButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
       // textView.text = "Say something, I'm listening!"
        
    }
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count //probably bc no messages in message array?
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Message", for: indexPath) as! MessagesCell
        cell.contentView.backgroundColor = UIColor.gray
            return cell
    }
        
        
            //cell receiverLabel.text =
            
//            return cell
//
//        } else {
//            return MessagesCell()
//        }
//    }
    
    //deal with swiping
    
//   @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
//        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
//            switch swipeGesture.direction {
//            case UISwipeGestureRecognizerDirection.right:
//                print("swipe right")
//                //right view controller
//                let newViewController = ViewController()
//                self.navigationController?.pushViewController(newViewController, animated: true)
//            case UISwipeGestureRecognizerDirection.left:
//                print("swipe left")
//                //left view controller
//                //let newViewController = TextToSpeech()
//                let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "TextToSpeech") as! TextToSpeech
//                self.navigationController?.pushViewController(newViewController, animated: true)
//
//
//            default:
//                break
//            }
//        }
//    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
}

