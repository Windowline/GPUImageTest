//
//  SceneMeshModel.h
//  SimpleImageFilter
//
//  Created by Naver on 2017. 10. 19..
//  Copyright © 2017년 Cell Phone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VertexBufferObject.h"
#import <GLKit/GLKit.h>

@interface SceneMeshModel : NSObject
@property(nonatomic, retain) VertexBufferObject *vertexBuffer;
@property(nonatomic, retain) VertexBufferObject *texturePositionBuffer;
@property(nonatomic, retain) VertexBufferObject *normalBuffer;
@property(nonatomic, retain) NSString *texturePath;
@property(nonatomic, retain) GLKTextureInfo *texInfo;
@property(nonatomic) int numOfVerticies;
@property(nonatomic, retain) NSMutableArray *childs;
@property(nonatomic, retain) SceneMeshModel *parent;
@property(nonatomic) GLKMatrix4 accumulatedMat;
@property(nonatomic) GLKMatrix4 mat;

@property(nonatomic) GLKVector3 localAngle;
@property(nonatomic) GLKVector3 pointBaseAngle;
@property(nonatomic) GLKVector3 deletaPos;
@property(nonatomic) GLKVector3 scaleFactor;

//@property(nonatomic, retain) VertexBufferObject *vertexBuffer;
- (id)initWithTexturePath:(NSString *)texturePath meshVertexData:(float *)vertexData
                                             meshTextureCoordData:(float *)meshTextureCoordData
                                                   meshNormalData:(float *)meshNormalData
                                                   numOfVerticies:(int)numOfVerticies;

- (void)updateLocalMat;

@end
