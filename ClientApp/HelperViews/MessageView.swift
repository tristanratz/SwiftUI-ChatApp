//
//  MessageView.swift
//  ClientApp
//
//  Created by Tristan Ratz on 06.10.19.
//  Copyright © 2019 Tristan Ratz. All rights reserved.
//

import SwiftUI

struct MessageView: View {
    @State var message: String
    @State var sender: String
    var alignment: HorizontalAlignment = .leading
    @State var accentColor: Color = .gray
    @State var messageColor: Color = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 0.7)

    var body: some View {
        VStack(alignment: self.alignment) {
            HStack {
                if alignment == .trailing {
                    Spacer()
                }
                Text(sender.uppercased())
                    .foregroundColor(accentColor)
                    .font(.footnote)
                    .padding(.bottom, -7)
                if alignment == .leading {
                    Spacer()
                }
            }
            HStack {
                if alignment == .trailing || alignment == .center {
                    Spacer()
                }
                
                VStack(alignment: .leading) {
                    Text(message)
                        .padding(.all, 10)
                        .background(messageColor)
                        .font((alignment == .center) ? .footnote : .body)
                        .cornerRadius(5)
                }
                
                if alignment == .leading || alignment == .center {
                    Spacer()
                }
            }
        }.padding(.leading, 30)
        .padding(.trailing, 30)
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView(message: "Hello", sender: "Me")
    }
}
