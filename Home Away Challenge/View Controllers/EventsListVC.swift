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
    
    private var searchResults: [Event] = [] {
        didSet {
            self.table.animateRowChanges(oldData: oldValue,
                                         newData: searchResults,
                                         deletionAnimation: UITableView.RowAnimation.fade,
                                         insertionAnimation: UITableView.RowAnimation.automatic)
        }
    }
    
    private var localEvents: [Event] = [] {
        didSet {
            self.table.reloadData()
        }
    }
    
    private var isSearching: Bool = false {
        didSet {
            self.table.view.separatorStyle = self.isSearching ? .singleLine : .none
            self.table.reloadData()
        }
    }
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.barStyle = .black
        searchBar.searchBarStyle = .default
        searchBar.tintColor = UIColor.white
        searchBar.barTintColor = #colorLiteral(red: 0.06647928804, green: 0.191093564, blue: 0.2737248242, alpha: 1)
        searchBar.placeholder = "Search for events"
        return searchBar
    }()
    
    init() {
        let node = ASTableNode(style: .plain)
        
        self.table = node
        
        super.init(node: node)
        
        self.title = "Events"
        self.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
        
        self.table.dataSource = self
        self.table.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.table.view.separatorStyle = .none
        self.table.view.keyboardDismissMode = .onDrag
        
        self.searchBar.delegate = self
        
        self.navigationItem.titleView = self.searchBar
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.06647928804, green: 0.191093564, blue: 0.2737248242, alpha: 1)
        
        firstly { () -> Promise<[Venue]> in
            return SeatGeekService.getVenues(postalCode: "78681").promise
        }.then { (venues) -> Promise<[Event]> in
            return SeatGeekService.getEventsFor(venues: venues).promise
        }.done { (events) in
            self.localEvents = events
            
            if (self.isSearching != false) {
                self.table.reloadData()
            }
        }.catch { (error) in
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension EventsListVC: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        if self.isSearching {
            return self.searchResults.count
        }
        
        return self.localEvents.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        if self.isSearching {
            let event = self.searchResults[indexPath.row]
            
            return { return EventCellNode(event: event) }
        } else {
            let event = self.localEvents[indexPath.row]
            
            return { return LocalEventCellNode(event: event) }
        }
    }
}

extension EventsListVC: ASTableDelegate {
    
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        tableNode.deselectRow(at: indexPath, animated: true)
        
        let event: Event
        if self.isSearching {
            event = self.searchResults[indexPath.row]
        } else {
            event = self.localEvents[indexPath.row]
        }
        
        let vc = EventDetailsVC(event: event)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension EventsListVC: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.isSearching = true
        
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let request = self.currentSearchRequest {
            request.cancel()
        }
        
        guard searchText.isEmpty == false else {
            self.searchResults = []
            self.isSearching = false
            self.table.reloadData()
            return
        }
        
        self.isSearching = true
        
        let (request, promise) = SeatGeekService.getEvents(query: searchText)
        
        self.currentSearchRequest = request
        
        promise.done { (events) in
            self.searchResults = events
        }.ensure {
            self.currentSearchRequest = nil
        }.catch { (error) in
            print(error)
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.endEditing(true)
        
        self.searchResults = []
        self.isSearching = false
        self.table.reloadData()
        
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}
