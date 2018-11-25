//
//  Event.swift
//  Home Away Challenge
//
//  Created by Juan Alvarez on 11/20/18.
//  Copyright © 2018 Juan Alvarez. All rights reserved.
//

import Foundation

protocol EventObjectType {
    var title: String { get }
    var eventId: String { get }
    var location: String { get }
    var imageUrlString: String? { get }
    var datetimeLocal: Date? { get }
}

struct Event: Decodable, Equatable, EventObjectType {
    let title: String
    let url: URL
    
    let datetimeLocal: Date?
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
    
    var eventId: String {
        return "\(self.id)"
    }
    
    var location: String {
        return self.venue.displayLocation
    }
    
    var imageUrlString: String? {
        return self.performers.first?.image?.absoluteString
    }
    
    static func == (lhs: Event, rhs: Event) -> Bool {
        return lhs.id == rhs.id
    }
}
