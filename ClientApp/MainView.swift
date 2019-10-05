//
//  MotherView.swift
//  ClientApp
//
//  Created by Tristan Ratz on 04.10.19.
//  Copyright © 2019 Tristan Ratz. All rights reserved.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject var mainController:MainController
    
    var body: some View {
        VStack(alignment: .leading) {
            if mainController.state == .Login {
                ConnectionView().environmentObject(mainController.connection!)
            } else {
                ChatView().environmentObject(mainController.chat!)
            }
        }
    }
}

struct MotherView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

enum SubviewState {
    case Login
    case Chat
}
