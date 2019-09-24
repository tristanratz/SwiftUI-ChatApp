//
//  ContentView.swift
//  ClientApp
//
//  Created by Tristan Ratz on 19.09.19.
//  Copyright © 2019 Tristan Ratz. All rights reserved.
//

import SwiftUI



struct ContentView: View {
    @State private var writing:Bool = false
    
    @State private var inputText:String = ""
    @EnvironmentObject private var chat:Chat
    //@State private var messages:[Message] = [Message(Sender(name: "TestSender", color: .green), message: "Hello World! This is a long test messsage, which hopefully will exceed one line")]
    
    var body: some View {
        NavigationView {
            VStack {
                List(self.chat.messages) { el in
                    HStack {
                        Text(el.sender.name)
                            .foregroundColor(el.sender.color)
                            .padding(4)
                            .font(.footnote)
                        Text(el.message)
                    }
                }
                ZStack {
                    HStack {
                        TextField("Text", text: $inputText, onEditingChanged: { edit in
                            self.writing = edit
                        }).textFieldStyle(RoundedBorderTextFieldStyle())
                        Button(action:send){
                            Text("Send")
                        }
                    }.padding()
                }.offset(y:(writing ? -300 : 0))
            }
        .navigationBarTitle(Text("Chat"))
            .navigationBarItems(leading: Button(action:chat.signOut){
            Text("Logout")
        })
        }
    }
    
    private func send() {
        self.chat.sendMessage(message: self.inputText)
        self.inputText = ""
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class StringID : Identifiable {
    
    var id = UUID()
    var string:String
    
    init(_ string:String) {
        self.string = string
    }
    
}
