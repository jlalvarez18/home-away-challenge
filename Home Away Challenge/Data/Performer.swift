//
//  Performer.swift
//  Home Away Challenge
//
//  Created by Juan Alvarez on 11/25/18.
//  Copyright © 2018 Juan Alvarez. All rights reserved.
//

import Foundation

struct Performer: Decodable {
    let name: String
    let shortName: String?
    let url: URL
    let image: URL?
    let images: [String: URL]?
    let id: Int
    let links: [Link]?
    
    struct Link: Decodable {
        let id: String?
        let provider: String
        let url: URL
    }
}
