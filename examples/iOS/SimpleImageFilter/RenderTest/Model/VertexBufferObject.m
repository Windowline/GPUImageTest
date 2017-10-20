//
//  VertexBufferObject.m
//  SimpleImageFilter
//
//  Created by Naver on 2017. 10. 19..
//  Copyright © 2017년 Cell Phone. All rights reserved.
//

#import "VertexBufferObject.h"

@implementation VertexBufferObject
-(id) initWithStride:(int)stride numOfVerticies:(int)numOfVerticies dataPtr:(void *)dataPtr hint:(GLenum)hint
{
    self = [super init];
    _byteSize = stride * numOfVerticies;
    _stride = stride;
    _numOfVerticies = numOfVerticies;
    if(self) {
        glGenBuffers(1, &_vboID);
        glBindBuffer(GL_ARRAY_BUFFER, _vboID);
        glBufferData(GL_ARRAY_BUFFER, _byteSize, dataPtr, hint);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
    }
    return self;
}
@end
