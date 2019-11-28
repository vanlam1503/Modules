//
//  ParentView.swift
//  PaddingLabel
//
//  Created by Lam Le V. on 11/28/19.
//  Copyright © 2019 Lam Le V. All rights reserved.
//

import UIKit

class ParentView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        loadNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func loadNib() {

        let bundle = Bundle.main
        var xib: String?
        let name = String(describing: type(of: self))
        if bundle.path(forResource: name, ofType: "nib") != nil {
            xib = name
        }
        if let xib = xib, let view = bundle.loadNibNamed(xib, owner: self)?.first as? UIView {
            addSubview(view)
            view.frame = bounds
        }
    }
}

extension Bundle {
    func hasNib(name: String) -> Bool {
        return path(forResource: name, ofType: "nib") != nil
    }
}
