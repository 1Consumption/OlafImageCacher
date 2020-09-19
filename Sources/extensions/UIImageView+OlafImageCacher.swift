//
//  UIImageView+OlafImageCacher.swift
//  OlafImageCacher
//
//  Created by 신한섭 on 2020/09/19.
//

import UIKit

extension OlafImageCacher where Base: UIImageView {
    @discardableResult
    public func setImage(with source: URL?) -> URLSessionDownloadTask? {
        //TODO: 1. Cache check through ImageCacher object.
        //TODO: 2. If an image exists, it is inserted into the image of the `base` property.
        //TODO: 3. If it does not exist, the image is retrieved from the network and inserted into the image of the `base` property after caching.
        
        return URLSessionDownloadTask()
    }
}
