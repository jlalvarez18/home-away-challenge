//
//  SeatGeekService.swift
//  Home Away Challenge
//
//  Created by Juan Alvarez on 11/20/18.
//  Copyright © 2018 Juan Alvarez. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

class SeatGeekService {
    
    struct ClientConfig {
        static let id = "MTQwMjAyNTl8MTU0Mjc1MTA0NC44Nw"
        static let secret = "6589a6249b5515d86e4954bd3a730be8c284247b0dd3239ab49d9a0f0836dc8b"
    }
    
    enum Router: Alamofire.URLRequestConvertible {
        case getEvents(query: String?)
        case getEvent(id: String)
        case getEventsLocal(postalCode: String)
        case getEventsFor(venues: [Venue])
        
        case getVenues(postalCode: String)
        
        static let baseUrlString = "https://api.seatgeek.com/2"
        
        private func starterParameters() -> Parameters {
            return ["client_id": ClientConfig.id, "client_secret": ClientConfig.secret]
        }
        
        func asURLRequest() throws -> URLRequest {
            let result: (path: String, parameters: Parameters) = {
                var params = starterParameters()
                
                switch self {
                case .getEvents(let q):
                    if let query = q {
                        params["q"] = query
                    }
                    
                    return ("/events", params)
                    
                case .getEvent(let eventId):
                    return ("/events/\(eventId)", params)
                    
                case .getEventsLocal(let postalCode):
                    params["postal_code"] = postalCode
                    params["sort"] = "score.desc"
                    
                    return ("/events", params)
                    
                case .getEventsFor(let venues):
                    let ids = venues.map { "\($0.id)" }
                    
                    params["venue.id"] = ids.joined(separator: ",")
                    params["sort"] = "score.desc"
                    
                    return ("/events", params)
                    
                case .getVenues(let postalCode):
                    params["postal_code"] = postalCode
                    params["sort"] = "score.desc"
                    
                    return ("/venues", params)
                }
            }()
            
            var url = try Router.baseUrlString.asURL()
            url.appendPathComponent(result.path)
            
            let request = URLRequest(url: url)
            
            return try URLEncoding.default.encode(request, with: result.parameters)
        }
    }
    
    static let manager: SessionManager = {
        let config = URLSessionConfiguration.default
        let session = Alamofire.SessionManager(configuration: config)
        
        return session
    }()
    
    static let decoder: JSONDecoder = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        return decoder
    }()
    
    static func getEvents(query: String) -> (request: DataRequest, promise: Promise<[Event]>) {
        return performEventRequest(.getEvents(query: query))
    }
    
    static func getEventsFor(venues: [Venue])  -> (request: DataRequest, promise: Promise<[Event]>) {
        return performEventRequest(.getEventsFor(venues: venues))
    }
    
    static func getLocalEvents(postalCode: String) -> (request: DataRequest, promise: Promise<[Event]>) {
        return performEventRequest(.getEventsLocal(postalCode: postalCode))
    }
    
    static func getVenues(postalCode: String) -> (request: DataRequest, promise: Promise<[Venue]>) {
        return performVenueRequest(.getVenues(postalCode: postalCode))
    }
}

private extension SeatGeekService {
    
    static func performEventRequest(_ router: Router) -> (request: DataRequest, promise: Promise<[Event]>) {
        struct Result: Decodable {
            let events: [Event]
        }
        
        let request = manager.request(router)
        
        let promise = request
            .responseDecodable(Result.self, queue: nil, decoder: decoder)
            .map { $0.events }
        
        return (request: request, promise: promise)
    }
    
    static func performVenueRequest(_ router: Router) -> (request: DataRequest, promise: Promise<[Venue]>) {
        struct Result: Decodable {
            let venues: [Venue]
        }
        
        let request = manager.request(router)
        
        let promise = request
            .responseDecodable(Result.self, queue: nil, decoder: decoder)
            .map { $0.venues }
        
        return (request: request, promise: promise)
    }
}
