//
//  FavoritesStore.swift
//  Home Away Challenge
//
//  Created by Juan Alvarez on 11/20/18.
//  Copyright © 2018 Juan Alvarez. All rights reserved.
//

import Foundation
import RealmSwift

class Favorite: Object {
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

class FavoritesStore {
    typealias EventId = String

    struct ObserverToken: Hashable {
        fileprivate let id = UUID()
        fileprivate let eventId: EventId
        fileprivate let block: ObserverBlock
        fileprivate let queue: DispatchQueue
        
        var hashValue: Int {
            return id.hashValue
        }

        fileprivate init(eventId: EventId, queue: DispatchQueue, block: @escaping ObserverBlock) {
            self.eventId = eventId
            self.queue = queue
            self.block = block
        }

        static func == (lhs: FavoritesStore.ObserverToken, rhs: FavoritesStore.ObserverToken) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    typealias ObserverBlock = (Bool) -> Void
    
    private static let shared = FavoritesStore()
    
    private static var realm: Realm {
        return try! Realm()
    }
    
    private var eventObservers: [EventId: Set<ObserverToken>] = [:]
    
    private init() {}
    
    static func allFavorites() -> Results<Favorite> {
        let objects = self.realm.objects(Favorite.self)
        return objects
    }
    
    static func isFavorite(event: Event) -> Bool {
        let fav = self.realm.object(ofType: Favorite.self, forPrimaryKey: event.idString)
        
        return fav != nil
    }
    
    static func favorite(event: Event) throws {
        try self.realm.write {
            let fav = Favorite()
            fav.datetimeLocal = event.datetimeLocal
            fav.eventId = event.idString
            fav.location = event.venue.displayLocation
            fav.imageUrlString = event.performers.first?.image?.absoluteString
            
            self.realm.add(fav, update: true)
        }
        
        notifyObservers(eventId: event.idString, value: true)
    }
    
    static func unfavorite(event: Event) throws {
        guard let fav = self.realm.object(ofType: Favorite.self, forPrimaryKey: event.idString) else {
            return
        }
        
        try self.realm.write {
            self.realm.delete(fav)
        }
        
        notifyObservers(eventId: event.idString, value: false)
    }
    
    
    static func observe(event: Event, queue: DispatchQueue = .main, block: @escaping ObserverBlock) -> ObserverToken {
        let token = ObserverToken(eventId: event.idString, queue: queue, block: block)

        var contexts = self.shared.eventObservers[event.idString] ?? []
        contexts.insert(token)

        self.shared.eventObservers[event.idString] = contexts

        return token
    }
    
    static func removeObserver(token: ObserverToken) {
        guard var tokens = self.shared.eventObservers[token.eventId] else {
            return
        }
        
        tokens.remove(token)
        
        self.shared.eventObservers[token.eventId] = tokens
    }
}

private extension FavoritesStore {
    
    static func notifyObservers(eventId: EventId, value: Bool) {
        guard let tokens = self.shared.eventObservers[eventId] else {
            return
        }
        
        for token in tokens {
            token.queue.async {
                token.block(value)
            }
        }
    }
}
