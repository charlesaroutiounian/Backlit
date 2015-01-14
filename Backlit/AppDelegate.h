//
//  AppDelegate.h
//  Backlit
//
//  Created by Charles Aroutiounian on 14/01/2015.
//  Copyright (c) 2015 Charles Aroutiounian. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/IOTypes.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    
    
    
    IBOutlet NSMenu *statusMenu;
    
    IBOutlet  NSSlider *mySlider;
    
    NSStatusItem *statusItem;
}

@property (nonatomic, strong)  IBOutlet  NSSlider *mySlider;

@property (nonatomic, strong)  IBOutlet NSMenu *statusMenu;

-(IBAction)setBrightness:(id)sender;
-(void)setBrightnessBackground:(double)val;
-(void) setKeyboardBrightness:(float)val;

@end

