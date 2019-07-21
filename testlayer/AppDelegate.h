//
//  AppDelegate.h
//  testlayer
//
//  Created by Zakk on 10/9/18.
//  Copyright © 2018 Zakk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainView.h"
#import <QuartzCore/QuartzCore.h>
#import "RenderTest.h"


@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    RenderTest *_testRenderer;
    CVDisplayLinkRef _dlink;
    
    
}
@property (assign) bool useCIFilter;
@property (assign) bool useOpenGL;

@property (weak) IBOutlet MainView *mainView;
@property (strong) CALayer *layerOne;
@property (strong) CALayer *layerTwo;
@property (strong) CALayer *mainLayer;

- (IBAction)mainButtonClick:(id)sender;

@end

