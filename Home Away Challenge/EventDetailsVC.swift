//
//  EventDetailsVC.swift
//  Home Away Challenge
//
//  Created by Juan Alvarez on 11/20/18.
//  Copyright © 2018 Juan Alvarez. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class EventDetailsVC: ASViewController<ASDisplayNode> {
    
    let event: Event
    
    init(event: Event) {
        self.event = event
        
        let node = ASDisplayNode()
        node.backgroundColor = UIColor.white
        
        super.init(node: node)
        
        self.title = self.event.title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.largeTitle),
                .foregroundColor: UIColor.white
            ]
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
            label.numberOfLines = 2
            label.textAlignment = NSTextAlignment.left
            label.attributedText = NSAttributedString(string: self.event.title, attributes: attributes)
            label.sizeToFit()
            
            return label
        }()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(self.toggleFavorite))
    }
    
    @objc func toggleFavorite() {
        let isFavorite = FavoritesStore.isFavorite(event: event)
        
        if isFavorite {
            FavoritesStore.unfavorite(event: event)
        } else {
            FavoritesStore.favorite(event: self.event)
        }
    }
}
