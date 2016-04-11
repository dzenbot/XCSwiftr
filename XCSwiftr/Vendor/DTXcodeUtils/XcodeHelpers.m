
#import "XcodeHelpers.h"

@implementation XcodeHelpers

+ (NSWindow *)currentWindow {
  return [[NSApplication sharedApplication] keyWindow];
}

+ (NSResponder *)currentWindowResponder {
  return [[self currentWindow] firstResponder];
}

+ (NSMenu *)mainMenu {
  return [NSApp mainMenu];
}

+ (NSMenuItem *)getMainMenuItemWithTitle:(NSString *)title {
  return [[self mainMenu] itemWithTitle:title];
}

+ (void)enableHighlighting:(BOOL)enable forTextView:(DVTSourceTextView *)textView
{
    DVTTextStorage *storage = (DVTTextStorage *)textView.textStorage;
    storage.syntaxColoringEnabled = enable;
    
    NSLog(@"storage : %@", storage);
    NSLog(@"textView : %@", textView);

    [textView setNeedsDisplay:YES];
}

+ (IDEWorkspaceWindowController *)currentWorkspaceWindowController {
  NSWindowController *result = [self currentWindow].windowController;
  if ([result isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
    return (IDEWorkspaceWindowController *)result;
  }
  return nil;
}

+ (IDEEditorArea *)currentEditorArea {
  return [self currentWorkspaceWindowController].editorArea;
}

+ (IDEEditorContext *)currentEditorContext {
  return [self currentEditorArea].lastActiveEditorContext;
}

+ (IDEEditor *)currentEditor {
  return [self currentEditorContext].editor;
}

+ (IDESourceCodeDocument *)currentSourceCodeDocument {
  if ([[self currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
    return ((IDESourceCodeEditor *)[self currentEditor]).sourceCodeDocument;
  } else if ([[self currentEditor] isKindOfClass:
      NSClassFromString(@"IDESourceCodeComparisonEditor")]) {
    IDEEditorDocument *document =
        ((IDESourceCodeComparisonEditor *)[self currentEditor]).primaryDocument;
    if ([document isKindOfClass:NSClassFromString(@"IDESourceCodeDocument")]) {
      return (IDESourceCodeDocument *)document;
    }
  }
  return nil;
}

+ (IDESourceCodeDocument *)mainSourceCodeDocument
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    NSArray *controllers = (NSArray *)[NSClassFromString(@"IDEWorkspaceWindowController") performSelector:@selector(workspaceWindowControllers)];
    NSWindow *keyWindow = [NSApplication sharedApplication].keyWindow;
    
    if ([keyWindow isKindOfClass:NSClassFromString(@"IDEWorkspaceWindow")]) {
        for (IDEWorkspaceWindowController *windowController in controllers)
        {
            if ([windowController.window isEqual:keyWindow]) {
                
                id editorArea = nil;
                id document = nil;
                
                @try { editorArea = [windowController performSelector:@selector(editorArea)]; }
                @catch (NSException *exception) { return nil; }
                
                @try { document = [editorArea performSelector:@selector(primaryEditorDocument)]; }
                @catch (NSException *exception) { return nil; }
                
                return document;
            }
        }
    }
    
    return nil;
    
#pragma clang diagnostic pop
}

+ (NSString *)mainSourceCodeFilename
{
    IDESourceCodeDocument *document = [self mainSourceCodeDocument];
    
    if (document) {
        NSString *filePath = document.fileURL.absoluteString;
        return filePath.lastPathComponent;
    }
    
    return nil;
}

+ (DVTSourceTextView *)currentSourceTextView {
  if ([[self currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
    return ((IDESourceCodeEditor *)[self currentEditor]).textView;
  } else if ([[self currentEditor] isKindOfClass:
      NSClassFromString(@"IDESourceCodeComparisonEditor")]) {
    return ((IDESourceCodeComparisonEditor *)[self currentEditor]).keyTextView;
  }
  return nil;
}

+ (DVTTextStorage *)currentTextStorage {
  NSTextView *textView = [self currentSourceTextView];
  if ([textView.textStorage isKindOfClass:NSClassFromString(@"DVTTextStorage")]) {
    return (DVTTextStorage *)textView.textStorage;
  }
  return nil;
}

+ (NSScrollView *)currentScrollView {
  NSView *view = [self currentSourceTextView];
  return [view enclosingScrollView];
}

@end
