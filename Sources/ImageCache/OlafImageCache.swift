//
//  OlafImageCache.swift
//  OlafImageCacher
//
//  Created by 신한섭 on 2020/09/23.
//

import UIKit

@available(iOS 10.0, *)
public class OlafImageCache {
    
    public static let `default` = OlafImageCache(name: "OlafImageCache")
    public var memoryCache: MemoryCache
    public var diskCache: DiskCache
    private let ioQueue: DispatchQueue = DispatchQueue(label: "OlafImageCacher.\(UUID().uuidString)")
    
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
    
    public func store(_ data: Data, forKey key: String, toDisk: Bool = true, completionHandler: @escaping ((CacheStoreResult) -> ())) {
        var cacheResult = CacheStoreResult(memoryCacheError: .success(()), diskCacheError: .success(()))
        
        if let image = UIImage(data: data) {
            memoryCache.store(image: image, forKey: NSString(string: key))
        } else {
            cacheResult = CacheStoreResult(memoryCacheError: .failure(.convertDataToImageError(key)), diskCacheError: .failure(.cachingError(key)))
        }
        
        guard toDisk else {
            completionHandler(cacheResult)
            return
        }
        
        ioQueue.async { [weak self] in
            do {
                try self?.diskCache.store(data: data, forKey: key)
                completionHandler(cacheResult)
            } catch {
                cacheResult = CacheStoreResult(memoryCacheError: .success(()), diskCacheError: .failure(.cachingError(key)))
                completionHandler(cacheResult)
            }
        }
    }
    
    public func isCached(forKey key: String) -> CacheType {
        if memoryCache.isCached(forKey: NSString(string: key)) {
            return .memory
        }
        
        do {
            if try diskCache.isCached(forKey: key) {
                return .disk
            }
        } catch {
            return .none
        }
        
        return .none
    }
    
    public func image(forKey key: String) -> ImageCacheResult {
        let cachedReulst = isCached(forKey: key)
        
        switch cachedReulst {
        case .memory:
            guard let image = memoryCache.image(forKey: NSString(string: key))?.image else { return .none }
            return .memory(image)
        case .disk:
            do {
                guard let data = try diskCache.data(forKey: key, expiration: .never) else { return .none }
                guard let image = UIImage(data: data) else { return .none }
                return .disk(image)
            } catch {
                return .none
            }
        case .none:
            return .none
        }
    }
}

@available(iOS 10.0, *)
extension OlafImageCache {
    public struct CacheStoreResult {
        let memoryCacheError: Result<(), OlafImageCacherError>
        let diskCacheError: Result<(), OlafImageCacherError>
    }
    
    public enum CacheType {
        case memory
        case disk
        case none
        
        public var result: Bool {
            switch self {
            case .memory, .disk:
                return true
            case .none:
                return false
            }
        }
    }
    
    public enum ImageCacheResult {
        case memory(UIImage)
        case disk(UIImage)
        case none
        
        public var image: UIImage? {
            switch self {
            case .memory(let image):
                return image
            case .disk(let image):
                return image
            case .none:
                return nil
            }
        }
        
        public var cacheType: CacheType {
            switch self {
            case .memory:
                return .memory
            case .disk:
                return .disk
            case .none:
                return .none
            }
        }
    }
    
}
