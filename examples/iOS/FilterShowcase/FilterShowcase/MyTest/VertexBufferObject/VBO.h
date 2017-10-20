//
//  VBO.h
//  FilterShowcase
//
//  Created by Naver on 2017. 10. 18..
//  Copyright © 2017년 Cell Phone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VBO : NSObject
@property(nonatomic, readonly) GLuint name;
@property (nonatomic, readonly) GLsizeiptr bufferSizeBytes;
@property (nonatomic, readonly) GLsizeiptr stride;
@end
