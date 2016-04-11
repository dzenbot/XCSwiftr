//
//  XCSwiftrPlugin.h
//  XCSwiftr
//
//  Created by Ignacio Romero on 4/4/16.
//  Copyright © 2016 DZN Labs. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface XCSwiftrPlugin : NSObject

@property (nonatomic, strong) NSBundle *bundle;

+ (instancetype)sharedPlugin;

@end