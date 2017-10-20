//
//  ShaderTest.m
//  FilterShowcase
//
//  Created by Naver on 2017. 7. 28..
//  Copyright © 2017년 Cell Phone. All rights reserved.
//
#import "ShaderTest.h"



NSString *const VertexShader = SHADER_STRING
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


NSString *const FragmentShader = SHADER_STRING
(
    precision highp float;
    uniform vec2 viewPort;
    varying highp vec2 textureCoordinate;
    uniform sampler2D inputImageTexture;
    uniform float curTime;
 
//    float rand(vec2 co)
//    {
//         float a = 12.9898;
//         float b = 78.233;
//         float c = 43758.5453;
//         float dt = dot(co.xy, vec2(a, b));
//         float sn = mod(dt, 3.14);
//         return fract(sin(sn) * c);
//    }
    float rand(vec2 co)
    {
        return fract(sin(mod(dot(co.xy, vec2(12.9898, 78.233)), 3.14)) * 43758.5453);
    }
 
    void main()
    {
        
        vec2 uv = textureCoordinate;
        uv.x = uv.x + rand(vec2(curTime, uv.y)) * 0.003;
        gl_FragColor = texture2D(inputImageTexture, uv);
        
        
        
//        vec2 uv = textureCoordinate;
//        uv.x = uv.x + rand(vec2(2.0, uv.y)) * 0.001;
//        vec3 rgb = texture2D(inputImageTexture, uv).rgb;
//        gl_FragColor = vec4(rgb, 1);
        
        
        
//        float magnitude = 0.00009;
//        
//        vec2 offsetRed = textureCoordinate;
//        offsetRed.x = offsetRed.x + rand(vec2(1000.0 * 0.03, textureCoordinate.y * 0.42)) * 0.001;
//        offsetRed.x += sin(rand(vec2(1000.0 * 0.2, textureCoordinate. y))) * magnitude;
//        
//        vec2 offsetGreen = textureCoordinate;
//        offsetGreen.x = offsetGreen.x + rand(vec2(1000.0 * 0.2, textureCoordinate.y)) * 0.004;
//        offsetGreen.x += sin(1000.0 * 9.0) * magnitude;
//        
//        float r = texture2D(inputImageTexture, offsetRed).r;
//        float g = texture2D(inputImageTexture, offsetGreen).g;
//        float b = texture2D(inputImageTexture, textureCoordinate).b;
//        gl_FragColor = vec4(r, g, b, 1.0);
    }
 );

@implementation ShaderTest
{
    GLuint _viewPortUniform;
    GLuint _curTimeUniform;
    
    NSDateFormatter *_timeFormat;
    long long _preMSFrom1970;
    int _curTime4Digit;
}

-(id) init
{
    self = [super initWithVertexShaderFromString:VertexShader fragmentShaderFromString:FragmentShader];
    _timeFormat = [[NSDateFormatter alloc] init];
    _preMSFrom1970 = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    _curTime4Digit = 0;
    [_timeFormat setDateFormat:@"ss"];
    return self;
}

-(void) initGLParams
{
    _viewPortUniform = [filterProgram uniformIndex:@"viewPort"];
    _curTimeUniform = [filterProgram uniformIndex:@"curTime"];
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
    
    [self setCurSec];
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    
    glUniform1i(filterInputTextureUniform, 2);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    int viewport[] = {0, 0, 0, 0}; // 0, 0, w, h
    glGetIntegerv(GL_VIEWPORT, viewport);
    glUniform2f(_viewPortUniform, (float)viewport[2], (float)viewport[3]);
    
    glUniform1f(_curTimeUniform, (GLfloat)_curTime4Digit);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [firstInputFramebuffer unlock];
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

-(void) setCurSec
{
    long long curMSFrom1970 = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    long long diff = curMSFrom1970 - _preMSFrom1970;
    _curTime4Digit = (_curTime4Digit + diff) % 1000; //0000 ~ 0999
    _preMSFrom1970 = curMSFrom1970;
}


@end
