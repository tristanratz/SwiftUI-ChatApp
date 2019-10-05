//
//  MainController.swift
//  ClientApp
//
//  Created by Tristan Ratz on 04.10.19.
//  Copyright © 2019 Tristan Ratz. All rights reserved.
//

import Foundation

class MainController : ObservableObject {
    
    @Published var state:SubviewState = .Login
    
    var chat:Chat?
    var connection:Connection?
    
    init() {
        chat = Chat(delegate:self)
        connection = Connection(delegate:self)
    }
    
    func connected() {
        print("CONNECTED")
        chat!.connection = self.connection
        self.connection!.socket!.stringHandler = chat!.receiveMessage
        state = .Chat
    }
    
    func disconnect() {
        chat!.clear()
        connection!.disconnect()
        state = .Login
    }
    
}
