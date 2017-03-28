//
//  XCSCommandController.swift
//  XCSwiftr
//
//  Created by Ignacio Romero on 4/3/16.
//  Copyright © 2016 DZN Labs. All rights reserved.
//

import Foundation

open class XCSCommandController: NSObject {

    fileprivate var scriptName = "objc2swift"
    fileprivate var scriptVersion = "1.0"

    open func objc2Swift(_ objcPath: String, completion: @escaping ((String) -> Void)) {

        let bundle = Bundle(for: XCSCommandController.self)

        var scriptPath = ""

        if let path = bundle.path(forResource: "\(scriptName)-\(scriptVersion)", ofType: "jar") {
            scriptPath = path
        }

        let args: [String] = ["-jar", scriptPath, objcPath]

        return self.runJavaWithArguments(args, completion: completion)
    }

    fileprivate func runJavaWithArguments(_ arguments: [String], completion: @escaping ((String) -> Void)) {

        isJDKInstalled { (available) in
            if available == true {
                return self.runWithLaunchPath("/usr/bin/java", arguments: arguments, completion: completion)
            } else {
                completion("JDK is not available. Please download and install from http://www.oracle.com/technetwork/java/javase/downloads/index.html")
            }
        }
    }

    fileprivate func runBashWithArguments(_ arguments: [String], completion: @escaping ((String) -> Void)) {
        return self.runWithLaunchPath("/bin/sh", arguments: arguments, completion: completion)
    }

    fileprivate func runWithLaunchPath(_ launchPath: String, arguments: [String], completion: @escaping ((String) -> Void)) {

        DispatchQueue.global(qos: .default).async {

            let task = Process()
            task.launchPath = launchPath
            task.arguments = arguments

            let outputPipe = Pipe()
            let errorPipe = Pipe()

            task.standardOutput = outputPipe
            task.standardError = errorPipe

            let outputFileHandler = outputPipe.fileHandleForReading
            let errorFileHandler = errorPipe.fileHandleForReading

            task.terminationHandler = { (task: Process) in print("termination reason : \(task.terminationReason) | termination status : \(task.terminationStatus)") }
            task.launch()

            let outputData = outputFileHandler.readDataToEndOfFile()
            let errorData = errorFileHandler.readDataToEndOfFile()

            var result = ""

            if outputData.count > 0 {
                result = String(data: outputData, encoding: String.Encoding.utf8)!
            } else if errorData.count > 0 {
                result = String(data: errorData, encoding: String.Encoding.utf8)!
            } else {
                result = "Unkown error!"
            }

            DispatchQueue.main.async {

                completion(result)
            }
        }
    }

    fileprivate func isJDKInstalled(_ completion: @escaping ((Bool) -> Void)) {

        let args = ["-version"]

        self.runBashWithArguments(args) { (result) in

            print(result)

            if result.lowercased().range(of: "cannot execute binary file") != nil {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
