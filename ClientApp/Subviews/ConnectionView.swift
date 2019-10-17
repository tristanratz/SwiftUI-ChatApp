//
//  SwiftUIView.swift
//  ClientApp
//
//  Created by Tristan Ratz on 03.10.19.
//  Copyright © 2019 Tristan Ratz. All rights reserved.
//

import SwiftUI

struct ConnectionView: View {
    @State var ip: String = ""
    @State var port: String = ""
    @State var username: String = ""
    @State var emptyFields: Bool = false
    @State var writing: Bool = false

    @EnvironmentObject private var connection: Connection

    var body: some View {
        VStack(alignment: .leading) {
            Text("Connect to \nServer")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 50)
                .padding(.top, 50)
            VStack(alignment:.leading) {
                LabeledTextField(label: "IP Adress",
                                 value: $ip,
                                 keyboardType: .numbersAndPunctuation,
                                 onEditingChanged: { editing in
                                    withAnimation {
                                        self.writing = editing
                                    }
                    }, disableAutocorrection: true
                )
                LabeledTextField(label: "Port",
                                 value: $port,
                                 keyboardType: .numberPad,
                                 onEditingChanged: { editing in
                                    withAnimation {
                                        self.writing = editing
                                    }
                    }, disableAutocorrection: true
                ).padding(.bottom,20)
                    .alert(isPresented: $emptyFields, content: {
                        Alert(title: Text("Empty Fields"),
                              message: Text("Please enter IP and Port"),
                              dismissButton: .default(Text("OK"))
                        )
                    }
                )
                Spacer()
                Button(action: { self.connect() }) {
                    HStack {
                        Spacer()
                        Text("Connect to Server")
                            .bold()
                            .foregroundColor(Color.white)
                        Spacer()
                    }
                }.sheet(isPresented: $connection.askForName, content: { Modal().environmentObject(self.connection) })
                    .padding(.vertical, 10.0)
                    .background(Color.green)
                    .cornerRadius(5.0)
                    .alert(isPresented: $connection.failedToConnect, content: {
                        Alert(title: Text("Connection error"),
                              message: Text("Failed to connect to server."),
                              dismissButton: .default(Text("OK"))
                        )
                    }
                )
            }
            Spacer().frame(height: writing ? (connection.keyboardHeight <= 30 ? 30 :  connection.keyboardHeight) : 30)
        }.padding(30)
    }

    func connect() {
        if self.ip == "" || self.port == "" {
            self.emptyFields = true
            return
        }
        
        if Int(self.port) == nil {
            self.connection.toggleFailed()
            return
        }
        
        connection.connect(ip: self.ip, port: Int(self.port)!)
    }
}


/**
 Our Modal which will pop up when user connects
 */
struct Modal: View {

    @State var username: String = ""
    @State var emptyField: Bool = false

    @State var writing: Bool = false

    @EnvironmentObject var connection: Connection

    var body : some View {
        VStack(alignment: .leading) {
            Text("Choose Name")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.trailing)
            LabeledTextField(label: "Username",
                             value: $username,
                             onCommit: self.connect,
                             onEditingChanged: { editing in
                                withAnimation {
                                    self.writing = editing
                                }
                }, disableAutocorrection: true
            ).padding(.bottom, 10)
            .alert(isPresented: $emptyField, content: {
                Alert(title: Text("Empty Field"),
                      message: Text("Please enter Name"),
                      dismissButton: .default(Text("OK"))
                )
            })
            Button(action: self.connect) {
                HStack {
                    Spacer()
                    Text("Join as \(self.username)!")
                        .bold()
                        .foregroundColor(Color.white)
                    Spacer()
                }
            }.padding(.vertical, 10.0)
            .background(Color.green)
            .cornerRadius(5.0)
            .alert(isPresented: $connection.userNameRejected, content: {
                Alert(title: Text("Name Rejected"),
                      message: Text("The server rejected your name. Please enter onther name."),
                      dismissButton: .default(Text("OK"))
                )
            })
            Spacer().frame(height: writing ? (connection.keyboardHeight <= 30 ? 30 :  connection.keyboardHeight) : 30)
        }.padding(30)
    }

    func connect() {
        if self.username == "" {
            self.emptyField = true
        } else {
            self.connection.login(name: self.username)
        }
    }
}


struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView().environmentObject(Connection(delegate:MainController()))
    }
}
