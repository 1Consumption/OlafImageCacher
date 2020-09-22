//
//  DiskCache.swift
//  OlafImageCacher
//
//  Created by 신한섭 on 2020/09/21.
//

import Foundation

public class DiskCache {
    
    private let fileManager = FileManager.default
    private var cacheDirectory: URL?
    
    public init(cacheName: String) throws {
        try createCacheDirectory(directoryName: cacheName)
    }
    
    private func createCacheDirectory(directoryName: String) throws {
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        try fileManager.createDirectory(at: documentDirectory.appendingPathComponent(directoryName), withIntermediateDirectories: true, attributes: nil)
        cacheDirectory = documentDirectory.appendingPathComponent(directoryName)
    }
    
    private func cacheURL(forKey key: String) -> URL? {
        return cacheDirectory?.appendingPathComponent(key)
    }
    
    public func store(data: Data, forKey key: String, expiration: Expiration = .never) throws {
        guard let fileURL = cacheURL(forKey: key) else { return }
        
        do {
            try data.write(to: fileURL)
        } catch {
            throw OlafImageCacherError.dataWriteError(fileURL.path)
        }
        
        let attributes: [FileAttributeKey : Date] = [
            .creationDate: Date(),
            .modificationDate: expiration.expirationDateFromNow
        ]
        
        do {
            try fileManager.setAttributes(attributes, ofItemAtPath: fileURL.path)
        } catch {
            try? fileManager.removeItem(at: fileURL)
            throw OlafImageCacherError.cachingError(fileURL.path)
        }
    }
    
    public func data(forKey key: String, expiration: Expiration) throws -> Data?  {
        guard let fileURL = cacheURL(forKey: key) else { return nil }
        let filePath = fileURL.path
        
        guard fileManager.fileExists(atPath: filePath) else { return nil }
        
        let resourceKeys: Set<URLResourceKey> = [.contentModificationDateKey]
        var expectedExpiration: Date
        do {
            expectedExpiration = try fileURL.resourceValues(forKeys: resourceKeys).contentModificationDate ?? .distantPast
        } catch {
            throw OlafImageCacherError.getModificationDateError(filePath)
        }
        
        guard expectedExpiration > Date() else { return nil }
        
        do {
            let data = try Data(contentsOf: fileURL)
            resetExpirationDate(forPath: filePath, expiration: expiration)
            
            return data
        } catch {
            throw OlafImageCacherError.getDataFromURLError(filePath)
        }
    }
    
    private func resetExpirationDate(forPath path: String, expiration: Expiration) {
        let attribute: [FileAttributeKey: Date] = [.modificationDate: expiration.expirationDateFromNow]
        try? fileManager.setAttributes(attribute, ofItemAtPath: path)
    }
    
    public func remove(forkey key: String) throws {
        guard let fileURL = cacheURL(forKey: key) else { return }
        
        try remove(forURL: fileURL)
    }
    
    public func remove(forURL url: URL) throws {
        do {
            try fileManager.removeItem(at: url)
        } catch {
            throw OlafImageCacherError.deleteDiskCacheError(url.path)
        }
    }
    
    public func removeAll() throws {
        guard let cacheDirectory = cacheDirectory else { return }
        do {
            try fileManager.removeItem(at: cacheDirectory)
        } catch {
            throw OlafImageCacherError.deleteDiskCacheAllError
        }
    }
    
    public func removeExpiredData() throws {
        guard let cacheDirectory = cacheDirectory else { return }
        guard let urls = fileManager.enumerator(at: cacheDirectory, includingPropertiesForKeys: [.contentModificationDateKey])?.allObjects as? [URL] else { return }
        
        let resourceKey: Set<URLResourceKey> = [.contentModificationDateKey]
        
        urls.filter { fileURL in
            do {
                guard let expirationDate = try fileURL.resourceValues(forKeys: resourceKey).contentModificationDate else { return true }
                return expirationDate <= Date()
            } catch {
                return true
            }
        }.forEach {
            try? remove(forURL: $0)
        }
    }
}

public enum OlafImageCacherError: Error {
    case dataWriteError(String)
    case cachingError(String)
    case getModificationDateError(String)
    case getDataFromURLError(String)
    case deleteDiskCacheError(String)
    case deleteDiskCacheAllError
}
