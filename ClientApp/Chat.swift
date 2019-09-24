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
    
    var sender:[Sender]
    var messages:[Message] = []
    
    init(_ ip:String, port:Int) {
        sender = [Sender(name:"server", color:.gray)]
        socket = Socket(ip,port,.utf8)
        socket.stringHandler = callback
    }
    
    func signIn() {
        self.chatName = "Tristan"
        socket.sendText(text: chatName)
    }
    
    func signOut() {
        socket.destroySession()
        var server:Sender?
        for s in sender {
            if s.name == "Server" {
                server = s
                break
            }
        }
        messages.append(Message(server!, message: "You left the chat"))
    }
    
    func sendMessage(message:String) {
        if message == "" {
            return
        }
        socket.sendText(text: self.chatName+":msg:"+message)
        newMessage(content: message, name: "You")
    }
    
    func callback(content:String, ip:String) {
        let m = content.split(separator: ":")
        
        if (m.count != 3) {
            return
        }
        
        var message = String(m.last!)
        message = String(message.dropLast())
                
        if String(m.first!) == "server" && message == "name" {
            signIn()
            return
        }
        
        if String(m.first!) == "server" && message.contains("Welcome") {
            
        }

        
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
}
