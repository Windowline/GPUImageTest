//
//  GPUImageObjectRenderFilter.m
//  SimpleImageFilter
//
//  Created by Naver on 2017. 10. 19..
//  Copyright © 2017년 Cell Phone. All rights reserved.
//

#import "GPUImageObjectRenderFilter.h"
#import "SceneMeshModel.h"
#import "Sphere.h"
#import "DefualtMesh.h"

static NSString *const kObjectRenderVertexShader = SHADER_STRING
(
     attribute vec4 position;
     attribute vec4 inputTextureCoordinate;
     attribute vec4 a_modelTextureCoord;
     attribute vec4 a_modelNormal;

     uniform mat4 u_modelViewMat;
     uniform mat4 u_projMat;
     uniform mat4 u_normalMat;

     varying vec2 textureCoordinate;
     varying vec2 v_modelCoord;
     varying vec3 v_normal;
     varying vec3 v_modelViewPos;

     void main()
    {
        gl_Position = u_projMat * u_modelViewMat * position;
        //varying
        textureCoordinate = inputTextureCoordinate.xy;
        v_modelCoord = a_modelTextureCoord.xy;
//        v_normal = (u_normalMat * a_modelNormal).xyz;
//        v_modelViewPos = (u_modelViewMat * position).xyz;
    }
);

static NSString *const kObjectRenderFragShader = SHADER_STRING(
                                                               
     precision highp float;

     varying vec2 textureCoordinate;
     varying vec2 v_modelCoord;
     varying vec3 v_normal;
     varying vec3 v_modelViewPos;

     uniform sampler2D inputImageTexture;
     uniform sampler2D modelTexture;
     uniform float bg;

     void main()
     {
         if(bg > 0.5) {
             gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
         } else {
             
//             vec3 lightPos = vec3(0.0, 0.0, 0.0);
//             vec3 diffuseColor = vec3(0.3, 0.7, 0.2);
//             vec3 lightDir = v_modelViewPos - lightPos;
//             float lambertian = max(0.0, dot(normalize(-lightDir), normalize(v_normal)));
//
//             vec3 texColor = texture2D(modelTexture, v_modelCoord).rgb;
//             
//             vec3 lightingColor = texColor + ( diffuseColor * lambertian );
//             //gl_FragColor = vec4(lightingColor.r, lightingColor.g, lightingColor.b, 1.0);
             
             gl_FragColor = texture2D(modelTexture, v_modelCoord);
         }
     }
);


@implementation GPUImageObjectRenderFilter
{
    NSArray *_objectList;
    
    GLuint _bgUniform;
    GLuint _modelTextureUniform;
    GLuint _modelViewMatUniform;
    GLuint _projMatUniform;
    GLuint _normalMatUniform;
    
    GLuint _modelTextureCoordAttr;
    GLuint _modelNormalAttr;
    
    GLuint _lightPosUniform;
    
    SceneMeshModel *_rootScene;
    
    SceneMeshModel *_c00; //earth
    SceneMeshModel *_c10; // moon
    
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
    [filterProgram addAttribute:@"a_modelTextureCoord"];
    [filterProgram addAttribute:@"a_modelNormal"];
    [filterProgram addAttribute:@"modelTexture"];
    
    _bgUniform = [filterProgram uniformIndex:@"bg"];
    _modelTextureUniform = [filterProgram uniformIndex:@"modelTexture"];
    _modelViewMatUniform = [filterProgram uniformIndex:@"u_modelViewMat"];
    _projMatUniform = [filterProgram uniformIndex:@"u_projMat"];
    _normalMatUniform = [filterProgram uniformIndex:@"u_normalMat"];
    
    _modelTextureCoordAttr = [filterProgram attributeIndex:@"a_modelTextureCoord"];
    _modelNormalAttr = [filterProgram attributeIndex:@"a_modelNormal"];
    
//    glEnableVertexAttribArray(_modelNormalAttr);
//    glEnableVertexAttribArray(_modelTextureCoordAttr);
    
}


- (void)initObjects
{
    SceneMeshModel *rootScene = [[SceneMeshModel alloc] initWithTexturePath:nil meshVertexData:testV meshTextureCoordData:testT meshNormalData:testN numOfVerticies:sizeof(testV) / (sizeof(float) * 3)]; // root
    
    GLKMatrix4 viewMat = GLKMatrix4MakeLookAt(0, 0, 0,
                                              0, 0, -1,
                                              0, 1, 0);
    GLKMatrix4 projMat = GLKMatrix4Identity;
    rootScene.mat = projMat;
    rootScene.accumulatedMat = viewMat;
    
    
    SceneMeshModel *child00 = [[SceneMeshModel alloc] initWithTexturePath:@"Earth512x256.jpg" meshVertexData:sphereVerts meshTextureCoordData:sphereTexCoords meshNormalData:sphereNormals numOfVerticies:sizeof(sphereVerts) / (sizeof(float) * 3)];
    
//    GLKMatrix4 deletaTrans = GLKMatrix4MakeTranslation(0, 0, 0);
//    GLKMatrix4 scale = GLKMatrix4MakeScale(0.35, 0.35, 1.0);
//    child00.mat = GLKMatrix4Multiply(deletaTrans, scale);
    child00.deletaPos = GLKVector3Make(0, 0, 0);
    child00.scaleFactor = GLKVector3Make(0.35, 0.35, 1.0);
    child00.localAngle = GLKVector3Make(0, 0, 0);
    child00.pointBaseAngle = GLKVector3Make(0, 0, 0);
    [child00 updateLocalMat];
    _c00 = child00;
    
    SceneMeshModel *child10 = [[SceneMeshModel alloc] initWithTexturePath:@"Moon256x128.png" meshVertexData:sphereVerts meshTextureCoordData:sphereTexCoords meshNormalData:sphereNormals numOfVerticies:sizeof(sphereVerts) / (sizeof(float) * 3)];
    
//    deletaTrans = GLKMatrix4MakeTranslation(0.45, 0.0, 0.0);
//    scale = GLKMatrix4MakeScale(0.2, 0.2, 1.0);
//    child10.mat = GLKMatrix4Multiply(deletaTrans, scale);
    child10.deletaPos = GLKVector3Make(0.45, 0.0, 0.0);
    child10.scaleFactor = GLKVector3Make(0.2, 0.2, 1.0);
    child10.localAngle = GLKVector3Make(0, 0, 0);
    child10.pointBaseAngle = GLKVector3Make(0, 0, 0);
    [child10 updateLocalMat];
    _c10 = child10;
    
    rootScene.parent = nil;
    
    [rootScene.childs addObject:child00];
    child00.parent = rootScene;
    [child00.childs addObject:child10];
    child10.parent = child00;
    
    _rootScene = rootScene;
}

- (void)updateSceneStatesWithAnimationRepeatCount:(int)repeatCnt repeatInterval:(NSTimeInterval)interval
{
    float localAngle = repeatCnt * 10;
    float pointBaseAngle = repeatCnt;
    
}


- (void)renderObjectsWithAnimationRepeatCount:(int)repeatCnt repeatInterval:(NSTimeInterval)interval
{
//    if(repeatCnt==0 && interval==0) {
//        return;
//    }
    
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
    
    _animateRepeatCnt = repeatCnt;
    _animateInterval = interval;
    
    [self updateSceneStatesWithAnimationRepeatCount:repeatCnt repeatInterval:interval];
    
    NSLog(@"ob render");
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    glCullFace(GL_BACK);
    glFrontFace(GL_CCW);
    
    glEnableVertexAttribArray(_modelTextureCoordAttr);
    glEnableVertexAttribArray(_modelNormalAttr);
    glEnableVertexAttribArray(filterPositionAttribute);
    
    [self traceSceneHierarchy:_rootScene];
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    glDisable(GL_BLEND);
    
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
    
    [self informTargetsAboutNewFrameAtTime:CMTimeMake(0, 0)];
}

- (void)traceSceneHierarchy:(SceneMeshModel *)currentModel
{
    if(currentModel != _rootScene) {
        [self renderSceneModel:currentModel];
    }
    
    for(SceneMeshModel *nextModels in currentModel.childs) {
        float localAngle = _animateRepeatCnt * 10;
        float pointBaseAngle = _animateRepeatCnt;
        
        nextModels.localAngle = GLKVector3Make(localAngle, 0.0, 0.0);
        if(nextModels == _c10) {
            nextModels.pointBaseAngle = GLKVector3Make(pointBaseAngle, 0, 0);
        }
        
        [nextModels updateLocalMat];
        
        nextModels.accumulatedMat = GLKMatrix4Multiply(nextModels.mat, currentModel.accumulatedMat);
        [self traceSceneHierarchy:nextModels];
    }
}

- (void)renderSceneModel:(SceneMeshModel *)sceneModel
{
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, sceneModel.texInfo.name);
    glUniform1i(_modelTextureUniform, 3);

    glBindBuffer(GL_ARRAY_BUFFER, sceneModel.vertexBuffer.vboID);
    glVertexAttribPointer(filterPositionAttribute, 3, GL_FLOAT, 0, 0, (GLvoid*)0);
    
    glBindBuffer(GL_ARRAY_BUFFER, sceneModel.texturePositionBuffer.vboID);
    glVertexAttribPointer(_modelTextureCoordAttr, 2, GL_FLOAT, 0, 0, (GLvoid*)0);
    
    glBindBuffer(GL_ARRAY_BUFFER, sceneModel.normalBuffer.vboID);
    glVertexAttribPointer(_modelNormalAttr, 3, GL_FLOAT, 0, 0, (GLvoid*)0);
    
    glUniform1f(_bgUniform, 0.0);
    glUniform3f(_lightPosUniform, 0.0, 0.0, 0.0);
    
    glUniformMatrix4fv(_modelViewMatUniform, 1, 0, sceneModel.accumulatedMat.m);
    glUniformMatrix4fv(_projMatUniform, 1, 0, _rootScene.mat.m);
    
    bool canInverse = NO;
    GLKMatrix4 normalMatrix = GLKMatrix4Transpose(GLKMatrix4Invert(sceneModel.accumulatedMat, &canInverse));
    glUniformMatrix4fv(_normalMatUniform, 1, 0, normalMatrix.m);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, sceneModel.numOfVerticies);
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
    
    
    glEnableVertexAttribArray(filterPositionAttribute);
    glEnableVertexAttribArray(filterTextureCoordinateAttribute);
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glUniform1f(_bgUniform, 1.0);
    
    glUniformMatrix4fv(_modelViewMatUniform, 1, 0, GLKMatrix4Identity.m);
    glUniformMatrix4fv(_projMatUniform, 1, 0, GLKMatrix4Identity.m);
    
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [self renderObjectsWithAnimationRepeatCount:0 repeatInterval:0];
    
    [firstInputFramebuffer unlock];
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

@end
