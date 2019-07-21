//
//  RenderTest.h
//  testlayer
//
//  Created by Zakk on 7/20/19.
//  Copyright © 2019 Zakk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <QuartzCore/QuartzCore.h>
#import <Metal/Metal.h>
#import <OpenGL/gl.h>

NS_ASSUME_NONNULL_BEGIN

@interface RenderTest : NSObject
{
    CVPixelBufferPoolRef _cvpool;
    id <MTLDevice> _metalDevice;
    CVMetalTextureCacheRef _cvmetalcache;
    CGLContextObj _cglCtx;
    GLuint _fboTexture;
    GLuint _rFbo;
    CALayer *_useLayer;
    
    
}
-(CVPixelBufferRef)currentImage;
-(void)setupRenderer:(CALayer *)withLayer;
@property (strong) CARenderer *renderer;
@property (strong) CARenderer *OGLrenderer;
@property (assign) bool useOGL;

@end

NS_ASSUME_NONNULL_END
