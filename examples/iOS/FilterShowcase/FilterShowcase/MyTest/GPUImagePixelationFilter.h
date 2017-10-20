//
//  GPUImagePixelationFilter.h
//  FilterShowcase
//
//  Created by Naver on 2017. 8. 18..
//  Copyright © 2017년 Cell Phone. All rights reserved.
//

#import <GPUImageFilter.h>
@interface GPUImagePixelationFilter : GPUImageFilter

-(void) setTexelScale:(GLfloat)scale;
@end
