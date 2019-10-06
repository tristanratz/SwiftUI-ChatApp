//
//  Chat.swift
//  ClientApp
//
//  Created by Tristan Ratz on 24.09.19.
//  Copyright © 2019 Tristan Ratz. All rights reserved.
//

import Combine
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

class Chat : ObservableObject {
    
    var delegate:MainController
    var connection:Connection?
    
    var chatName:String = ""
    
    var sender:[Sender]
    @Published var messages:[Message] = []
    
    init(delegate:MainController) {
        self.delegate = delegate
        sender = [Sender(name:"server", color:.gray), Sender(name:"You", color:.green)]
        //socket = Socket(ip,port,.utf8)
        //socket.stringHandler = callback
    }
    
    func signOut() {
        newMessage(content: "You left the chat.", name: "server")
        delegate.disconnect()
    }
    
    func sendMessage(message:String) {
        if message == "" {
            return
        }
        connection!.send(message: message)
        newMessage(content: message, name: "You")
    }
    
    func receiveMessage(content:String, ip:String) {
        let m = content.split(separator: ":")
        
        if (m.count != 3) {
            return
        }
        
        let message = String(m.last!)
        
        newMessage(content: message, name: String(m[0]))
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
            print("Already known sender: ", name)
            messages.append(Message(sender!, message: content))
            return
        }
        
        
        print("Not known sender: ", name)
        
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
        
        sender = Sender(name: name, color: color)
        self.sender.append(sender!)
        messages.append(Message(sender!, message: content))
    }
    
    func clear() {
        messages.removeAll()
    }
}
