//
//  ExpirableImage.swift
//  OlafImageCacher
//
//  Created by 신한섭 on 2020/09/20.
//

import UIKit

public class ExpirableImage {
    
    private var expirationDate: Date
    public let image: UIImage
    
    public init(image: UIImage, expiration: Expiration) {
        self.image = image
        expirationDate = expiration.expirationDateFromNow
    }
    
    // Returns `true` if the expiration date has passed.
    public func isExpired() -> Bool {
        return expirationDate < Date()
    }
    
    // To reset the expiration date when the image has been used
    public func modifyExpirationDate(expiration: Expiration) {
        expirationDate = expiration.expirationDateFromNow
    }
}
