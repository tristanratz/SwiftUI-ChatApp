//
//  Decoder.swift
//  ClientApp
//
//  Created by Tristan Ratz on 04.10.19.
//  Copyright © 2019 Tristan Ratz. All rights reserved.
//

import Foundation

protocol ChatProtocols {
    func decode(dictionary: Dictionary<String, String>)
    func encode(dictionary: Dictionary<String, String>)
}
