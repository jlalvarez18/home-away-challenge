//
//  EventDetailsVC.swift
//  Home Away Challenge
//
//  Created by Juan Alvarez on 11/20/18.
//  Copyright © 2018 Juan Alvarez. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol EventObjectType {
    var title: String { get }
    var eventId: String { get }
    var location: String { get }
    var imageUrlString: String? { get }
    var datetimeLocal: Date? { get }
}

class EventDetailsVC: ASViewController<EventDetailsNode> {
    
    private var event: EventObjectType?
    
    init(event: EventObjectType) {
        self.event = event
        
        let node = EventDetailsNode(event: event)
        
        super.init(node: node)
        
        self.title = event.title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
