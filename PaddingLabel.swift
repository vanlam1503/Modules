//
//  PaddingLabel.swift
//  PaddingLabel
//
//  Created by Lam Le V. on 11/28/19.
//  Copyright © 2019 Lam Le V. All rights reserved.
//

import UIKit

@IBDesignable class PaddingLabel: UILabel {

    @IBInspectable var topInset: CGFloat = 0.0
    @IBInspectable var leftInset: CGFloat = 0.0
    @IBInspectable var bottomInset: CGFloat = 0.0
    @IBInspectable var rightInset: CGFloat = 0.0

    var insets: UIEdgeInsets {
        get {
            return UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        }
        set {
            topInset = newValue.top
            leftInset = newValue.left
            bottomInset = newValue.bottom
            rightInset = newValue.right
        }
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var newSize = super.sizeThatFits(size)
        newSize.width += leftInset + rightInset
        newSize.height += topInset + bottomInset
        return newSize
    }

    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.width += leftInset + rightInset
        contentSize.height += topInset + bottomInset
        return contentSize
    }
}
