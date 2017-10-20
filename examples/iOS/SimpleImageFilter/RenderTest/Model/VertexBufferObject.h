//
//  VertexBufferObject.h
//  SimpleImageFilter
//
//  Created by Naver on 2017. 10. 19..
//  Copyright © 2017년 Cell Phone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

//typedef enum {
////    AGLKVertexAttribPosition = GLKVertexAttribPosition,
////    AGLKVertexAttribmal = GLKVertexAttribNormal,
////    AGLKVertexAttribColor = GLKVertexAttribColor,
////    AGLKVertexAttribTexCoord0 = GLKVertexAttribTexCoord0,
////    AGLKVertexAttribTexCoord1 = GLKVertexAttribTexCoord1,
//} VertexAttribType;

@interface VertexBufferObject : NSObject
-(id) initWithStride:(int)stride numOfVerticies:(int)numOfVerticies dataPtr:(void *)dataPtr hint:(GLenum)hint;
@property(nonatomic, assign) int attribType;
@property(nonatomic, assign) GLuint vboID;
@property(nonatomic, assign) int byteSize;
@property(nonatomic, assign) int stride;
@property(nonatomic, assign) int numOfVerticies;
@end
