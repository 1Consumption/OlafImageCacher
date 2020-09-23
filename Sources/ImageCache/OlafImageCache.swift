//
//  OlafImageCache.swift
//  OlafImageCacher
//
//  Created by 신한섭 on 2020/09/23.
//

import Foundation

@available(iOS 10.0, *)
public class OlafImageCache {
    
    public static let `default` = OlafImageCache(name: "OlafImageCache")
    public var memoryCache: MemoryCache
    public var diskCache: DiskCache
    
    public init(memoryCache: MemoryCache, diskCache: DiskCache) {
        self.memoryCache = memoryCache
        self.diskCache = diskCache
        setObserver()
    }
    
    convenience init(name: String) {
        let totalMemeory = ProcessInfo.processInfo.physicalMemory
        let memoryCacheConfig = MemoryCache.Config(countLimit: .max,
                                                   totalCostLimit: Int(totalMemeory) / 4,
                                                   expirationDate: .minutes(5),
                                                   cleanInterval: 120)
        let memoryCache = MemoryCache(config: memoryCacheConfig)
        let diskCache = try! DiskCache(cacheName: name)
        
        self.init(memoryCache: memoryCache, diskCache: diskCache)
    }
    
    private func setObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(removeExpiredImage),
                                               name: UIApplication.didReceiveMemoryWarningNotification,
                                               object: nil)
    }
    
    @objc public func removeExpiredImage() {
        memoryCache.cleanExpiredImage()
    }
}
