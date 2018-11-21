//
//  ViewController.swift
//  Home Away Challenge
//
//  Created by Juan Alvarez on 11/20/18.
//  Copyright © 2018 Juan Alvarez. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import PromiseKit

extension ASNavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if let top = self.topViewController {
            return top.preferredStatusBarStyle
        }
        
        return UIStatusBarStyle.default
    }
}

class EventsListVC: ASViewController<ASTableNode> {
    
    private let table: ASTableNode
    
    private var currentSearchRequest: DataRequest?
    
    private var events: [Event] = [] {
        didSet {
            self.table.animateRowChanges(oldData: oldValue,
                                         newData: events,
                                         deletionAnimation: UITableView.RowAnimation.fade,
                                         insertionAnimation: UITableView.RowAnimation.automatic)
        }
    }
    
    init() {
        let node = ASTableNode(style: .plain)
        
        self.table = node
        
        super.init(node: node)
        
        self.table.dataSource = self
        self.table.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.table.view.keyboardDismissMode = .onDrag
        
        let searchBar = UISearchBar()
        searchBar.tintColor = UIColor.white
        searchBar.barTintColor = #colorLiteral(red: 0.06647928804, green: 0.191093564, blue: 0.2737248242, alpha: 1)
        searchBar.placeholder = "Search for events"
        searchBar.delegate = self
        
        self.navigationItem.titleView = searchBar
        
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.06647928804, green: 0.191093564, blue: 0.2737248242, alpha: 1)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension EventsListVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let event = self.events[indexPath.row]
        
        return {
            return EventCellNode(event: event, isFavorited: indexPath.row == 0)
        }
    }
}

extension EventsListVC: ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        tableNode.deselectRow(at: indexPath, animated: true)
        
        let event = self.events[indexPath.row]
        
        let vc = EventDetailsVC(event: event)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension EventsListVC: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let request = self.currentSearchRequest {
            request.cancel()
        }
        
        guard searchText.isEmpty == false else {
            self.events = []
            return
        }
        
        let (request, promise) = SeatGeekService.getEvents(query: searchText)
        
        self.currentSearchRequest = request
        
        promise.done { (events) in
            self.events = events
        }.ensure {
            self.currentSearchRequest = nil
        }.catch { (error) in
            print(error)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        
        self.events = []
        
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
