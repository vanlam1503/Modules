//
//  CollectionExts.swift
//  GridCollectionView
//
//  Created by MBP0004 on 7/25/20.
//  Copyright © 2020 MBP0004. All rights reserved.
//

import Foundation

extension Collection {

    subscript(safe index: Index) -> Element? {
        guard self.indices.contains(index) else { return nil }
        return self[index]
    }
}
