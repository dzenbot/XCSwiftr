
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

@interface DVTTextStorage : NSTextStorage

@property(readonly) id languageService;
/** Whether to syntax highlight the current editor */
@property(getter=isSyntaxColoringEnabled) BOOL syntaxColoringEnabled;

/** Converts from a character number in the text to a line number */
- (NSRange)lineRangeForCharacterRange:(NSRange)characterRange;

/** Converts from a line number in the text to a character number */
- (NSRange)characterRangeForLineRange:(NSRange)lineRange;

@end

@interface DVTCompletingTextView : NSTextView
@end

@interface DVTSourceTextView : DVTCompletingTextView
@end

@interface DVTViewController : NSViewController
@end

@interface IDEViewController : DVTViewController
@end

@interface IDEEditorDocument : NSDocument
@end

@interface IDESourceCodeDocument : IDEEditorDocument
@end

@class IDEEditorContext;
@interface IDEEditorArea : IDEViewController
@property(retain, nonatomic) IDEEditorContext *lastActiveEditorContext;
@property(retain, nonatomic) IDESourceCodeDocument *primaryEditorDocument;
@end

@interface IDEEditor : IDEViewController
@end

@interface IDEEditorContext : IDEViewController
@property(retain, nonatomic) IDEEditor *editor;
@property(retain, nonatomic) IDEEditorArea *editorArea;
@end

@interface IDESourceCodeEditor : IDEEditor
@property(readonly) IDESourceCodeDocument *sourceCodeDocument;
@property(retain) DVTSourceTextView *textView;
@end

@interface IDEComparisonEditor : IDEEditor
@property(retain) IDEEditorDocument *secondaryDocument;
@property(retain) IDEEditorDocument *primaryDocument;
@end

@interface IDESourceCodeComparisonEditor : IDEComparisonEditor
@property(readonly) DVTSourceTextView *keyTextView;
@end

@interface IDEWorkspaceWindowController : NSWindowController
@property(readonly) IDEEditorArea *editorArea;
@property(readonly) NSArray *workspaceWindowControllers;
@end

@interface IDEWorkspaceWindow : NSWindow
@end
