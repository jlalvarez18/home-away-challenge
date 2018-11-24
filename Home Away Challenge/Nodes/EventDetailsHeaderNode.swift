//
//  EventDetailsHeaderNode.swift
//  Home Away Challenge
//
//  Created by Juan Alvarez on 11/21/18.
//  Copyright © 2018 Juan Alvarez. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class EventDetailsHeaderNode: ASDisplayNode {
    
    lazy var titleLabelNode: ASTextNode = {
        let node = ASTextNode()
        node.style.flexShrink = 1.0
        node.style.flexGrow = 1.0
        return node
    }()
    
    lazy var likeButtonNode: ASButtonNode = {
        let node = ASButtonNode()
        node.setImage(#imageLiteral(resourceName: "heart-outline"), for: UIControl.State.normal)
        node.setImage(#imageLiteral(resourceName: "heart-solid"), for: UIControl.State.selected)
        node.style.preferredSize = CGSize(width: 45, height: 45)
        return node
    }()
    
    lazy var backButtonNode: ASButtonNode = {
        let node = ASButtonNode()
        node.setImage(#imageLiteral(resourceName: "back"), for: UIControl.State.normal)
        node.style.preferredSize = CGSize(width: 45, height: 45)
        return node
    }()
    
    lazy var dividerLineNode: ASDisplayNode = {
        let node = ASDisplayNode()
        node.backgroundColor = UIColor.lightGray
        node.style.height = ASDimensionMake(1.0)
        return node
    }()
    
    private var observerToken: FavoritesStore.ObserverToken?
    
    let event: Event
    
    init(event: Event) {
        self.event = event
        
        super.init()
        
        self.titleLabelNode.attributedText = NSAttributedString(string: self.event.title, attributes: [
            .font: UIFont.systemFont(ofSize: 22, weight: .heavy)
            ])
        
        self.likeButtonNode.isSelected = FavoritesStore.isFavorite(event: self.event)
        
        self.automaticallyManagesSubnodes = true
    }
    
    override func didLoad() {
        super.didLoad()
        
        self.backButtonNode.addTarget(self, action: #selector(self.goBack), forControlEvents: .touchUpInside)
        
        self.likeButtonNode.addTarget(self, action: #selector(self.didTapFavoriteButton), forControlEvents: .touchUpInside)
        
        self.observerToken = FavoritesStore.observe(event: self.event) { (isFavorite) in
            self.likeButtonNode.isSelected = isFavorite
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let contentStack = ASStackLayoutSpec(direction: .horizontal,
                                     spacing: 9.0,
                                     justifyContent: .spaceBetween,
                                     alignItems: .start,
                                     children: [self.backButtonNode, self.titleLabelNode, self.likeButtonNode])
        
        let stack = ASStackLayoutSpec(direction: .vertical,
                                      spacing: 18.0,
                                      justifyContent: .start,
                                      alignItems: .start,
                                      children: [contentStack, self.dividerLineNode])
        
        let insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        let insetSpec = ASInsetLayoutSpec(insets: insets, child: stack)
        
        return insetSpec
    }
    
    @objc func didTapFavoriteButton() {
        do {
            if (self.likeButtonNode.isSelected) {
                try FavoritesStore.unfavorite(event: self.event)
            } else {
                try FavoritesStore.favorite(event: self.event)
            }
        } catch {
            print(error)
        }
    }
    
    @objc func goBack() {
        self.closestViewController?.navigationController?.popViewController(animated: true)
    }
}
