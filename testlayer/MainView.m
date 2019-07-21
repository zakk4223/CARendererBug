//
//  MainView.m
//  testlayer
//
//  Created by Zakk on 10/9/18.
//  Copyright © 2018 Zakk. All rights reserved.
//

#import "MainView.h"

@implementation MainView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


-(void)updateLayer
{
    self.layer.backgroundColor = CGColorCreateGenericRGB(0, 0, 0, 1);
}



-(BOOL)wantsUpdateLayer
{
    return YES;
}
@end
