
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

#import "XcodeHeaders.h"

@interface XcodeHelpers : NSObject

+ (NSWindow *)currentWindow;
+ (NSResponder *)currentWindowResponder;
+ (NSMenu *)mainMenu;
+ (IDEWorkspaceWindowController *)currentWorkspaceWindowController;
+ (IDEEditorArea *)currentEditorArea;
+ (IDEEditorContext *)currentEditorContext;
+ (IDEEditor *)currentEditor;
+ (IDESourceCodeDocument *)currentSourceCodeDocument;
+ (IDESourceCodeDocument *)mainSourceCodeDocument;
+ (NSString *)mainSourceCodeFilename;
+ (DVTSourceTextView *)currentSourceTextView;
+ (DVTTextStorage *)currentTextStorage;
+ (NSScrollView *)currentScrollView;

+ (NSMenuItem *)getMainMenuItemWithTitle:(NSString *)title;

+ (void)enableHighlighting:(BOOL)enable forTextView:(DVTSourceTextView *)textView;

@end
