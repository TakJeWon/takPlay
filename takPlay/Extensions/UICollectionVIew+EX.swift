//
//  UICollectionVIew+EX.swift
//  takPlay
//
//  Created by 탁제원 on 4/30/24.
//

import UIKit

extension UICollectionView {
    func scrollToCenterForItem(at indexPath: IndexPath, animated: Bool) {
        guard let layoutAttributes = layoutAttributesForItem(at: indexPath) else {
            return
        }
        
        let collectionViewWidth = self.bounds.size.width
        let xOffset = layoutAttributes.frame.origin.x - (collectionViewWidth - layoutAttributes.frame.width) / 2
        
        setContentOffset(CGPoint(x: xOffset, y: 0), animated: animated)
    }
}
