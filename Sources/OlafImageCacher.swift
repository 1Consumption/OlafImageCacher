//
//  OlafImageCacher.swift
//  OlafImageCacher
//
//  Created by 신한섭 on 2020/09/19.
//

import UIKit

/// Struct that contains features supported by OlafImageCacher.
/// property `base` contains the address of an object conforming to the `ViewHashImage` protocol.
public struct OlafImageCacher<Base> {
    
    private let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

/// A view that has an image.
/// e.g. UIImageView, UIButton
public protocol ViewHasImage: AnyObject {}

extension ViewHasImage {
    /// This property allows you to use the features of OlafImageCacher.
    /// e.g. imageView.of
    public var of: OlafImageCacher<Self> {
        return OlafImageCacher(self)
    }
}

extension UIImageView: ViewHasImage {}
