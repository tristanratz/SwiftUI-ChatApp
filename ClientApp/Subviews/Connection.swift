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

    @Published var askForName: Bool = false
    @Published var failedToConnect: Bool = false

    @Published var userNameRejected: Bool = false

    @Published var emptyFields: Bool = false
    @Published var emptyNameField: Bool = false

    var connected: Bool = false
    var name: String

    var controller: MainController
    var socket: Socket?

    @Published var keyboardHeight: CGFloat = 0

    init(delegate: MainController) {
        self.controller = delegate
        self.name = ""
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }

    func connect(ip: String, port: Int) {
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
    func didConnect(_ success: Bool) {
        if success {
            self.connected = true
            self.askForName = true
        } else {
            print("Failed")
            self.failedToConnect = true
        }
    }

    func login(name: String) {
        self.name = name
        socket!.stringHandler = loginCallback
        socket!.sendText(text: name)
    }

    func loginCallback(reply: String, ip: String) {
        print("Logincallback: ", reply)
        if reply == "server:msg:Welcome, \(self.name)!" {
            self.askForName = false
            controller.connected()
        } else if reply == "server:inf:name" {
            self.askForName = true
            self.userNameRejected = true
        }
    }

    func send(message: String) {
        socket!.sendText(text: self.name + ":msg:" + message)
    }

    func disconnect() {
        self.connected = false
        self.socket!.destroySession()
        self.name = ""
    }

    func toggleFailed() {
        self.failedToConnect.toggle()
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                keyboardHeight = keyboardRectangle.height
        }
    }
}
