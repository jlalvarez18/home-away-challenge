//
//  Venue.swift
//  Home Away Challenge
//
//  Created by Juan Alvarez on 11/23/18.
//  Copyright © 2018 Juan Alvarez. All rights reserved.
//

import Foundation

struct Venue: Decodable {
    let id: Int
    let city: String?
    let state: String?
    let name: String
    
    let displayLocation: String
}
