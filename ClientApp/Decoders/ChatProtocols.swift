//
//  Decoder.swift
//  ClientApp
//
//  Created by Tristan Ratz on 04.10.19.
//  Copyright © 2019 Tristan Ratz. All rights reserved.
//

import Foundation

protocol ChatProtocols {
    func decode(dictionary: [String: String])
    func encode(dictionary: [String: String])
}
