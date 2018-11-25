//
//  Diff+Texture.swift
//  Home Away Challenge
//
//  Created by Juan Alvarez on 11/20/18.
//  Copyright © 2018 Juan Alvarez. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import Differ

extension ASTableNode {
    
    func animateRowChanges<T: Collection>(
        oldData: T,
        newData: T,
        deletionAnimation: UITableView.RowAnimation = .automatic,
        insertionAnimation: UITableView.RowAnimation = .automatic,
        indexPathTransform: (IndexPath) -> IndexPath = { $0 }
    ) where T.Element: Equatable {
        self.apply(oldData.extendedDiff(newData),
                   deletionAnimation: deletionAnimation,
                   insertionAnimation: insertionAnimation,
                   indexPathTransform: indexPathTransform)
    }
    
    public func apply(
        _ diff: ExtendedDiff,
        deletionAnimation: UITableView.RowAnimation = .automatic,
        insertionAnimation: UITableView.RowAnimation = .automatic,
        indexPathTransform: (IndexPath) -> IndexPath = { $0 }
    ) {
        let update = BatchUpdate(diff: diff, indexPathTransform: indexPathTransform)
        
        self.performBatchUpdates({
            deleteRows(at: update.deletions, with: deletionAnimation)
            insertRows(at: update.insertions, with: insertionAnimation)
            update.moves.forEach { moveRow(at: $0.from, to: $0.to) }
        }, completion: nil)
    }
}
