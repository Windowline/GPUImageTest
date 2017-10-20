//
//  SceneObject.h
//  FilterShowcase
//
//  Created by Naver on 2017. 10. 18..
//  Copyright © 2017년 Cell Phone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SceneObject : NSObject
@property(nonatomic) GLuint vboID;
@property(nonatomic, retain) NSString *textureImagePath;

@end
