//
//  FavoritesVC.swift
//  Home Away Challenge
//
//  Created by Juan Alvarez on 11/24/18.
//  Copyright © 2018 Juan Alvarez. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RealmSwift

class FavoritesVC: ASViewController<ASTableNode> {
    
    private var notificationToken: NotificationToken?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    init() {
        let node = ASTableNode(style: .plain)
        
        super.init(node: node)
        
        self.title = "Favorites"
        self.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)
        
        node.dataSource = self
        node.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        self.navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .largeTitle),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.06647928804, green: 0.191093564, blue: 0.2737248242, alpha: 1)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        let realm = try! Realm()
        let results = realm.objects(Favorite.self)
        
        self.notificationToken = results.observe { [weak self] (changes) in
            guard let table = self?.node else {
                return
            }
            
            switch changes {
            case .initial:
                table.reloadData()
                
            case .update(_, let deletions, let insertions, let modifications):
                table.performBatchUpdates({
                    table.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    table.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                    table.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                }, completion: nil)
                
            case .error(let error):
                print(error)
            }
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension FavoritesVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        let realm = try! Realm()
        let results = realm.objects(Favorite.self)
        
        return results.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        let favorite = try! getFavorite(at: indexPath)
        
        return FavoritesCellNode(favorite)
    }
}

extension FavoritesVC: ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        tableNode.deselectRow(at: indexPath, animated: true)
        
        let favorite = try! getFavorite(at: indexPath)
        
        let vc = EventDetailsVC(event: favorite)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

private extension FavoritesVC {
    
    func getFavorite(at indexPath: IndexPath) throws -> Favorite {
        let realm = try Realm()
        let results = realm.objects(Favorite.self)
        
        let favorite = results[indexPath.row]
        
        return favorite
    }
}
