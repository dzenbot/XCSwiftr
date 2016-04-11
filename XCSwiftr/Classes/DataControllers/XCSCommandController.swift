//
//  XCSCommandController.swift
//  XCSwiftr
//
//  Created by Ignacio Romero on 4/3/16.
//  Copyright © 2016 DZN Labs. All rights reserved.
//

import Foundation

public class XCSCommandController: NSObject {
    
    private var scriptName = "objc2swift"
    private var scriptVersion = "1.0"
    
    public func objc2Swift(objcPath: String, completion: ((String) -> Void)) {
        
        let bundle = NSBundle(forClass: XCSCommandController.self)
        
        var scriptPath = ""
        
        if let path = bundle.pathForResource("\(scriptName)-\(scriptVersion)", ofType: "jar") {
            scriptPath = path
        }
        
        let args: [String] = ["-jar", scriptPath, objcPath]
        
        return self.runJavaWithArguments(args, completion: completion)
    }
    
    private func runJavaWithArguments(arguments: [String], completion: ((String) -> Void)) {
        
        isJDKInstalled { (available) in
            if available == true {
                return self.runWithLaunchPath("/usr/bin/java", arguments: arguments, completion: completion)
            }
            else {
                completion("JDK is not available. Please download and install from http://www.oracle.com/technetwork/java/javase/downloads/index.html")
            }
        }
    }
    
    private func runBashWithArguments(arguments: [String], completion: ((String) -> Void)) {
        return self.runWithLaunchPath("/bin/sh", arguments: arguments, completion: completion)
    }
    
    private func runWithLaunchPath(launchPath: String, arguments: [String], completion: ((String) -> Void)) {

        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            let task = NSTask()
            task.launchPath = launchPath
            task.arguments = arguments
                        
            let outputPipe = NSPipe()
            let errorPipe = NSPipe()
            
            task.standardOutput = outputPipe
            task.standardError = errorPipe
            
            let outputFileHandler = outputPipe.fileHandleForReading
            let errorFileHandler = errorPipe.fileHandleForReading
            
            task.terminationHandler = { (task: NSTask) in print("termination reason : \(task.terminationReason) | termination status : \(task.terminationStatus)") }
            task.launch()
            
            let outputData = outputFileHandler.readDataToEndOfFile()
            let errorData = errorFileHandler.readDataToEndOfFile()
            
            var result = ""
            
            if outputData.length > 0 {
                result = String(data: outputData, encoding: NSUTF8StringEncoding)!
            }
            else if errorData.length > 0 {
                result = String(data: errorData, encoding: NSUTF8StringEncoding)!
            }
            else {
                result = "Unkown error!"
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                
                completion(result)
            }
        }
    }
    
    private func isJDKInstalled(completion: ((Bool) -> Void)) {
        
        let args = ["-version"]
        
        self.runBashWithArguments(args) { (result) in
            
            print(result)
            
            if result.lowercaseString.rangeOfString("cannot execute binary file") != nil {
                completion(false)
            }
            else {
                completion(true)
            }
        }
    }
}