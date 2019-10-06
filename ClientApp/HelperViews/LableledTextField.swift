//
//  TextField.swift
//  ClientApp
//
//  Created by Tristan Ratz on 05.10.19.
//  Copyright © 2019 Tristan Ratz. All rights reserved.
//

import SwiftUI

struct LabeledTextField: View {
    @State var label:String
    @Binding var value:String
    @State var showLabel:Bool = true
    @State var keyboardType:UIKeyboardType = .default
    @State var onCommit:()->Void = {}
    @State var editing:Bool = false
    @State var disableAutocorrection:Bool = false
    
    var body: some View {
        VStack(alignment:.leading) {
            if showLabel {
                Text(label).bold().padding(.top, 20)
            }
            TextField(label, text: $value, onEditingChanged: {e in self.editing = e}, onCommit: onCommit)
                .keyboardType(keyboardType)
                .padding(.all, 10)
                .background(Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 0.5))
                .cornerRadius(5)
                .disableAutocorrection(disableAutocorrection)
        }
    }
}

struct TextField_Previews: PreviewProvider {
    static var previews: some View {
        LabeledTextField(label:"Port", value: Binding<String>(get: {return ""}
, set: {_ in }))
    }
}
