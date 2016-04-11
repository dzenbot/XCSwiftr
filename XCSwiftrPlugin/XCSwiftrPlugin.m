//
//  XCSwiftrPlugin.m
//  XCSwiftr
//
//  Created by Ignacio Romero on 4/4/16.
//  Copyright © 2016 DZN Labs. All rights reserved.
//

#import "XCSwiftrPlugin.h"
#import "XcodeHelpers.h"

#import "XCSwiftr-Swift.h"

static XCSwiftrPlugin *_sharedPlugin;

static NSString * const kNavigateTitle =            @"Navigate";
static NSString * const kProjectNavigatorTitle =    @"Reveal in Project Navigator";
static NSString * const kConvertToTitle =           @"Convert to Swift";

@interface XCSwiftrPlugin() <NSWindowDelegate>
@property (nonatomic, strong) XCSConverterWindowController *windowController;
@end

@implementation XCSwiftrPlugin

+ (void)pluginDidLoad:(nullable NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *bundleName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    
    if ([bundleName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            _sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

- (nullable instancetype)initWithBundle:(nullable NSBundle *)plugin
{
    self = [super init];
    if (self) {
        self.bundle = plugin;
        
        // Listen to menu tracking to hook up the contextual menu
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidBeginTracking:) name:NSMenuDidBeginTrackingNotification object:nil];
    }
    return self;
}


#pragma mark - Getters

+ (nullable instancetype)sharedPlugin
{
    return _sharedPlugin;
}

- (nullable NSString *)selectedText
{
    NSTextView *sourceTextView = [XcodeHelpers currentSourceTextView];
    
    if (sourceTextView && [sourceTextView isKindOfClass:NSClassFromString(@"DVTSourceTextView")]) {
        return [[sourceTextView string] substringWithRange:[sourceTextView selectedRange]];
    }
    return nil;
}

- (nullable NSString *)initialText
{
    NSMutableString *text = [self.selectedText mutableCopy];
    NSString *documentName = [XcodeHelpers mainSourceCodeFilename];
    NSString *className = [documentName stringByDeletingPathExtension];

    NSRange interfaceRange = [text rangeOfString:@"@interface"];
    NSRange implementationRange = [text rangeOfString:@"@implementation"];
    
    // Wraps the selected text into an obj-c @implementation if needed
    if (implementationRange.location == NSNotFound) {
        
        NSString *implementation = [NSString stringWithFormat:@"\r@implementation %@\r", className];
        [text insertString:implementation atIndex:0];
        [text appendString:@"\r\r@end"];
    }
    
    // Wraps the selected text into an obj-c @interface if needed
    if (interfaceRange.location == NSNotFound) {
        
        NSString *interface = [NSString stringWithFormat:@"\r@interface %@ : NSObject\r@end\r\r", className];
        [text insertString:interface atIndex:0];
    }
    
    return text;
}

- (BOOL)canConvertToSwift
{
    NSString *documentName = [XcodeHelpers mainSourceCodeFilename];
    
    return [@[@"h", @"m"] containsObject:documentName.pathExtension];
}

- (nullable id)menuTarget
{
    return (self.selectedText.length > 1) ? self : nil;
}


#pragma mark - Menu

- (void)configureMenuIfNeeded:(nonnull NSMenu *)menu
{
    if (![self canConvertToSwift]) {
        return;
    }
    
    NSMenu *submenu = nil;
    
    if ([menu itemWithTitle:kProjectNavigatorTitle]) {
        submenu = menu;
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (submenu) {
            id target = [self menuTarget];
            NSInteger idx = [self appropriateIndexInMenu:menu];
            
            // Fetch the Menu Item, if available
            NSMenuItem *menuItem = [submenu itemWithTitle:kConvertToTitle];
            
            // Configure Menu Item
            if (!menuItem) {
                menuItem = [[NSMenuItem alloc] initWithTitle:kConvertToTitle action:@selector(presentConverter:) keyEquivalent:@""];
                menuItem.target = target;
            }
            else {
                menuItem.target = target;
            }
            
            [submenu insertItem:menuItem atIndex:idx];
        }
    });
}

- (NSInteger)appropriateIndexInMenu:(nonnull NSMenu *)menu
{
    if ([menu itemWithTitle:kNavigateTitle]) {
        NSMenuItem *menuItem = [menu itemWithTitle:kNavigateTitle];
        
        NSInteger idx = [[menuItem submenu] indexOfItemWithTitle:kProjectNavigatorTitle];
        
        // So the title is above 'Open in Assistant Editor'
        idx += 3;
        
        return idx;
    }
    else {
        NSInteger idx = [menu indexOfItemWithTitle:kProjectNavigatorTitle];
        NSMenuItem *item = [menu itemAtIndex:idx];
        
        while ([item isSeparatorItem]) {
            idx--;
            item = [menu itemAtIndex:idx];
        }
        
        // So the title is above 'Open in Assistant Editor'
        idx-=2;
        
        return idx;
    }
}


#pragma mark - Events

- (void)menuDidBeginTracking:(nonnull NSNotification *)notification
{
    id object = notification.object;
    id name = notification.name;
    
    if ([name isEqualToString:NSMenuDidBeginTrackingNotification]) {
        if ([object isKindOfClass:[NSMenu class]]) {
            [self configureMenuIfNeeded:object];
        }
    }
}

- (void)presentConverter:(nonnull NSMenuItem *)menuItem
{
    NSTextView *sourceTextView = [XcodeHelpers currentSourceTextView];
    
    NSRange selectedRange = sourceTextView.selectedRange;
    
    // Setup content
    if (!_windowController) {
        _windowController = [[XCSConverterWindowController alloc] initWithWindowNibName:@"XCSConverterWindowController"];
        _windowController.inPlugin = YES;
    }
    
    [self.windowController setInitialText:self.initialText];

    // Deselects the text in Xcode
    sourceTextView.selectedRange = NSMakeRange(selectedRange.location, 0);
    
    NSWindow *keyWindow = [NSApplication sharedApplication].keyWindow;
    NSWindow *modalWindow = self.windowController.window;
    
    NSRect keyWindowFrame = keyWindow.frame;
    NSRect windowFrame = NSZeroRect;
    CGFloat margin = 40.0;
    
    windowFrame.origin = NSMakePoint(CGRectGetMinX(keyWindowFrame) - margin,0.0);
    windowFrame.size.width = CGRectGetWidth(keyWindowFrame) - (margin * 2.0);
    windowFrame.size.height = CGRectGetHeight(keyWindowFrame) - (margin * 6.0);
    
    [modalWindow setFrame:windowFrame display:YES];
    
    [keyWindow beginSheet:modalWindow completionHandler:^(NSModalResponse returnCode) {
        
        _windowController = nil;
    }];
}

- (void)dealloc
{
    _bundle = nil;
    _sharedPlugin = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
