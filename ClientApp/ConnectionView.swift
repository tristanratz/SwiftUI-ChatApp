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
                }.sheet(isPresented: $connection.connected, content: { Modal() })
                .padding(.vertical, 10.0)
                .background(Color.green)
                .cornerRadius(5.0)
                .alert(isPresented: $connection.failed, content: {
                    Alert(title: Text("Connection error"), message: Text("Failed to connect to server."), dismissButton: .default(Text("Ok")))
                })
            }
            Spacer()
        }.padding(30)
            //.sheet(isPresented: Binding(get:{self.connection.connected}, set:{(newValue) in self.connection.connected=newValue}), content: Modal())
    }
    
    func connect() {
        print(self.port == nil)
        if self.ip == "" || self.port == nil || self.port == 0 {
            
            return
        }
        print("Hello")
        connection.connect(ip: self.ip, port: self.port!)
    }
}


/**
 Our Modal which will pop up when user connects
 */
struct Modal : View {
    @State var username:String = ""
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
            Button(action: { }) {
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
        }.padding(10)
            .padding(.bottom, 80)
    }
}


struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectionView().environmentObject(Connection())
    }
}
