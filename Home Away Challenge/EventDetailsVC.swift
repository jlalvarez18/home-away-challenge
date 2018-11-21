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
    
    let event: Event
    
    init(event: Event) {
        self.event = event
        
        let node = EventDetailsNode(event: event)
        
        super.init(node: node)
        
        self.title = self.event.title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
