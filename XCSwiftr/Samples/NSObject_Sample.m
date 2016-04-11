#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface CommandController : NSObject

+ (nonnull NSString *)objc2Swift:(nullable NSString *)objc;

@end

@implementation CommandController

static NSString *scriptName = @"objc2swift";

// Verify that JDK is installed
+ (BOOL)isJDKInstalled
{
    NSString *result = [self runBashWithArguments:@[@"java", @"-version"]];
    
    if ([result rangeOfString:@"cannot execute binary file"].location != NSNotFound) {
        return NO;
    }
    
    return result ? YES : NO;
}

+ (nonnull NSString *)objc2Swift:(nullable NSString *)objcPath
{
    //    if ([self isJDKInstalled] == NO) {
    //        return @"*** Java Development Kit (JDK) is required.\n"
    //        @"Download from http://www.oracle.com/technetwork/java/javase/downloads/index.html";
    //    }
    
    NSString *scriptPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@-1.0", scriptName] ofType:@"jar"];
    NSArray *args = @[@"-jar", scriptPath, objcPath];
    
    return [self runJavaWithArguments:args];
}

+ (nonnull NSString *)runJavaWithArguments:(nullable NSArray *)arguments
{
    return [self runWithLaunchPath:@"/usr/bin/java" withArguments:arguments];
}

+ (nonnull NSString *)runBashWithArguments:(nullable NSArray *)arguments
{
    return [self runWithLaunchPath:@"/bin/sh" withArguments:arguments];
}

+ (nonnull NSString *)runWithLaunchPath:(nullable NSString *)launchPath withArguments:(nullable NSArray *)arguments
{
    if (!launchPath) {
        return @"Missing launch path";
    }
    
    if (!arguments) {
        return @"Missing arguments";
    }
    
    NSTask *task = [NSTask new];
    task.launchPath = launchPath;
    task.arguments = arguments;
    task.currentDirectoryPath = [[NSBundle mainBundle] resourcePath];
    
    NSLog(@"Running: %@ %@", launchPath, [arguments componentsJoinedByString:@" "]);
    
    NSPipe *outputPipe = [NSPipe pipe];
    NSPipe *errorPipe = [NSPipe pipe];
    
    task.standardOutput = outputPipe;
    task.standardError = errorPipe;
    
    NSFileHandle *outputFileHandler = [outputPipe fileHandleForReading];
    NSFileHandle *errorFileHandler = [errorPipe fileHandleForReading];
    
    task.terminationHandler = ^(NSTask *task) {
        NSLog(@"termination reason : %ld | termination status : %d", task.terminationReason, task.terminationStatus);
    };
    
    [task launch];
    
    // Task launched now just read and print the data
    NSData *outputData = [outputFileHandler readDataToEndOfFile];
    NSData *errorData = [errorFileHandler readDataToEndOfFile];
    
    if (outputData.length > 0) {
        return [[NSString alloc] initWithData:outputData encoding: NSUTF8StringEncoding];
    }
    else if (errorData.length > 0) {
        return [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
    }
    else {
        return @"ERROR!";
    }
}

@end