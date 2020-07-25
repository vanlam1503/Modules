//
//  GridCollectionView.swift
//  GridCollectionView
//
//  Created by MBP0004 on 7/25/20.
//  Copyright © 2020 MBP0004. All rights reserved.
//

import UIKit

protocol GridCollectionViewDelegate: class {
    func gridCollectionView(_ gridCollectionView: GridCollectionView, didSelectItemAt indexPath: IndexPath)
}

protocol GridCollectionViewDataSource: class {
    func gridCollectionView(_ gridCollectionView: GridCollectionView, cellForRowAt indexPath: IndexPath) -> UICollectionViewCell
    func gridCollectionView(_ gridCollectionView: GridCollectionView, cellForHeaderAt indexPath: IndexPath) -> UICollectionViewCell
    func gridCollectionView(_ gridCollectionView: GridCollectionView, cellForSectionAt indexPath: IndexPath) -> UICollectionViewCell

    func gridCollectionView(_ gridCollectionView: GridCollectionView, sizeForRowAt indexPath: IndexPath) -> CGSize
    func gridCollectionView(_ gridCollectionView: GridCollectionView, sizeForSectionAt indexPath: IndexPath) -> CGSize
    func gridCollectionView(_ gridCollectionView: GridCollectionView, sizeForHeaderAt indexPath: IndexPath) -> CGSize

    // Calculate
    func numberOfHeaders(in gridCollectionView: GridCollectionView) -> Int
    func numberOfColumn(in gridCollectionView: GridCollectionView) -> Int
    func numberOfSection(in gridCollectionView: GridCollectionView) -> Int
    func gridCollectionView(_ gridCollectionView: GridCollectionView, numberOfRowInSection section: Int) -> Int
}

extension GridCollectionViewDataSource {

    func numberOfHeaders(in gridCollectionView: GridCollectionView) -> Int {
         return 1
    }

    func numberOfSection(in gridCollectionView: GridCollectionView) -> Int {
        return 1
    }
}

final class Blank: CustomDebugStringConvertible {
    var column = 0
    var header = 0
    var section = 0
    var row = 0

    var isHeader: Bool {
        if (row < 0) && (section < 0) {
            return true
        }
        return false
    }

    var isSection: Bool {
        if (row  < 0) && (section >= 0) {
            return true
        }
        return false
    }

    init() {}

    var debugDescription: String {
        return "header: \(header), column: \(column), row: \(row), section: \(section)"
    }
}

final class GridCollectionView: UIView {

    private var collectionView: UICollectionView!
    private var lastContentOffset: CGPoint = .zero
    weak var dataSource: GridCollectionViewDataSource! {
        didSet {
            configDataSource()
        }
    }
    weak var delegate: GridCollectionViewDelegate?

    var numberOfHeaders = 0
    var numberOfSection = 0
    var rowsAtSection: [Section: Row] = [0: 0]
    private var caches: [IndexPath: Blank] = [:]

    typealias Section = Int
    typealias Row = Int

    override func awakeFromNib() {
        super.awakeFromNib()
        configView()
    }

    private func configView() {
        // Add subview
        let layout = GridCollectionViewFlowLayout()
        layout.delegate = self
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        addSubview(collectionView)

        // Register
//        collectionView.register(nibWithCellClass: BackCell.self)
//        collectionView.register(nibWithCellClass: CategoryCollectionCell.self)
//        collectionView.register(nibWithCellClass: HourlyDetailCollectionCell.self)
//        collectionView.register(nibWithCellClass: WindCollectionCell.self)
//        collectionView.register(nibWithCellClass: WeatherCollectionCell.self)
//        collectionView.register(nibWithCellClass: DateSectionCollectionCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.bounces = false
    }

    private func configDataSource() {
        guard let dataSource = dataSource else { return }
        numberOfHeaders = dataSource.numberOfHeaders(in: self)
        numberOfSection = dataSource.numberOfSection(in: self)
        for sectionIndex in 0..<numberOfSection {
             rowsAtSection[sectionIndex] = dataSource.gridCollectionView(self, numberOfRowInSection: sectionIndex)
        }
    }

    func blankAt(indexPath: IndexPath) -> Blank {
        let box = Blank()
        box.column = indexPath.row
        if let box = caches[indexPath] {
            return box
        }
        defer {
            caches[indexPath] = box
        }
        box.row = indexPath.section - numberOfHeaders
        box.section -= numberOfHeaders
        if box.row < 0 {
            return box
        }
        for _ in 0..<numberOfSection {
            box.row -= 1 // decrease if we have section
            box.section += 1
            if let value = rowsAtSection[box.section] {
                if box.row < value {
                    return box
                } else {
                    box.row -= value
                    continue
                }
            }
        }
        return box
    }

    func invalidateLayout() {
        (collectionView.collectionViewLayout as? GridCollectionViewFlowLayout)?.removeItemAttributes()
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

// MARK: - UICollectionViewDelegate

extension GridCollectionView: UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let absContentOffsetX = abs(scrollView.contentOffset.x - lastContentOffset.x)
        let absContentOffsetY = abs(scrollView.contentOffset.y - lastContentOffset.y)
        if (absContentOffsetX > absContentOffsetY) && (scrollView.contentOffset.y > 0) {
            scrollView.contentOffset.y = lastContentOffset.y
        } else if absContentOffsetY > absContentOffsetX && (scrollView.contentOffset.x > 0) {
            scrollView.contentOffset.x = lastContentOffset.x
        } else if (scrollView.contentOffset.y < 0) && (absContentOffsetY > absContentOffsetX) {
            scrollView.contentOffset.x = lastContentOffset.x
        } else if (scrollView.contentOffset.x < 0) && (absContentOffsetX > absContentOffsetY) {
            scrollView.contentOffset.y = lastContentOffset.y
        }
        lastContentOffset = scrollView.contentOffset
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.gridCollectionView(self, didSelectItemAt: indexPath)
    }
}

// MARK: - UICollectionViewDataSource
extension GridCollectionView: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        var number: Int = numberOfHeaders + numberOfSection
        number += (rowsAtSection.values.reduce(0, +))
        return number
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let blank: Blank = blankAt(indexPath: IndexPath(item: 0, section: section))
        if blank.isSection {
            return 1
        }
        return dataSource.numberOfColumn(in: self)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let blank: Blank = blankAt(indexPath: indexPath)
        if blank.isHeader {
            return dataSource.gridCollectionView(self, cellForHeaderAt: indexPath)
        } else if blank.isSection {
            return dataSource.gridCollectionView(self, cellForSectionAt: indexPath)
        }
        return dataSource.gridCollectionView(self, cellForRowAt: indexPath)
    }
}

extension GridCollectionView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .zero
    }
}

extension GridCollectionView: GridCollectionViewFlowLayoutDelegate {

    func collectionView(_ collectionView: UICollectionView, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let blank = blankAt(indexPath: indexPath)
        if blank.isHeader {
            return dataSource.gridCollectionView(self, sizeForHeaderAt: indexPath)
        } else if blank.isSection {
            return dataSource.gridCollectionView(self, sizeForSectionAt: indexPath)
        }
        return dataSource.gridCollectionView(self, sizeForRowAt: indexPath)
    }
}

// MARK: Register
extension GridCollectionView {

    func register<T: UICollectionViewCell>(nibWithCellClass name: T.Type, at bundleClass: AnyClass? = nil) {
        let identifier = String(describing: name)
        var bundle: Bundle?
        if let bundleName = bundleClass {
            bundle = Bundle(for: bundleName)
        }
        collectionView.register(UINib(nibName: identifier, bundle: bundle), forCellWithReuseIdentifier: identifier)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(withClass name: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: name), for: indexPath) as? T else {
            fatalError("Couldn't find cell for \(String(describing: name)), make sure the cell is registered with collection view")
        }
        return cell
    }
}
