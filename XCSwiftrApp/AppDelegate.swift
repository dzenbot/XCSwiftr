//
//  AppDelegate.swift
//  XCSwiftrApp
//
//  Created by Ignacio Romero on 4/3/16.
//  Copyright © 2016 DZN Labs. All rights reserved.
//

import Cocoa

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {

    var mainWindowController: XCSConverterWindowController!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        self.mainWindowController = XCSConverterWindowController(windowNibName: "XCSConverterWindowController")
        self.mainWindowController.window?.makeKeyAndOrderFront(self)
    }

    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
}

