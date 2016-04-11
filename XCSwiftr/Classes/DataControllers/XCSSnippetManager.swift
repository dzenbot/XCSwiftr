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
    
    public func cacheTemporary(snippet: String, completion: ((String?) -> Void)) {
        
        let filePath = getTempDirectory().stringByAppendingPathComponent("temp_objc.m")
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            do {
                try snippet.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
                
                dispatch_async(dispatch_get_main_queue()) {
                    completion(filePath)
                }
            }
            catch {
                print("Failed saving file at path \(filePath)")
                
                dispatch_async(dispatch_get_main_queue()) {
                    completion(nil)
                }
            }
        }
    }
    
    private func getCacheDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        return paths[0]
    }
    
    private func getTempDirectory() -> NSString {
        
        let fileManager = NSFileManager.defaultManager()
        let cachePath = getCacheDirectory()
        
        if self.domain.characters.count == 0 {
            return cachePath
        }
        
        let filePath = getCacheDirectory().stringByAppendingPathComponent(self.domain)
        
        if fileManager.fileExistsAtPath(filePath) == false {
            do {
                try fileManager.createDirectoryAtPath(filePath, withIntermediateDirectories: false, attributes: nil)
            }
            catch {
                print("Failed creating directory at path \(filePath)")
            }
        }
        
        return filePath
    }
}
