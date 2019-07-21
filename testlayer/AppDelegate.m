//
//  AppDelegate.m
//  testlayer
//
//  Created by Zakk on 10/9/18.
//  Copyright © 2018 Zakk. All rights reserved.
//

#import "AppDelegate.h"

CVReturn DisplayCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *now, const CVTimeStamp *outputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext);

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

@synthesize useOpenGL = _useOpenGL;


-(void)setUseOpenGL:(bool)useOpenGL
{
    _useOpenGL = useOpenGL;
    _testRenderer.useOGL = _useOpenGL;
}

-(bool)useOpenGL
{
    return _useOpenGL;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    self.mainView.layerUsesCoreImageFilters = YES;

    
    self.mainLayer = [CALayer layer];
    self.mainLayer.bounds = NSMakeRect(0, 0, 1280, 720);
    self.mainLayer.backgroundColor = CGColorCreateGenericRGB(0.0f,0.0f,0.0f, 1.0);
    
    
    // Insert code here to initialize your application
    self.layerOne = [CALayer layer];
    self.layerOne.bounds = NSMakeRect(0, 0, 100, 100);
    self.layerOne.position = NSMakePoint(200,200);
    self.layerOne.backgroundColor = NSColor.redColor.CGColor;
    /*
    self.layerOne.pluginType = @"com.apple.WindowServer.CGSWindow";
    self.layerOne.pluginId = 3120;
    */
    [self.mainLayer addSublayer:self.layerOne];
    
    self.layerTwo = [CALayer layer];
    
    self.layerTwo.backgroundColor = CGColorCreateGenericRGB(1, 0, 1, 1);
    self.layerTwo.position = NSMakePoint(600,200);
    self.layerTwo.bounds = NSMakeRect(0, 0, 100, 100);
    
    _testRenderer = [[RenderTest alloc] init];
    [_testRenderer setupRenderer:self.mainLayer];

    
    CVDisplayLinkCreateWithCGDisplay(CGMainDisplayID(), &_dlink);
    CVDisplayLinkSetOutputCallback(_dlink, &DisplayCallback, (__bridge void * _Nullable)(self));
    CVDisplayLinkStart(_dlink);


}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (IBAction)mainButtonClick:(id)sender {
    

    //CATransition *useTransition = [CATransition animation];
   // useTransition.type = kCATransitionMoveIn;
   // useTransition.duration = 2.0f;
    [CATransaction begin];
    [CATransaction disableActions];
    CATransition *trans = [CATransition animation];
    if (self.useCIFilter)
    {
        trans.filter = [CIFilter filterWithName:@"CIDissolveTransition"];
    } else {
        trans.type = kCATransitionFade;
    }
    
   trans.duration = 3.5;
    [self.layerOne addAnimation:trans forKey:nil];
    if (self.layerOne.bounds.size.width == 100)
    {
        self.layerOne.bounds = NSMakeRect(0, 0, 300, 300);
    } else {
        self.layerOne.bounds = NSMakeRect(0, 0, 100, 100);
    }


    if (self.layerTwo.superlayer)
    {
        [self.layerTwo removeFromSuperlayer];
    } else {
        [self.mainLayer addSublayer:self.layerTwo];
    }
    [CATransaction commit];

}


-(void)render
{

            dispatch_async(dispatch_get_main_queue()
                           , ^{
                               [CATransaction begin];
                               CVPixelBufferRef newImg = [_testRenderer currentImage];
                               [CATransaction commit];
                               self.mainView.layer.contents = (__bridge id _Nullable)(newImg);
                           });



}
@end

CVReturn DisplayCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *now, const CVTimeStamp *outputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext)
{
    AppDelegate *realSelf = (__bridge AppDelegate *)displayLinkContext;
    
    [realSelf render];
    return kCVReturnSuccess;
}
