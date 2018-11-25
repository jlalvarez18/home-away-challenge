//
//  EventDetailsVC.swift
//  Home Away Challenge
//
//  Created by Juan Alvarez on 11/20/18.
//  Copyright © 2018 Juan Alvarez. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class EventDetailsVC: ASViewController<EventDetailsNode> {
    
    private let event: EventObjectType
    
    init(event: EventObjectType) {
        self.event = event
        
        let node = EventDetailsNode(event: event)
        
        super.init(node: node)
        
        self.title = event.title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
}
