//
//  ImagesCollectionViewController+NSFetchedResultsControllerDelegat.swift
//  Virtual Tourist
//
//  Created by António Ramos on 01/08/2019.
//  Copyright © 2019 António Ramos. All rights reserved.
//

import Foundation
import CoreData

extension ImagesCollectionViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertIndexPath = [IndexPath]()
        deleteIndexPath = [IndexPath]()
        updateIndexPath = [IndexPath]()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch (type) {
        case .insert:
            insertIndexPath.append(newIndexPath!)
            break
        case .update:
            updateIndexPath.append(indexPath!)
            break
        case .delete:
            deleteIndexPath.append(indexPath!)
            break
        case .move:
            showAlert(message: "This feature was not implemented in this app.")
            break
        @unknown default:
            showAlert(message: "Unknow feature not yet implemented")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates( {() -> Void in
            for indexPath in self.insertIndexPath {
                self.collectionView.insertItems(at: [indexPath])
            }
            for indexPath in self.deleteIndexPath {
                self.collectionView.deleteItems(at: [indexPath])
            }
            for indexPath in self.updateIndexPath {
                self.collectionView.reloadItems(at: [indexPath])
            }
        }, completion: nil)
        
    }
}

