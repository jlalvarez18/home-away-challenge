//
//  FavoritesStore.swift
//  Home Away Challenge
//
//  Created by Juan Alvarez on 11/20/18.
//  Copyright © 2018 Juan Alvarez. All rights reserved.
//

import Foundation
import Cache

class FavoritesStore {
    
    private let memoryStorage: MemoryStorage<Bool> = {
        let memoryConfig = MemoryConfig(expiry: .never, countLimit: 50, totalCostLimit: 50)
        let storage = MemoryStorage<Bool>(config: memoryConfig)
        
        return storage
    }()
    
    private let diskStorage: DiskStorage<Bool> = {
        let fm = FileManager.default
        let url = try! fm.url(for: .documentDirectory,
                              in: .userDomainMask,
                              appropriateFor: nil,
                              create: true)
        
        let path = url.appendingPathComponent("MyCache").path
        
        try? fm.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        
        let diskConfig = DiskConfig(name: "Favorites", protectionType: .complete)
        
        let transformer = TransformerFactory.forCodable(ofType: Bool.self)
        
        let storage = DiskStorage<Bool>(config: diskConfig, path: path, transformer: transformer)
        
        return storage
    }()
    
    private let storage: HybridStorage<Bool>
    
    private static let shared = FavoritesStore()
    
    typealias EventId = String
    typealias ObserverBlock = (Bool) -> Void
    
    struct StoreToken: Equatable {
        fileprivate let id = UUID()
        fileprivate let eventId: EventId
        fileprivate let observerToken: ObservationToken
        fileprivate let block: ObserverBlock
        
        fileprivate init(eventId: EventId, token: ObservationToken, block: @escaping ObserverBlock) {
            self.eventId = eventId
            self.observerToken = token
            self.block = block
        }
        
        static func == (lhs: FavoritesStore.StoreToken, rhs: FavoritesStore.StoreToken) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    private var observers: [EventId: [StoreToken]] = [:]
    
    private init() {
        self.storage = HybridStorage(memoryStorage: self.memoryStorage, diskStorage: self.diskStorage)
    }
    
    static func isFavorite(event: Event) -> Bool {
        do {
            return try self.shared.storage.existsObject(forKey: event.idString)
        } catch {
            print(error)
            
            return false
        }
    }
    
    static func favorite(event: Event) {
        do {
            try self.shared.storage.setObject(true, forKey: event.idString)
        } catch {
            print(error)
        }
    }
    
    static func unfavorite(event: Event) {
        do {
            try self.shared.storage.removeObject(forKey: event.idString)
        } catch {
            print(error)
        }
    }
    
    static func observe(event: Event, block: @escaping ObserverBlock) -> StoreToken {
        let token = self.shared.storage.addObserver(shared, forKey: event.idString) { (observer, storage, change) in
            guard let tokens = self.shared.observers[event.idString] else {
                return
            }

            switch change {
            case .edit(_, _):
                for t in tokens {
                    t.block(true)
                }
            case .remove:
                for t in tokens {
                    t.block(false)
                }
            }
        }
        
        let storeToken = StoreToken(eventId: event.idString, token: token, block: block)
        
        var contexts = self.shared.observers[event.idString] ?? []
        contexts.append(storeToken)
        
        self.shared.observers[event.idString] = contexts
        
        return storeToken
    }
    
    static func removeObserver(token: StoreToken) {
        token.observerToken.cancel()
        
        guard var tokens = self.shared.observers[token.eventId] else {
            return
        }
        
        guard let index = tokens.firstIndex(of: token) else {
            return
        }
        
        tokens.remove(at: index)
        
        self.shared.observers[token.eventId] = tokens
    }
}
