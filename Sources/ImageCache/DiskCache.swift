//
//  DiskCache.swift
//  OlafImageCacher
//
//  Created by 신한섭 on 2020/09/21.
//

import Foundation

public class DiskCache {
    
    private let fileManager = FileManager.default
    private var keys: Set<NSString> = Set<NSString>()
    private var cacheDirectory: URL?
    
    public init(cacheName: String) throws {
        try createCacheDirectory(directoryName: cacheName)
    }
    
    private func createCacheDirectory(directoryName: String) throws {
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        try fileManager.createDirectory(at: documentDirectory.appendingPathComponent(directoryName), withIntermediateDirectories: true, attributes: nil)
        cacheDirectory = documentDirectory.appendingPathComponent(directoryName)
    }
}
