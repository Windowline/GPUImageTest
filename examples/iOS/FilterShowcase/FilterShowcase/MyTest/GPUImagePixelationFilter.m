//
//  GPUImagePixelationFilter.m
//  Pods
//
//  Created by Naver on 2017. 8. 17..
//
//

#import "GPUImagePixelationFilter.h"

NSString *const kGPUImagePixelationVertexShader = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 varying vec2 textureCoordinate;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );


NSString *const kGPUImagePixelationFragmentShader = SHADER_STRING
(
 precision highp float;
 
 uniform sampler2D inputImageTexture;
 
 varying vec2 textureCoordinate;
 
 uniform float texelWidth;
 uniform float texelHeight;
 
 void main() {
     vec2 uv  = textureCoordinate.xy;
     uv = vec2(texelWidth * floor(uv.x / texelWidth), texelHeight * floor(uv.y / texelHeight));
     gl_FragColor = vec4(texture2D(inputImageTexture, uv).rgb, 1.0);
     //gl_FragColor = vec4(0.5, 0.5, 0.5, 1.0);
 }
 
 );


@implementation GPUImagePixelationFilter
{
    GLuint _texelWidthUniform;
    GLuint _texelHeightUniform;
    CGFloat _scale;
}
-(id) init
{
    self = [super initWithVertexShaderFromString:kGPUImagePixelationVertexShader
                        fragmentShaderFromString:kGPUImagePixelationFragmentShader];
    [self initGLParams];
    return self;
}
-(void) setTexelScale:(float)scale
{
    _scale = scale;
}
-(void) initGLParams
{
    _texelWidthUniform = [filterProgram uniformIndex:@"texelWidth"];
    _texelHeightUniform = [filterProgram uniformIndex:@"texelHeight"];
}


-(void) renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates
{
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        return;
    }
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture)
    {
        [outputFramebuffer lock];
    }
    
    [self setUniformsForProgramAtIndex:0];
    
    glUniform1f(_texelWidthUniform, _scale / self.sizeOfFBO.width);
    glUniform1f(_texelHeightUniform, _scale / self.sizeOfFBO.height);
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    
    glUniform1i(filterInputTextureUniform, 2);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [firstInputFramebuffer unlock];
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

@end
