//
//  DiskCache.swift
//  OlafImageCacher
//
//  Created by 신한섭 on 2020/09/21.
//

import Foundation

public class DiskCache {
    
    private let fileManager = FileManager.default
    private var keys: Set<String> = Set<String>()
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
        guard let fileURL = cacheURL(forKey: key) else {
            return
        }
        
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
        
        keys.insert(key)
    }
}

public enum OlafImageCacherError: Error {
    case dataWriteError(String)
    case cachingError(String)
}
