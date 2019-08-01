//
//  ImagesCollectionViewController+UICollectionView.swift
//  Virtual Tourist
//
//  Created by António Ramos on 01/08/2019.
//  Copyright © 2019 António Ramos. All rights reserved.
//

import UIKit

extension ImagesCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let image = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.reusableIdentifier, for: indexPath) as! CollectionViewCell
        
        cell.cellImageView.image = nil
        
        if cell.cellImageView.image == nil {
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
            cell.backgroundColor = .gray
        }
        
        if image.data != nil {
            if let data = image.data {
                cell.backgroundColor = .clear
                cell.cellImageView.image = UIImage(data: data)
                cell.cellImageView.contentMode = .scaleAspectFill
                cell.activityIndicator.stopAnimating()
                cell.activityIndicator.isHidden = true
                downloadNewCollectionButton.isEnabled = true
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if downloadNewCollectionButton.isEnabled == true {
            let imageToDelete = fetchedResultsController.object(at: indexPath)
            delete(dataController.viewContext, object: imageToDelete)
        } else {
            return
        }
    }
}
