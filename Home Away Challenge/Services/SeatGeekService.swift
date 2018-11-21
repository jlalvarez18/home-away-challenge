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
    
    static func getEvents(query: String) -> Promise<[Event]> {
        struct Result: Decodable {
            let events: [Event]
        }
        
        return manager
            .request(Router.getEvents(query: query))
            .responseDecodable(Result.self, queue: nil, decoder: decoder)
            .map { $0.events }
    }
}
