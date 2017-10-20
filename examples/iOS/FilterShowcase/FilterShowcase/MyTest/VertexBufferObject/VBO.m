//
//  VBO.m
//  FilterShowcase
//
//  Created by Naver on 2017. 10. 18..
//  Copyright © 2017년 Cell Phone. All rights reserved.
//

#import "VBO.h"

@implementation VBO
{
    GLsizeiptr   stride;
    GLsizeiptr   bufferSizeBytes;
    GLuint       name;
}
- (id)initWithAttribStride:(GLsizeiptr)aStride
          numberOfVertices:(GLsizei)count
                     bytes:(const GLvoid *)dataPtr
                     usage:(GLenum)usage;
{
    NSParameterAssert(0 < aStride);
    NSAssert((0 < count && NULL != dataPtr) ||
             (0 == count && NULL == dataPtr),
             @"data must not be NULL or count > 0");
    
    if(nil != (self = [super init]))
    {
        stride = aStride;
        bufferSizeBytes = stride * count;
        
        glGenBuffers(1,                // STEP 1
                     &name);
        glBindBuffer(GL_ARRAY_BUFFER,  // STEP 2
                     self.name);
        glBufferData(                  // STEP 3
                     GL_ARRAY_BUFFER,  // Initialize buffer contents
                     bufferSizeBytes,  // Number of bytes to copy
                     dataPtr,          // Address of bytes to copy
                     usage);           // Hint: cache in GPU memory
        
        NSAssert(0 != name, @"Failed to generate name");
    }
    
    return self;
}

@end
