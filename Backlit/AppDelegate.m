//
//  AppDelegate.m
//  Backlit
//
//  Created by Charles Aroutiounian on 14/01/2015.
//  Copyright (c) 2015 Charles Aroutiounian. All rights reserved.
//

#import "AppDelegate.h"
#include <IOKit/graphics/IOGraphicsLib.h>
#import <IOKit/IOTypes.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

@synthesize statusMenu, mySlider;

static io_connect_t dataPort = 0;

enum {
    kGetSensorReadingID = 0,    // getSensorReading(int *, int *)
    kGetLEDBrightnessID = 1,    // getLEDBrightness(int, int *)
    kSetLEDBrightnessID = 2,    // setLEDBrightness(int, int, int *)
    kSetLEDFadeID = 3,          // setLEDFade(int, int, int, int *)
};

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    
    NSImage *img = [NSImage imageNamed:@"brightness"];
    
    
    [img setTemplate:YES];
    
    statusItem.image = img;
    statusItem.target = self;
    statusItem.enabled = YES;
    statusItem.highlightMode = YES;
    [statusItem setMenu:statusMenu];
    
    [NSThread detachNewThreadSelector:@selector(bgThread:) toTarget:self withObject:nil];
    
    mySlider.maxValue = 10;
    mySlider.minValue = 0;
    
    

    [statusItem setHighlightMode:YES];
    [mySlider setContinuous:NO];
    [mySlider becomeFirstResponder];
    
    
    
    
}
io_connect_t getDataPort(void) {
    kern_return_t kr;
    io_service_t serviceObject;
    if (dataPort) return dataPort;
    
    // Look up a registered IOService object whose class is AppleLMUController
    serviceObject = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                IOServiceMatching("AppleLMUController"));
    
    if (!serviceObject) {
        printf("getDataPort() error: failed to find ambient light sensor\n");
        return 0;
    }
    
    // Create a connection to the IOService object
    kr = IOServiceOpen(serviceObject, mach_task_self(), 0, &dataPort);
    IOObjectRelease(serviceObject);
    if (kr != KERN_SUCCESS) {
        printf("getDataPort() error: failed to open IoService object\n");
        return 0;
    }
    return dataPort;
}

-(void)setKeyboardBrightness:(float)val{
    // static io_connect_t dp = 0; // shared?
    kern_return_t kr;
    uint64_t inputCount = 2;
    uint64_t inputValues[2];
    uint64_t in_unknown = 0;
    uint64_t in_brightness = val * 0xfff;
    inputValues[0] = in_unknown;
    inputValues[1] = in_brightness;
    uint32_t outputCount = 1;
    uint64_t outputValues[1];
    uint32_t out_brightness;
    
    kr = IOConnectCallScalarMethod(getDataPort(), kSetLEDBrightnessID,
                                   inputValues, inputCount, outputValues, &outputCount);
    out_brightness = outputValues[0];
    if (kr != KERN_SUCCESS) {
        printf("setKeyboardBrightness() error\n");
        return;
    } else {
        printf("keyboard brightness is %f\n", val);
    }
}


-(void) getKeyboardBrightness:(float)val{

}

const float INTERACTIVE = 1;
const float BACKGROUND = 1.0;


- (void)bgThread:(NSConnection *)connection
{
    
    float old_brightness = [self get_brightness];
    float wait_amount = INTERACTIVE;
    while (true) {
        // every 0.1 seconds poll for the current brightness and set the slider
        NSDate *future = [NSDate dateWithTimeIntervalSinceNow: wait_amount ];
        [NSThread sleepUntilDate:future];
        
        // only change the slider if brightness has changed
        float new_brightness = [self get_brightness];
        if(old_brightness != new_brightness){
            old_brightness = new_brightness;
            [mySlider setFloatValue:new_brightness*10];
            wait_amount = INTERACTIVE;
        }else{
            // slow down wait
            wait_amount = wait_amount*4 > BACKGROUND ? BACKGROUND : wait_amount*4;
        }
        // NSLog(@"got brightness");
    }
    
    //return (float)f;
    
}


- (float) get_brightness {
    
    
    float f;
    kern_return_t kr;
    
    uint64_t inputCount = 1;
    uint64_t inputValues[1] = {0};
    
    uint32_t outputCount = 1;
    uint64_t outputValues[1];
    
    uint32_t out_brightness;
    
    kr = IOConnectCallScalarMethod(getDataPort(),
                                   kGetLEDBrightnessID,
                                   inputValues,
                                   inputCount,
                                   outputValues,
                                   &outputCount);
    
    out_brightness = outputValues[0];
    
    
    f = out_brightness;
    f /= 0xfff;
    return f;
    
}


-(void)setBrightnessBackground:(double)val{
    
    double value =  val *1/10;
    [self setKeyboardBrightness:value];
    NSLog(@"%f",val *1/10);
}

-(IBAction)setBrightness:(id)sender{
    
    double value =  [sender doubleValue] *1/10;
   // [self set_brightness:value];
    NSLog(@"%f",[sender doubleValue]/10);
    
    [self setKeyboardBrightness:value];

}



-(IBAction)exit:(id)sender{
    exit(1);
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
