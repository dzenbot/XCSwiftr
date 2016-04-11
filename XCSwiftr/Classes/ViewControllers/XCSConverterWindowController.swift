//
//  XCSConverterWindowController.swift
//  XCSwiftr
//
//  Created by Ignacio Romero on 4/3/16.
//  Copyright © 2016 DZN Labs. All rights reserved.
//

import Cocoa

private let XCSwifterDomain = "com.dzn.XCSwiftr"

extension Bool {
    init<T : IntegerType>(_ integer: T){
        self.init(integer != 0)
    }
}

class XCSConverterWindowController: NSWindowController, NSTextViewDelegate {
    
    let commandController = XCSCommandController()
    let snippetManager = XCSSnippetManager(domain: XCSwifterDomain)
    
    var initialText: String?
    
    var inPlugin: Bool = false
    var autoConvert: Bool = false
    
    #if PLUGIN
    @IBOutlet var primaryTextView: DVTSourceTextView!
    @IBOutlet var secondaryTextView: DVTSourceTextView!
    #else
    @IBOutlet var primaryTextView: NSTextView!
    @IBOutlet var secondaryTextView: NSTextView!
    #endif
    
    @IBOutlet var autoCheckBox: NSButton!
    @IBOutlet var cancelButton: NSButton!
    @IBOutlet var acceptButton: NSButton!
    
    @IBOutlet var progressIndicator: NSProgressIndicator!

    var loading: Bool = false {
        didSet {
            if loading {
                self.progressIndicator.startAnimation(self)
                self.acceptButton.title = ""
            }
            else {
                self.progressIndicator.stopAnimation(self)
                self.acceptButton.title = "Convert"
            }
        }
    }
    
    
    // MARK: View lifecycle

    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        primaryTextView.delegate = self
        primaryTextView.string = ""
        secondaryTextView.string = ""
        
        if let string = initialText {
            primaryTextView.string = initialText
            
            convertToSwift(string)
            updateAcceptButton()
        }
        
        if inPlugin == true {
            cancelButton.hidden = false
        }
    }
    
    
    // MARK: Actions

    func convertToSwift(objcString: String?) {
        
        guard let objcString = objcString else { return }
        
        loading = true
        
        snippetManager.cacheTemporary(objcString) { (filePath) in
            
            if let path = filePath {
                self.commandController.objc2Swift(path) { (result) in
                    
                    self.loading = false
                    self.secondaryTextView.string = result
                }
            }
        }
    }
    
    func updateAcceptButton() {
        acceptButton.enabled = (primaryTextView.string?.characters.count > 0)
    }
    
    
    // MARK: IBActions

    @IBAction func convertAction(sender: AnyObject) {
        
        convertToSwift(primaryTextView.string)
    }
    
    @IBAction func dismissAction(sender: AnyObject) {
        
        guard let window = window, let sheetParent = window.sheetParent else { return }
        
        sheetParent.endSheet(window, returnCode: NSModalResponseCancel)
    }
    
    @IBAction func autoConvert(sender: AnyObject) {
        
        autoConvert = Bool(autoCheckBox.state)
    }
    
    // MARK: NSTextViewDelegate
    
    func textDidChange(notification: NSNotification) {
        updateAcceptButton()
    }
}