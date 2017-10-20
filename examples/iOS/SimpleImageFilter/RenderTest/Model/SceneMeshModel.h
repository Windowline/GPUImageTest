//
//  SceneMeshModel.h
//  SimpleImageFilter
//
//  Created by Naver on 2017. 10. 19..
//  Copyright © 2017년 Cell Phone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VertexBufferObject.h"

@interface SceneMeshModel : NSObject
@property(nonatomic, retain) VertexBufferObject *vertexBuffer;
@property(nonatomic, retain) VertexBufferObject *texturePositionBuffer;
@property(nonatomic, retain) VertexBufferObject *normalBuffer;
@property(nonatomic, retain) NSString *texturePath;
@property(nonatomic, retain) GLKTextureInfo *texInfo;
@property(nonatomic) int numOfVerticies;
//@property(nonatomic, retain) VertexBufferObject *vertexBuffer;
- (id)initWithTexturePath:(NSString *)texturePath;

@end
