//
//  EventCellNode.swift
//  Home Away Challenge
//
//  Created by Juan Alvarez on 11/20/18.
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
        NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1),
        NSAttributedString.Key.foregroundColor: UIColor.lightGray
    ]
}

private let ImageSize = CGSize(width: 80, height: 80)

class EventCellNode: ASCellNode {
    
    let event: Event
    let isFavorited: Bool
    
    lazy var imageNode: ASNetworkImageNode = {
        let node = ASNetworkImageNode()
        node.cornerRadius = 9.0
        node.style.preferredSize = ImageSize
        node.backgroundColor = UIColor.lightGray
        
        return node
    }()
    
    lazy var titleNode: ASTextNode = {
        let node = ASTextNode()
        
        return node
    }()
    
    lazy var locationNode: ASTextNode = {
        let node = ASTextNode()
        
        return node
    }()
    
    lazy var dateNode: ASTextNode = {
        let node = ASTextNode()
        
        return node
    }()
    
    lazy var likeImageNode: ASImageNode = {
        let node = ASImageNode()
        node.image = #imageLiteral(resourceName: "heart")
        node.style.preferredSize = CGSize(width: 24, height: 24)
        node.style.layoutPosition = CGPoint(x: -12, y: -9)
        
        return node
    }()
    
    init(event: Event, isFavorited: Bool) {
        self.event = event
        self.isFavorited = isFavorited
        
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        
        super.init()
        
        self.imageNode.url = self.event.performers.first?.image
        self.titleNode.attributedText = NSAttributedString(string: event.title, attributes: Attributes.title)
        self.locationNode.attributedText = NSAttributedString(string: event.venue.displayLocation, attributes: Attributes.subtitle)
        self.dateNode.attributedText = NSAttributedString(string: df.string(from: event.datetimeLocal), attributes: Attributes.subtitle)
        
        self.automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let imageSpec: ASLayoutSpec
        
        if self.isFavorited {
            imageSpec = ASAbsoluteLayoutSpec(sizing: ASAbsoluteLayoutSpecSizing.sizeToFit,
                                             children: [self.imageNode, self.likeImageNode])
        } else {
            imageSpec = ASAbsoluteLayoutSpec(children: [self.imageNode])
        }
        
        let labelStack = ASStackLayoutSpec(direction: .vertical,
                                           spacing: 4.0,
                                           justifyContent: .start,
                                           alignItems: .start,
                                           children: [self.titleNode, self.locationNode, self.dateNode])
        
        labelStack.style.flexGrow = 1.0
        labelStack.style.flexShrink = 1.0
        
        let fullStack = ASStackLayoutSpec(direction: .horizontal,
                                          spacing: 20.0,
                                          justifyContent: .start,
                                          alignItems: .start,
                                          children: [imageSpec, labelStack])
        
        let insets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        let insetSpec = ASInsetLayoutSpec(insets: insets, child: fullStack)
        
        return insetSpec
    }
}
