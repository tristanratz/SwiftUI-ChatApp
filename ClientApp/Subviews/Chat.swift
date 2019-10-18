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

    let name: String
    let color: Color

    init(name: String, color: Color) {
        self.name = name
        self.color = color
    }
}

class Message: Identifiable {

    let id = UUID()
    let sender: Sender
    var message: String

    init(_ sender: Sender, message: String) {
        self.sender = sender
        self.message = message

    }
}

class Chat: ObservableObject {

    var controller: MainController
    var connection: Connection?

    var chatName: String = ""

    var sender: [Sender]
    @Published var messages: [Message] = []
    @Published var keyboardHeight: CGFloat = 0

    init(delegate: MainController) {
        self.controller = delegate
        sender = [Sender(name: "server", color: .gray), Sender(name: "You", color: .green)]

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }

    func signOut() {
        newMessage(content: "You left the chat.", name: "server")
        controller.disconnect()
    }

    func sendMessage(message: String) {
        if message == "" {
            return
        }
        connection!.send(message: message)
        newMessage(content: message, name: "You")
    }

    func receiveMessage(content: String, ip: String) {
        let messageParts = content.split(separator: ":")
        
        if messageParts.count != 3 {
            return
        }
        
        let message = String(messageParts.last!)
        
        newMessage(content: message, name: String(messageParts[0]))
    }

    func newMessage(content: String, name: String) {
        for possibleSender in self.sender {
            if possibleSender.name == name {
                print("Already known sender: ", name)
                messages.append(Message(possibleSender, message: content))
                return
            }
        }
        
        print("Not known sender: ", name)
        
        let color: Color
        switch Int.random(in: 0...5) {
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
        default:
            color = Color.white
        }

        let sender = Sender(name: name, color: color)
        self.sender.append(sender)
        messages.append(Message(sender, message: content))
    }

    func clear() {
        messages.removeAll()
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
    }
}
