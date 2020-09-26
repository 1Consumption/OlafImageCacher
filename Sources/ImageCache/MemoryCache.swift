//
//  MemoryCache.swift
//  OlafImageCacher
//
//  Created by 신한섭 on 2020/09/19.
//

import UIKit

@available(iOS 10.0, *)
public class MemoryCache {
    
    private let storage: NSCache<NSString, ExpirableImage> = NSCache<NSString, ExpirableImage>()
    // To prevent access while writing to memory.
    // e.g. store, remove
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
    private let expirationDate: Expiration
    private var keys: Set<NSString> = Set<NSString>()
    // A timer that allows you to clear caches that have expired during a certain interval
    private var timer: Timer?
    
    public init(config: Config) {
        storage.countLimit = config.countLimit
        storage.totalCostLimit = config.totalCostLimit
        expirationDate = config.expirationDate
        timer = .scheduledTimer(withTimeInterval: config.cleanInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.cleanExpiredImage()
        }
    }
    
    public func cleanExpiredImage() {
        semaphore.wait()
        defer { semaphore.signal() }
        
        keys.forEach {
            if let image = storage.object(forKey: $0) {
                if image.isExpired() {
                    keys.remove($0)
                    storage.removeObject(forKey: $0)
                }
            } else {
                keys.remove($0)
            }
        }
    }
    
    public func store(image: UIImage, forKey key: NSString) {
        semaphore.wait()
        defer { semaphore.signal() }
        
        let expirableImage = ExpirableImage(image: image, expiration: expirationDate)
        storage.setObject(expirableImage, forKey: key)
        keys.insert(key)
    }
    
    public func remove(forKey key: NSString) {
        semaphore.wait()
        defer { semaphore.signal() }
        
        storage.removeObject(forKey: key)
        keys.remove(key)
    }
    
    public func removeAll() {
        semaphore.wait()
        defer { semaphore.signal() }
        
        storage.removeAllObjects()
        keys.removeAll()
    }
    
    public func image(forKey key: NSString) -> ExpirableImage? {
        guard let expirableImage = storage.object(forKey: key) else { return nil }
        guard !expirableImage.isExpired() else { return nil }
        
        expirableImage.modifyExpirationDate(expiration: expirationDate)
        
        return expirableImage
    }
    
    public func isCached(forKey key: NSString) -> Bool {
        guard let _ = image(forKey: key) else {
            return false
        }
        return true
    }
}

@available(iOS 10.0, *)
extension MemoryCache {
    public struct Config {
        
        public var countLimit: Int
        public var totalCostLimit: Int
        public var expirationDate: Expiration
        public var cleanInterval: TimeInterval
    }
}
