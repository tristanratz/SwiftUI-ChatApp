//
//  Connection.swift
//  ClientApp
//
//  Created by Tristan Ratz on 03.10.19.
//  Copyright © 2019 Tristan Ratz. All rights reserved.
//

import SwiftUI
import Combine

class Connection: ObservableObject {
    @Published var askForName:Bool = false
    @Published var failed:Bool = false
    
    var connected:Bool = false
    var name:String
    
    var delegate:MainController
    var socket:Socket?
    
    init(delegate:MainController) {
        self.delegate = delegate
        self.name = ""
    }
    
    func connect(ip:String, port:Int) {
        if socket != nil {
            socket!.destroySession()
        }
        self.socket = Socket(ip, port, .utf8)
        self.socket!.connectionCallback = didConnect
        self.socket!.connect()
    }
    
    /**
     Called when socket is open to server
     */
    func didConnect(_ success:Bool) {
        if success {
            self.connected = true
            self.askForName = true
        } else {
            self.failed = true
        }
    }
    
    func login(name:String) {
        self.name = name
        self.askForName = false
        socket!.stringHandler = loginCallback
        socket!.sendText(text: name)
    }
    
    func loginCallback(reply:String, ip:String) {
        print("Logincallback: ",reply)
        if reply == "server:msg:Welcome, \(self.name)!" {
            delegate.connected()
        } else if reply == "server:inf:name" {
            self.askForName = true
        }
    }
    
    func send(message:String) {
        socket!.sendText(text: self.name+":msg:"+message)
    }
    
    func disconnect() {
        self.connected = false
        self.socket!.destroySession()
        self.name = ""
    }
}
