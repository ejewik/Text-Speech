//
//  Message.swift
//  SpeechText
//
//  Created by Emily Jewik on 9/22/18.
//  Copyright © 2018 Emily Jewik. All rights reserved.
//

import Foundation

class Message {
    
    var _message: String!
    
    private var _sender: String!
    
    private var _messageKey: String!
    
//    var message: String {
//        return _message
//    }
    
//    var sender: String {
//        return _sender
//    }
//
//    var messageKey: String{
//        return _messageKey
//    }
    
    init( message: String, sender: String) {
        _message = message
        _sender = sender
    }
    
//    init( messageKey: String, postData: Dictionary<String, AnyObject>) {
//        _messageKey = messageKey
//        if let message = postData["message"] as? String {
//            _message = message
//        }
//
//        if let sender = postData["sender"] as? String {
//            _sender = sender
//        }
//    }
}
