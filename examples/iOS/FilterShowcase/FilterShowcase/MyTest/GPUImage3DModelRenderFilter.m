//
//  GPUImage3DModelRenderFilter.m
//  FilterShowcase
//
//  Created by Naver on 2017. 10. 18..
//  Copyright © 2017년 Cell Phone. All rights reserved.
//

#import "GPUImage3DModelRenderFilter.h"
#import "sphere2.h"

NSString *const k3dModelRenderVertex = SHADER_STRING(
                                                                            
    attribute vec4 position;
    attribute vec4 inputTextureCoordinate;
    varying vec2 textureCoordinate;
    varying vec2 objectTextureCoordinate;
    uniform mat4 vtxMat;

    void main()
    {
        vec4 pos = vtxMat * position;
        gl_Position = pos;
        objectTextureCoordinate = vec2( (pos.x + 1.0)/2.0, (pos.y + 1.0) / 2.0 );
        textureCoordinate = inputTextureCoordinate.xy;
        
    }
);


NSString *const k3dMedelRederFrag = SHADER_STRING(
    precision highp float;
    varying highp vec2 textureCoordinate;
    varying vec2 objectTextureCoordinate;
    uniform sampler2D inputImageTexture;
    uniform sampler2D modelTexture;
    uniform float isAddBlend;

    void main()
    {
        //       if(isAddBlend < 0.5) {
        gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
        //gl_FragColor = vec4(0.5, 0.5, 0.5, 1.0);
        //        } else {
        //            vec4 backgroundColor = texture2D(inputImageTexture, objectTextureCoordinate);
        //            vec4 objColor = texture2D(modelTexture, textureCoordinate);
        //            vec3 addBlend = min(backgroundColor.rgb + objColor.rgb, vec3(1.0));
        //            vec3 addBlend = backgroundColor.rgb + objColor.rgb;
        //            gl_FragColor = vec4(addBlend.rgb, objColor.a);
        //            gl_FragColor = texture2D(modelTexture, textureCoordinate);
        //            gl_FragColor = mix(backgroundColor, objColor, 0.75);
        //        }
        
    }
);

@implementation GPUImage3DModelRenderFilter


- (id)init
{
    self =  [super initWithVertexShaderFromString:k3dModelRenderVertex
                         fragmentShaderFromString:k3dMedelRederFrag];
    [self loadNumberTextures];
    [self initGLParams];
    [self generateDrawingObjects];
    return self;
}

- (void)initGLParams
{
    _vtxMatUniform = [filterProgram uniformIndex:@"vtxMat"];
    _modelTexture = [filterProgram uniformIndex:@"modelTexture"];
    _isAddBlendUniform = [filterProgram uniformIndex:@"isAddBlend"];
}

@end
