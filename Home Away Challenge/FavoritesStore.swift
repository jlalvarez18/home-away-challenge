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
    
    typealias EventFavoriteObserver = (Bool) -> Void
    
    private static let shared = FavoritesStore()
    
    private var observers: [String: ObservationToken] = [:]
    
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
    
    static func observe(event: Event, block: @escaping EventFavoriteObserver) -> String {
        let token = UUID().uuidString
        
        let observerToken = self.shared.storage.addObserver(shared, forKey: event.idString) { (observer, storage, change) in
            switch change {
            case .edit(_, _):
                block(true)
            case .remove:
                block(false)
            }
        }
        
        self.shared.observers[token] = observerToken
        
        return token
    }
    
    static func removeObserver(token: String) {
        guard let observerToken = self.shared.observers[token] else {
            return
        }
        
        observerToken.cancel()
    }
}
