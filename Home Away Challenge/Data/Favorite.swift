//
//  Favorite.swift
//  Home Away Challenge
//
//  Created by Juan Alvarez on 11/25/18.
//  Copyright © 2018 Juan Alvarez. All rights reserved.
//

import Foundation
import RealmSwift

class Favorite: Object, EventObjectType {
    @objc dynamic var eventId: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var location: String = ""
    @objc dynamic var imageUrlString: String?
    @objc dynamic var datetimeLocal: Date?
    @objc dynamic var createdAt: Date = Date()
    
    override static func primaryKey() -> String? {
        return "eventId"
    }
}
