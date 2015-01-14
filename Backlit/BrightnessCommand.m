//
//  BrightnessCommand.m
//  HueMenu
//
//  Created by Charles Aroutiounian on 29/09/14.
//  Copyright (c) 2014 Hue Menu. All rights reserved.
//

#import "BrightnessCommand.h"
#import "scriptLog.h"
#import "AppDelegate.h"



@implementation BrightnessCommand

- (id)performDefaultImplementation {
    
    NSDictionary * theArguments = [self evaluatedArguments];
    NSString *theResult;
    
    
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    
    [appDelegate setBrightnessBackground:[ [theArguments objectForKey:@"intensity"] doubleValue]];


    theResult = [NSString stringWithFormat:@"%@",  [NSNumber numberWithInteger: [theArguments objectForKey:@"intensity"]]];
    
    return theResult;
}

@end
