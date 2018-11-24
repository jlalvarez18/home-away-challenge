//
//  FavoritesStore.swift
//  Home Away Challenge
//
//  Created by Juan Alvarez on 11/20/18.
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
    
    static func isFavorite(event: EventObjectType) -> Bool {
        let fav = self.realm.object(ofType: Favorite.self, forPrimaryKey: event.eventId)
        
        return fav != nil
    }
    
    static func favorite(event: EventObjectType) throws {
        try self.realm.write {
            let fav = Favorite()
            fav.datetimeLocal = event.datetimeLocal
            fav.title = event.title
            fav.eventId = event.eventId
            fav.location = event.location
            fav.imageUrlString = event.imageUrlString
            
            self.realm.add(fav, update: true)
        }
        
        notifyObservers(eventId: event.eventId, value: true)
    }
    
    static func unfavorite(event: EventObjectType) throws {
        guard let fav = self.realm.object(ofType: Favorite.self, forPrimaryKey: event.eventId) else {
            return
        }
        
        let id = event.eventId
        
        try self.realm.write {
            self.realm.delete(fav)
        }
        
        notifyObservers(eventId: id, value: false)
    }
    
    
    static func observe(event: EventObjectType, queue: DispatchQueue = .main, block: @escaping ObserverBlock) -> ObserverToken {
        let token = ObserverToken(eventId: event.eventId, queue: queue, block: block)

        var contexts = self.shared.eventObservers[event.eventId] ?? []
        contexts.insert(token)

        self.shared.eventObservers[event.eventId] = contexts

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
