//
//  SceneMeshModel.m
//  SimpleImageFilter
//
//  Created by Naver on 2017. 10. 19..
//  Copyright © 2017년 Cell Phone. All rights reserved.
//

#import "SceneMeshModel.h"

@implementation SceneMeshModel

- (id)initWithTexturePath:(NSString *)texturePath meshVertexData:(float *)vertexData
     meshTextureCoordData:(float *)meshTextureCoordData
           meshNormalData:(float *)meshNormalData
           numOfVerticies:(int)numOfVerticies
{
    _texturePath = texturePath;
    _numOfVerticies = numOfVerticies;
    _childs = [NSMutableArray array];
    self = [super init];
    
    
    self.vertexBuffer = [[VertexBufferObject alloc] initWithStride:3 * sizeof(float)
                                                    numOfVerticies:numOfVerticies
                                                           dataPtr:vertexData
                                                              hint:GL_STATIC_DRAW];
    
    self.texturePositionBuffer = [[VertexBufferObject alloc] initWithStride:2 * sizeof(float)
                                                             numOfVerticies:numOfVerticies
                                                                    dataPtr:meshTextureCoordData
                                                                       hint:GL_STATIC_DRAW];
    
    self.normalBuffer = [[VertexBufferObject alloc] initWithStride:3 * sizeof(float)
                                                    numOfVerticies:numOfVerticies
                                                           dataPtr:meshNormalData
                                                              hint:GL_STATIC_DRAW];

    if(texturePath) {
        [self loadTexture];
    }
    
    
    return self;
}

- (void)loadTexture
{
    CGImageRef image = [[UIImage imageNamed:_texturePath] CGImage];
    
    _texInfo = [GLKTextureLoader
                                    textureWithCGImage:image
                                    options:nil
                                    error:NULL];
}

- (void)updateLocalMat
{
    GLKMatrix4 scale = GLKMatrix4MakeScale(self.scaleFactor.x, self.scaleFactor.y, self.scaleFactor.z);
    GLKMatrix4 localRot = GLKMatrix4MakeRotation(self.localAngle.x * M_PI / 180.0,
                                                 self.localAngle.y * M_PI / 180.0,
                                                 self.localAngle.z * M_PI / 180.0,
                                                 1.0);
    GLKMatrix4 pointBaseRot = GLKMatrix4MakeRotation(self.pointBaseAngle.x * M_PI / 180.0,
                                                     self.pointBaseAngle.y * M_PI / 180.0,
                                                     self.pointBaseAngle.z * M_PI / 180.0,
                                                     1.0);
    
    GLKMatrix4 deltaTrans = GLKMatrix4MakeTranslation(self.deletaPos.x, self.deletaPos.y, self.deletaPos.z);
    
    GLKMatrix4 newMat = GLKMatrix4Multiply(localRot, scale);
    newMat = GLKMatrix4Multiply(deltaTrans, newMat);
    newMat = GLKMatrix4Multiply(pointBaseRot, newMat);
    
    self.mat = newMat;
    //self.mat = GLKMatrix4Multiply(deltaTrans, scale);
}

//- (void)calcAccumulatedMat:(GLKMatrix4)parentsAccumaltedMat animateRepeatCnt:(int)repeatCnt animateInterval:(NSTimeInterval)interval
//{
//    float localAngle = repeatCnt * 10;
//    float pointBaseAngle = repeatCnt;
//
//    GLKM
//}

@end
