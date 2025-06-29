//
//  UIView.swift
//  Generic project
//
//  Created by Zain Haider on 10/05/2021.
//

import UIKit

public extension UIView {

    enum gradianColor {
        case blue
        case green
        case blueDark
    }
    /// Add both shadow and corner radius.
    /// - Parameters:
    ///   - capacity: capacity of shadow.
    ///   - cornerRadius: Corner radius of shadow.
    func AddShadowAndCornerRadius(capacity: Float = 0.4, cornerRadius: CGFloat = 12, shadowColor: UIColor = .gray) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = false
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = CGSize(width: -2, height: 7)
        self.layer.backgroundColor = self.backgroundColor?.cgColor ?? UIColor.white.cgColor
        self.layer.shadowOpacity = capacity
        self.layer.shadowRadius = cornerRadius
    }
    
    func rotate(degrees: CGFloat) {
        rotate(radians: CGFloat.pi * degrees / 180.0)
    }
    
    func rotate(radians: CGFloat) {
        self.transform = CGAffineTransform(rotationAngle: radians)
    }
}


extension Collection {
    func unfoldSubSequences(limitedTo maxLength: Int) -> UnfoldSequence<SubSequence,Index> {
        sequence(state: startIndex) { start in
            guard start < self.endIndex else { return nil }
            let end = self.index(start, offsetBy: maxLength, limitedBy: self.endIndex) ?? self.endIndex
            defer { start = end }
            return self[start..<end]
        }
    }

    func every(n: Int) -> UnfoldSequence<Element,Index> {
        sequence(state: startIndex) { index in
            guard index < endIndex else { return nil }
            defer { index = self.index(index, offsetBy: n, limitedBy: endIndex) ?? endIndex }
            return self[index]
        }
    }

    var pairs: [SubSequence] { .init(unfoldSubSequences(limitedTo: 2)) }
}
extension StringProtocol where Self: RangeReplaceableCollection {
    mutating func insert<S: StringProtocol>(separator: S, every n: Int) {
        for index in indices.every(n: n).dropFirst().reversed() {
            insert(contentsOf: separator, at: index)
        }
    }
    func inserting<S: StringProtocol>(separator: S, every n: Int) -> Self {
        .init(unfoldSubSequences(limitedTo: n).joined(separator: separator))
    }
}
