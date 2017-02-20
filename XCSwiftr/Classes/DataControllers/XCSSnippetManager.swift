//
//  XCSSnippetManager.swift
//  XCSwiftr
//
//  Created by Ignacio Romero on 4/4/16.
//  Copyright © 2016 DZN Labs. All rights reserved.
//

import Foundation

public class XCSSnippetManager: NSObject {

    var domain = ""

    init(domain: String) {
        self.domain = domain
    }

    public func cacheTemporary(snippet: String, completion: @escaping ((String?) -> Void)) {

        let filePath = getTempDirectory().appendingPathComponent("temp_objc.m")
        
        DispatchQueue.global(qos: .default).async {
            do {
                try snippet.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)

                DispatchQueue.main.async {
                    completion(filePath)
                }
            } catch {
                print("Failed saving file at path \(filePath)")

                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }

    private func getCacheDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        return paths[0] as NSString
    }

    private func getTempDirectory() -> NSString {

        let fileManager = FileManager.default
        let cachePath = getCacheDirectory()

        if self.domain.characters.count == 0 {
            return cachePath
        }

        let filePath = getCacheDirectory().appendingPathComponent(self.domain)

        if fileManager.fileExists(atPath: filePath) == false {
            do {
                try fileManager.createDirectory(atPath: filePath, withIntermediateDirectories: false, attributes: nil)
            } catch {
                print("Failed creating directory at path \(filePath)")
            }
        }

        return filePath as NSString
    }
}
