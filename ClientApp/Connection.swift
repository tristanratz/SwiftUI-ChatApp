//
//  Connection.swift
//  ClientApp
//
//  Created by Tristan Ratz on 03.10.19.
//  Copyright © 2019 Tristan Ratz. All rights reserved.
//

import SwiftUI
import Combine

class Connection : ObservableObject {
    @Published var connected:Bool = false
    @Published var failed:Bool = false
    var socket:Socket?
    
    func connect(ip:String, port:Int) {
        if socket != nil {
            socket!.destroySession()
        }
        self.socket = Socket(ip, port, .utf8)
        self.socket!.connectionCallback = didConnect
        self.socket!.connect()
    }
    
    func didConnect(_ c:Bool) {
        if c {
            self.connected = true
        } else {
            self.failed = true
        }
    }
}
