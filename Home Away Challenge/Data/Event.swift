//
//  Event.swift
//  Home Away Challenge
//
//  Created by Juan Alvarez on 11/20/18.
//  Copyright © 2018 Juan Alvarez. All rights reserved.
//

import Foundation

struct Event: Decodable, Equatable {
    let title: String
    let url: URL
    
    let datetimeLocal: Date
    let datetimeUtc: Date
    
    let announceDate: Date
    
    let timeTbd: Bool
    let dateTbd: Bool
    
    let performers: [Performer]
    let venue: Venue
    
    let shortTitle: String
    let score: Double
    
    let type: String
    let id: Int
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Performer: Decodable {
    let name: String
    let shortName: String?
    let url: URL
    let image: URL?
    let id: Int
    let links: [Link]?
    
    struct Link: Decodable {
        let id: String?
        let provider: String
        let url: URL
    }
}

struct Venue: Decodable {
    let city: String?
    let state: String?
    let name: String
    
    let displayLocation: String
}
