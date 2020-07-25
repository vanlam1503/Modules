//
//  GridCollectionViewFlowLayout.swift
//  GridCollectionView
//
//  Created by MBP0004 on 7/25/20.
//  Copyright © 2020 MBP0004. All rights reserved.
//

import UIKit

protocol GridCollectionViewFlowLayoutDelegate: class {
    func collectionView(_ collectionView: UICollectionView, sizeForItemAt indexPath: IndexPath) -> CGSize
}

final class GridCollectionViewFlowLayout: UICollectionViewFlowLayout {

    weak var delegate: GridCollectionViewFlowLayoutDelegate?
    var itemAttributes: [[UICollectionViewLayoutAttributes]] = []
    var contentSize: CGSize = .zero

    func removeItemAttributes() {
        if !itemAttributes.isEmpty {
            itemAttributes.removeAll()
        }
    }

    override func prepare() {
        guard let collectionView = collectionView else {
            return
        }
        if collectionView.numberOfSections == 0 {
            return
        }
        if itemAttributes.count != collectionView.numberOfSections {
            generateItemAttributes(collectionView: collectionView)
            return
        }

        for section in 0..<collectionView.numberOfSections {
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                if section != 0 && item != 0 {
                    continue
                }
                if let attributes = layoutAttributesForItem(at: IndexPath(item: item, section: section)) {
                    if section == 0 {
                        var frame = attributes.frame
                        frame.origin.y = collectionView.contentOffset.y
                        attributes.frame = frame
                    }

                    if item == 0 {
                        var frame = attributes.frame
                        frame.origin.x = collectionView.contentOffset.x
                        attributes.frame = frame
                    }
                }
            }
        }
    }

    override var collectionViewContentSize: CGSize {
        return contentSize
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return itemAttributes[safe: indexPath.section]?[safe: indexPath.row]
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        for section in itemAttributes {
            let filteredArray = section.filter { obj -> Bool in
                return rect.intersects(obj.frame)
            }
            attributes.append(contentsOf: filteredArray)
        }
        return attributes
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

extension GridCollectionViewFlowLayout {

    func generateItemAttributes(collectionView: UICollectionView) {
        guard let delegate = delegate else {
            fatalError("Please handle delegate for \(String(describing: self))")
        }
        var column = 0
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        var contentWidth: CGFloat = 0
        itemAttributes = []
        for section in 0..<collectionView.numberOfSections {
            var sectionAttributes: [UICollectionViewLayoutAttributes] = []
            let numberOfItem: Int = collectionView.numberOfItems(inSection: section)
            for index in 0..<numberOfItem {
                let indexPath = IndexPath(item: index, section: section)
                let itemSize = delegate.collectionView(collectionView, sizeForItemAt: indexPath)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemSize.width, height: itemSize.height).integral
                if let gridView = collectionView.superview as? GridCollectionView {
                    let blank = gridView.blankAt(indexPath: indexPath)
                    if blank.isHeader && blank.column == 0 {
                        // Keep first cell on top
                        attributes.zIndex = 1_024
                    } else if blank.isSection {
                        attributes.zIndex = 1_022
                    } else if section == 0 || index == 0 {
                        attributes.zIndex = 1_023
                    }
                }
                if section == 0 {
                    var frame = attributes.frame
                    frame.origin.y = collectionView.contentOffset.y
                    attributes.frame = frame
                }
                if index == 0 {
                    var frame = attributes.frame
                    frame.origin.x = collectionView.contentOffset.x
                    attributes.frame = frame
                }
                sectionAttributes.append(attributes)
                xOffset += itemSize.width
                column += 1
                if column == numberOfItem {
                    if xOffset > contentWidth {
                        contentWidth = xOffset
                    }
                    column = 0
                    xOffset = 0
                    yOffset += itemSize.height
                }
            }
            itemAttributes.append(sectionAttributes)
        }
        if let attributes = itemAttributes.last?.last {
            contentSize = CGSize(width: contentWidth, height: attributes.frame.maxY)
        }
    }
}


