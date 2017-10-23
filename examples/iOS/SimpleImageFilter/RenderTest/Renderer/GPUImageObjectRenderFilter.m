//
//  GPUImageObjectRenderFilter.m
//  SimpleImageFilter
//
//  Created by Naver on 2017. 10. 19..
//  Copyright © 2017년 Cell Phone. All rights reserved.
//

#import "GPUImageObjectRenderFilter.h"
#import "SceneMeshModel.h"

static NSString *const kObjectRenderVertexShader = SHADER_STRING
(
     attribute vec4 position;
     attribute vec4 inputTextureCoordinate;
     attribute vec4 a_modelTextureCoord;
     attribute vec4 a_modelNormal;
 
     uniform mat4 matrix;
     uniform vec3 u_lightPos;
 
     varying vec2 textureCoordinate;
     varying vec2 v_modelCoord;
     varying vec3 v_normal;
     varying vec3 v_lightDir;
 
     void main()
    {
        vec4 pPos = matrix * position;
        gl_Position = pPos;
        textureCoordinate = inputTextureCoordinate.xy;
        
        v_modelCoord = a_modelTextureCoord.xy;
        v_normal = a_modelNormal.xyz;
        v_lightDir = (pPos/pPos.w).xyz - u_lightPos;
    }
);

static NSString *const kObjectRenderFragShader = SHADER_STRING
(

     varying highp vec2 textureCoordinate;
     varying highp vec2 v_modelCoord;
     varying highp vec3 v_normal;
     varying highp vec3 v_lightDir;
 
     uniform sampler2D inputImageTexture;
     uniform sampler2D modelTexture;
     uniform highp float bg;

     void main()
     {
         if(bg > 0.5) {
             gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
         } else {
             
             highp vec3 originColor = texture2D(modelTexture, v_modelCoord).rgb;
             highp vec3 originLight = vec3(0.5, 1.0, 0.3);
             
             highp float lightDist = length(v_lightDir);
             
             highp vec3 color = (clamp(dot(v_normal, - v_lightDir), 0.0, 1.0) * originLight * originColor)
                                / (lightDist * lightDist);
             
             //gl_FragColor = vec4(color.r, color.g, color.b, 1.0);
             //gl_FragColor = vec4(0.5, 0.5, 0.5, 1.0);
             
             gl_FragColor = texture2D(modelTexture, v_modelCoord);
         }
     }
);


@implementation GPUImageObjectRenderFilter
{
    NSArray *_objectList;
    
    GLuint _bgUniform;
    GLuint _modelTextureUniform;
    GLuint _matUniform;
    
    GLuint _modelTextureCoordAttr;
    GLuint _modelNormalAttr;
    
    GLuint _lightPosUniform;
}

- (instancetype)init
{
    self = [super initWithVertexShaderFromString:kObjectRenderVertexShader
                        fragmentShaderFromString:kObjectRenderFragShader];
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [self initGLParams];
    });
    
    [self initObjects];
    
    return self;
}

- (void)initGLParams
{
    _bgUniform = [filterProgram uniformIndex:@"bg"];
    _modelTextureUniform = [filterProgram uniformIndex:@"modelTexture"];
    _matUniform = [filterProgram uniformIndex:@"matrix"];
    _modelTextureCoordAttr = [filterProgram attributeIndex:@"a_modelTextureCoord"];
    _modelNormalAttr = [filterProgram attributeIndex:@"a_modelNormal"];
    _lightPosUniform = [filterProgram uniformIndex:@"u_lightPos"];
    
    glEnableVertexAttribArray(_modelNormalAttr);
    glEnableVertexAttribArray(_modelTextureCoordAttr);
    
}

- (void)initObjects
{
    NSMutableArray *objects = [NSMutableArray array];
    SceneMeshModel *earthModel = [[SceneMeshModel alloc] initWithTexturePath:@"Moon256x128.png"];
    [objects addObject:earthModel];
    _objectList = objects;
}

- (void)renderObjects
{
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    for(SceneMeshModel *model in _objectList) {

        glActiveTexture(GL_TEXTURE3);
        glBindTexture(GL_TEXTURE_2D, model.texInfo.name);
        glUniform1i(_modelTextureUniform, 3);

        glBindBuffer(GL_ARRAY_BUFFER, model.vertexBuffer.vboID);
        glVertexAttribPointer(filterPositionAttribute, 3, GL_FLOAT, 0, 0, (GLvoid*)0);
        
        glBindBuffer(GL_ARRAY_BUFFER, model.texturePositionBuffer.vboID);
        glVertexAttribPointer(_modelTextureCoordAttr, 2, GL_FLOAT, 0, 0, (GLvoid*)0);
        
        glBindBuffer(GL_ARRAY_BUFFER, model.normalBuffer.vboID);
        glVertexAttribPointer(_modelNormalAttr, 3, GL_FLOAT, 0, 0, (GLvoid*)0);

        glUniform1f(_bgUniform, 0.0);
        glUniform3f(_lightPosUniform, 0.0, 0.0, 0.0);
        
        //glUniformMatrix4fv(_matUniform, 1, 0, GLKMatrix4Identity.m);
        
        GLfloat aspect = self.sizeOfFBO.width / self.sizeOfFBO.height;
        
        glUniformMatrix4fv(_matUniform, 1, 0, GLKMatrix4MakeFrustum(-aspect, aspect, -1, 1, 0.1, 1000).m);
        
        glDrawArrays(GL_TRIANGLES, 0, model.numOfVerticies);
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glDisable(GL_BLEND);
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates
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
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    
    glUniform1i(filterInputTextureUniform, 2);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glUniform1f(_bgUniform, 1.0);
    
    glUniformMatrix4fv(_matUniform, 1, 0, GLKMatrix4Identity.m);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [self renderObjects];
    
    [firstInputFramebuffer unlock];
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

@end
