//
//  Chat.swift
//  ClientApp
//
//  Created by Tristan Ratz on 24.09.19.
//  Copyright © 2019 Tristan Ratz. All rights reserved.
//

import Foundation
import SwiftUI

class Sender {
    let name:String
    let color:Color
    
    init(name:String,color:Color) {
        self.name = name
        self.color = color
    }
}

class Message : Identifiable {
    let id = UUID()
    let sender:Sender
    var message:String
    
    init(_ sender:Sender, message:String) {
        self.sender = sender
        self.message = message

    }
}

class Chat {
    var socket:Socket
    var chatName:String = ""
    
    var sender:[Sender] = []
    var messages:[Message] = []
    
    init(_ ip:String, port:Int) {
        socket = Socket(ip,port,.utf8)
    }
    
    func signIn() {
        
    }
    
    func signOut() {
        
    }
    
    func sendMessage() {
        
    }
    
    func newMessage(content:String, name:String) {
        var sender:Sender?
        for s in self.sender {
            if s.name == name {
                sender = s
                break
            }
        }
        
        if sender != nil {
            messages.append(Message(sender!, message: content))
            return
        }
        
        let color:Color
        switch Int.random(in:0...5) {
        case 0:
            color = Color.green
            break
        case 1:
            color = Color.yellow
            break
        case 2:
            color = Color.blue
            break
        case 3:
            color = Color.red
            break
        case 4:
            color = Color.purple
            break
        case 5:
            color = Color.orange
            break
        default:
            color = Color.white
        }
        
        messages.append(Message(Sender(name: name, color: color), message: content))
    }
}
