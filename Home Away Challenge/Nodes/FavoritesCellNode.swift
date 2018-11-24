//
//  FavoritesCellNode.swift
//  Home Away Challenge
//
//  Created by Juan Alvarez on 11/24/18.
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

class FavoritesCellNode: ASCellNode {
    
    lazy var imageNode: ASNetworkImageNode = {
        let node = ASNetworkImageNode()
        node.cornerRadius = 9.0
        node.style.preferredSize = CGSize(width: 100, height: 100)
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
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        return formatter
    }()
    
    let favorite: Favorite
    
    init(_ favorite: Favorite) {
        self.favorite = favorite
        
        super.init()
        
        self.imageNode.url = {
            guard let imageUrlString = favorite.imageUrlString else {
                return nil
            }
            
            let url = URL(string: imageUrlString)
            
            return url
        }()
        self.titleNode.attributedText = NSAttributedString(string: favorite.title, attributes: Attributes.title)
        self.locationNode.attributedText = NSAttributedString(string: favorite.location, attributes: Attributes.subtitle)
        self.dateNode.attributedText = {
            let dateString: String
            
            if let date = favorite.datetimeLocal {
                dateString = EventCellNode.dateFormatter.string(from: date)
            } else {
                dateString = "TBD"
            }
            
            return NSAttributedString(string: dateString, attributes: Attributes.subtitle)
        }()
        
        self.automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let imageSpec = ASAbsoluteLayoutSpec(sizing: ASAbsoluteLayoutSpecSizing.sizeToFit,
                                             children: [self.imageNode, self.likeImageNode])
        
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
                                          children: [labelStack, imageSpec])
        
        let insets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        let insetSpec = ASInsetLayoutSpec(insets: insets, child: fullStack)
        
        return insetSpec
    }
}
