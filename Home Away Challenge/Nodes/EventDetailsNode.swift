//
//  EventDetailsNode.swift
//  Home Away Challenge
//
//  Created by Juan Alvarez on 11/21/18.
//  Copyright © 2018 Juan Alvarez. All rights reserved.
//

import Foundation
import AsyncDisplayKit

private struct Attributes {
    static let title: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline),
        NSAttributedString.Key.foregroundColor: UIColor.black
    ]
    
    static let subtitle: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body),
        NSAttributedString.Key.foregroundColor: UIColor.lightGray
    ]
}

class EventDetailsNode: ASDisplayNode {
    
    lazy var imageNode: ASNetworkImageNode = {
        let node = ASNetworkImageNode()
        node.cornerRadius = 9.0
        node.style.height = ASDimensionMake(200)
        node.style.width = ASDimensionMakeWithFraction(1.0)
        node.backgroundColor = UIColor.lightGray
        
        return node
    }()
    
    lazy var dateNode: ASTextNode = {
        let node = ASTextNode()
        
        return node
    }()
    
    lazy var locationNode: ASTextNode = {
        let node = ASTextNode()
        
        return node
    }()
    
    let headerNode: EventDetailsHeaderNode
    
    let event: EventObjectType
    
    init(event: EventObjectType) {
        self.event = event
        
        self.headerNode = EventDetailsHeaderNode(event: event)
        
        super.init()
        
        self.imageNode.url = URL(string: event.imageUrlString ?? "")
        self.dateNode.attributedText = {
            let dateString: String
            
            if let date = event.datetimeLocal {
                dateString = EventCellNode.dateFormatter.string(from: date)
            } else {
                dateString = "TBD"
            }
            
            return NSAttributedString(string: dateString, attributes: Attributes.subtitle)
        }()
        self.locationNode.attributedText = NSAttributedString(string: event.location, attributes: Attributes.subtitle)
        
        self.backgroundColor = UIColor.white
        
        self.automaticallyManagesSubnodes = true
        self.automaticallyRelayoutOnSafeAreaChanges = true
        self.insetsLayoutMarginsFromSafeArea = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let labelStack = ASStackLayoutSpec(direction: .vertical,
                                           spacing: 5,
                                           justifyContent: .start,
                                           alignItems: .start,
                                           children: [self.dateNode, self.locationNode])
        
        let stack = ASStackLayoutSpec(direction: .vertical,
                                      spacing: 18.0,
                                      justifyContent: .start,
                                      alignItems: .start,
                                      children: [self.headerNode, self.imageNode, labelStack])
        
        var insets = self.safeAreaInsets
        insets.left = 20
        insets.right = 20
        
        let insetSpec = ASInsetLayoutSpec(insets: insets, child: stack)
        
        return insetSpec
    }
}
