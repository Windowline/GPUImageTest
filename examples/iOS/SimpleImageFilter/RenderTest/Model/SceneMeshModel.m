//
//  SceneMeshModel.m
//  SimpleImageFilter
//
//  Created by Naver on 2017. 10. 19..
//  Copyright © 2017년 Cell Phone. All rights reserved.
//

#import "SceneMeshModel.h"
#import "Sphere.h"

@implementation SceneMeshModel

- (id)initWithTexturePath:(NSString *)texturePath
{
    _texturePath = texturePath;
    _numOfVerticies = sizeof(sphereVerts)/(sizeof(float) * 3);
    
    self = [super init];
    
    self.vertexBuffer = [[VertexBufferObject alloc] initWithStride:3 * sizeof(float)
                                                    numOfVerticies:sizeof(sphereVerts)/(sizeof(float) * 3)
                                                           dataPtr:sphereVerts
                                                              hint:GL_STATIC_DRAW];
    
    self.texturePositionBuffer = [[VertexBufferObject alloc] initWithStride:2 * sizeof(float)
                                                             numOfVerticies:sizeof(sphereTexCoords)/(sizeof(float) * 2)
                                                                    dataPtr:sphereTexCoords
                                                                       hint:GL_STATIC_DRAW];
    
    self.normalBuffer = [[VertexBufferObject alloc] initWithStride:3 * sizeof(float)
                                                    numOfVerticies:sizeof(sphereNormals)/(sizeof(float) * 3 )
                                                           dataPtr:sphereNormals
                                                              hint:GL_STATIC_DRAW];
    [self loadTexture];
    
    
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
@end
