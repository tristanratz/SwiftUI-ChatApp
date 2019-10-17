//
//  MainController.swift
//  ClientApp
//
//  Created by Tristan Ratz on 04.10.19.
//  Copyright © 2019 Tristan Ratz. All rights reserved.
//

import Combine
import SwiftUI

class MainController : ObservableObject {

    @Published var state: SubviewState = .login

    var chat: Chat?
    var connection: Connection?

    init() {
        chat = Chat(delegate: self)
        connection = Connection(delegate: self)
    }

    func connected() {
        chat!.connection = self.connection
        self.connection!.socket!.stringHandler = chat!.receiveMessage
        withAnimation {
            state = .chat
        }
    }

    func disconnect() {
        chat!.clear()
        connection!.disconnect()
        state = .login
    }

}
