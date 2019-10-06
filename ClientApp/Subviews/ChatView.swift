//
//  ContentView.swift
//  ClientApp
//
//  Created by Tristan Ratz on 19.09.19.
//  Copyright © 2019 Tristan Ratz. All rights reserved.
//

import SwiftUI



struct ChatView: View {
    @State private var writing:Bool = false
    
    @State private var inputText:String = ""
    @EnvironmentObject private var chat:Chat
    
    var body: some View {
        VStack(alignment:.leading) {
            HStack(alignment:.top) {
                Text("Chat")
                    .font(.title)
                    .bold()
                Spacer()
                Button(action:chat.signOut){
                    Text("Logout")
                }.frame(alignment:.trailing)
            }.padding(.top,30)
                .padding(.leading,30)
                .padding(.trailing,30)
            .padding(.bottom,0)
            ScrollView {
                ForEach(self.chat.messages) { el in
                    if el.sender.name == "You" {
                        MessageView(message:el.message, sender:el.sender.name, alignment:.trailing, accentColor:el.sender.color, messageColor: Color(red: 221.0/255.0, green: 252.0/255.0, blue: 212.0/255.0, opacity: 0.5))
                    } else if el.sender.name == "server" {
                        MessageView(message:el.message, sender:"", alignment:.center, accentColor:.gray)
                    }
                    else {
                        MessageView(message:el.message, sender:el.sender.name, accentColor:el.sender.color)
                    }
                }
            } //.content.offset(y:self.chat.messages.count*20)
            HStack {
                LabeledTextField(label:"Text", value:$inputText, showLabel:false, onCommit: send, onEditingChanged:{editing in
                    withAnimation {
                        self.writing=editing
                    }
                })
                Button(action:send){
                    Text("Send")
                }
            }.padding(.leading, 30).padding(.trailing, 30)
            Spacer().frame(height: writing ? chat.keyboardHeight : 30)
        }
    }
    
    private func send() {
        self.chat.sendMessage(message: self.inputText)
        self.inputText = ""
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView().environmentObject(Chat(delegate:MainController()))
    }
}

class StringID : Identifiable {
    
    var id = UUID()
    var string:String
    
    init(_ string:String) {
        self.string = string
    }
    
}
