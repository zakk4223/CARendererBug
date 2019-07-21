//
//  RenderTest.m
//  testlayer
//
//  Created by Zakk on 7/20/19.
//  Copyright © 2019 Zakk. All rights reserved.
//

#import "RenderTest.h"

@implementation RenderTest


-(void) createCGLContext
{
    CGLPixelFormatAttribute glAttributes[] = {
        
        kCGLPFAAccelerated,
        kCGLPFANoRecovery,
        kCGLPFADepthSize, (CGLPixelFormatAttribute)32,
        kCGLPFAAllowOfflineRenderers,
        (CGLPixelFormatAttribute)0
    };
    
    GLint screens;
    CGLPixelFormatObj pixelFormat;
    CGLChoosePixelFormat(glAttributes, &pixelFormat, &screens);
    
    
    if (!pixelFormat)
    {
        return;
    }
    
    CGLCreateContext(pixelFormat, NULL, &_cglCtx);
    
}


-(CVPixelBufferRef)currentImage
{

    CVPixelBufferRef destFrame = NULL;
    CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, _cvpool, &destFrame);
    [CATransaction begin];
    [CATransaction disableActions];
    if (self.useOGL)
    {
        self.OGLrenderer.layer = _useLayer;
        [self renderToPixelBufferOGL:destFrame];
    } else {
        self.renderer.layer = _useLayer;

        [self renderToPixelBuffer:destFrame];
    }
    [CATransaction commit];
    
    return destFrame;
}


-(void)renderToPixelBufferOGL:(CVPixelBufferRef)pixelBuffer
{
    
    IOSurfaceRef ioSurface = CVPixelBufferGetIOSurface(pixelBuffer);
    
    CGLSetCurrentContext(_cglCtx);
    if (!_rFbo)
    {
        glGenFramebuffers(1, &_rFbo);
    }
    
    if (!_fboTexture)
    {
        glGenTextures(1, &_fboTexture);
    }
    
    glViewport(0, 0, 1280,720);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0, 1280, 0,720, 1, -1);
    
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glClearColor(0, 0, 0, 0);
    
    glEnable(GL_TEXTURE_RECTANGLE_ARB);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_RECTANGLE_ARB, _fboTexture);
    
    //glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    //glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glDisable(GL_DEPTH_TEST);
    glDepthMask(GL_FALSE);
    
    
    
    CGLTexImageIOSurface2D(_cglCtx, GL_TEXTURE_RECTANGLE_ARB, GL_RGBA, (int)IOSurfaceGetWidth(ioSurface), (int)IOSurfaceGetHeight(ioSurface), GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, ioSurface, 0);
    
    GLenum fboStatus;
    
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_RECTANGLE_ARB, _fboTexture, 0);
    
    glBindFramebuffer(GL_FRAMEBUFFER, _rFbo);
    fboStatus  = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    glClear(GL_COLOR_BUFFER_BIT);

    if (fboStatus == GL_FRAMEBUFFER_COMPLETE && self.OGLrenderer && self.OGLrenderer.layer)
    {
        
        [self.OGLrenderer beginFrameAtTime:CACurrentMediaTime() timeStamp:NULL];
        [self.OGLrenderer addUpdateRect:self.OGLrenderer.bounds];
        [self.OGLrenderer render];
        [self.OGLrenderer endFrame];
        
    }
    glBindTexture(GL_TEXTURE_RECTANGLE_ARB, 0);
    glDisable(GL_TEXTURE_RECTANGLE_ARB);
    
    glFlush();
}
-(void)renderToPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    CVMetalTextureRef mtlTexture = NULL;
    CVMetalTextureCacheCreateTextureFromImage(NULL, _cvmetalcache, pixelBuffer, NULL, MTLPixelFormatBGRA8Unorm, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer), 0, &mtlTexture);
    
    [self.renderer setDestination:CVMetalTextureGetTexture(mtlTexture)];
    [self.renderer beginFrameAtTime:CACurrentMediaTime() timeStamp:NULL];
    [self.renderer addUpdateRect:self.renderer.bounds];
    [self.renderer render];
    [self.renderer endFrame];
    CFRelease(mtlTexture);
}


-(void)setupRenderer:(CALayer *)withLayer
{
    _useLayer = withLayer;
    [self createCGLContext];
    _metalDevice = MTLCreateSystemDefaultDevice();
    [self createMetalTextureCache];
    [self createPixelBufferPoolForSize:NSMakeSize(1280, 720)];
    CVPixelBufferRef dummyFrame = NULL;
    CVMetalTextureRef dummyTexture = NULL;
    CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, _cvpool, &dummyFrame);
    CVMetalTextureCacheCreateTextureFromImage(NULL, _cvmetalcache, dummyFrame, NULL, MTLPixelFormatBGRA8Unorm, 1280, 720, 0, &dummyTexture);
    self.OGLrenderer = [CARenderer rendererWithCGLContext:_cglCtx options:nil];
    //self.OGLrenderer.layer = withLayer;
    
    self.renderer = [CARenderer rendererWithMTLTexture:CVMetalTextureGetTexture(dummyTexture) options:nil];
    //self.renderer.layer = withLayer;
    withLayer.position = CGPointMake(0.0, 0.0);
    withLayer.anchorPoint = CGPointMake(0.0, 0.0);
    withLayer.masksToBounds = YES;

    self.renderer.bounds = NSMakeRect(0.0f, 0.0f, 1280, 720);
    self.OGLrenderer.bounds = NSMakeRect(0.0f, 0.0f, 1280, 720);

}


-(bool) createPixelBufferPoolForSize:(NSSize) size
{
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setValue:[NSNumber numberWithInt:size.width] forKey:(NSString *)kCVPixelBufferWidthKey];
    [attributes setValue:[NSNumber numberWithInt:size.height] forKey:(NSString *)kCVPixelBufferHeightKey];
    [attributes setValue:@{(NSString *)kIOSurfaceIsGlobal: @NO} forKey:(NSString *)kCVPixelBufferIOSurfacePropertiesKey];
    [attributes setValue:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA] forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
    [attributes setValue:@YES forKey:(NSString *)kCVPixelBufferMetalCompatibilityKey];
    
    
    if (_cvpool)
    {
        CVPixelBufferPoolRelease(_cvpool);
    }
    
    
    
    CVReturn result = CVPixelBufferPoolCreate(NULL, NULL, (__bridge CFDictionaryRef)(attributes), &_cvpool);
    
    if (result != kCVReturnSuccess)
    {
        return NO;
    }
    
    return YES;
    
    
}

-(bool)createMetalTextureCache
{
    if (_cvmetalcache)
    {
        CFRelease(_cvmetalcache);
    }
    
    CVReturn result = CVMetalTextureCacheCreate(NULL, NULL, _metalDevice, NULL, &_cvmetalcache);
    if (result != kCVReturnSuccess)
    {
        return NO;
    }
    return YES;
}



@end
