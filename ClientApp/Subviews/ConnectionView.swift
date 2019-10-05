//
//  SwiftUIView.swift
//  ClientApp
//
//  Created by Tristan Ratz on 03.10.19.
//  Copyright © 2019 Tristan Ratz. All rights reserved.
//

import SwiftUI

struct ConnectionView: View {
    @State var ip:String = ""
    @State var port:Int? = 8000
    @State var username:String = ""
    @State var emptyFields:Bool = false
    
    @EnvironmentObject private var connection:Connection
    
    var body: some View {
        VStack(alignment:.leading) {
            Text("Connect to \nServer")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 50)
                .padding(.top, 50)
            VStack(alignment:.leading) {
                Text("IP Adress").bold()
                TextField("IP Adress", text: $ip)
                    .padding(.all, 10)
                    .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 0.5))
                    .cornerRadius(5)
                    .keyboardType(.numbersAndPunctuation)
                    .disableAutocorrection(true)
                Text("Port").bold().padding(.top, 20)
                TextField("Port", value: $port, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .padding(.all, 10)
                    //.background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0))
                    .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 0.5))
                    .cornerRadius(5)
                    .padding(.bottom, 20)
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
                .alert(isPresented: $connection.failed, content: {
                    Alert(title: Text("Connection error"), message: Text("Failed to connect to server."), dismissButton: .default(Text("OK")))
                })
                .alert(isPresented: $emptyFields, content: {
                    Alert(title: Text("Empty Fields"), message: Text("Please enter IP and Port"), dismissButton: .default(Text("OK")))
                })
            }
            Spacer()
        }.padding(30)
            //.sheet(isPresented: Binding(get:{self.connection.connected}, set:{(newValue) in self.connection.connected=newValue}), content: Modal())
    }
    
    func connect() {
        if self.ip == "" || self.port == nil || self.port == 0 {
            self.emptyFields = true
            return
        }
        connection.connect(ip: self.ip, port: self.port!)
    }
}


/**
 Our Modal which will pop up when user connects
 */
struct Modal : View {
    @State var username:String = ""
    @State var emptyField:Bool = false
    
    @EnvironmentObject var connection:Connection
    
    var body : some View {
        VStack(alignment: .leading) {
            Text("Choose Name")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.trailing)
            Text("Username")
                .bold()
                .padding(.top, 20)
            TextField("Username", text: $username)
                .padding(.all, 10)
                .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 0.5))
                .cornerRadius(5)
                .padding(.bottom, 20)
                .disableAutocorrection(true)
            Button(action: {
                if self.username == "" {
                    self.emptyField = true
                } else {
                    self.connection.login(name: self.username)
                }
            }) {
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
            .alert(isPresented: $emptyField, content: {
                Alert(title: Text("Empty Field"), message: Text("Please enter Name"), dismissButton: .default(Text("OK")))
            })
        }.padding(30)
            .padding(.bottom, 80)
    }
}


struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView().environmentObject(Connection(delegate:MainController()))
    }
}
