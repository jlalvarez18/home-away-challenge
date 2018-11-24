//
//  LocalEventCellNode.swift
//  Home Away Challenge
//
//  Created by Juan Alvarez on 11/23/18.
//  Copyright © 2018 Juan Alvarez. All rights reserved.
//

import Foundation
import AsyncDisplayKit

private let TextShadow: NSShadow = {
    let shadow = NSShadow()
    shadow.shadowOffset = .zero
    shadow.shadowColor = UIColor.black.withAlphaComponent(0.5)
    shadow.shadowBlurRadius = 4.0
    return shadow
}()

private let TitleAttributes: [NSAttributedString.Key: Any] = [
    .font: UIFont.preferredFont(forTextStyle: .title1),
    .foregroundColor: UIColor.white,
    .shadow: TextShadow
]

class LocalEventCellNode: ASCellNode {
    
    lazy var imageNode: ASNetworkImageNode = {
        let node = ASNetworkImageNode()
        node.style.width = ASDimensionMake("100%")
        node.style.height = ASDimensionMake(200)
        
        node.cornerRadius = 9.0
        return node
    }()
    
    lazy var titleNode: ASTextNode = {
        let node = ASTextNode()
        node.style.flexGrow = 1.0
        node.style.flexShrink = 1.0
        return node
    }()
    
    let event: Event
    
    init(event: Event) {
        self.event = event
        
        super.init()
        
        self.shadowOpacity = 0.3
        self.shadowRadius = 4
        self.shadowOffset = .zero

        self.imageNode.url = self.event.performers.first?.images?.first?.value
        self.titleNode.attributedText = NSAttributedString(string: self.event.title, attributes: TitleAttributes)
        
        self.automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let textInsets = UIEdgeInsets(top: .infinity, left: 10, bottom: 10, right: 10)
        let textInsetSpec = ASInsetLayoutSpec(insets: textInsets, child: self.titleNode)
        
        let overlaySpec = ASOverlayLayoutSpec(child: self.imageNode, overlay: textInsetSpec)
        
        let insets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        let insetSpec = ASInsetLayoutSpec(insets: insets, child: overlaySpec)
        
        return insetSpec
    }
}
