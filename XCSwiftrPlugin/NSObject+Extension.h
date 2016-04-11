//
//  NSObject+Extension.h
//  XCSwiftr
//
//  Created by Ignacio Romero on 4/4/16.
//  Copyright © 2016 DZN Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (XcodePlugin)

+ (void)pluginDidLoad:(NSBundle *)plugin;

@end
