//
//  GPUImageObjectRenderFilter.h
//  SimpleImageFilter
//
//  Created by Naver on 2017. 10. 19..
//  Copyright © 2017년 Cell Phone. All rights reserved.
//

#import "GPUImage.h"

@interface GPUImageObjectRenderFilter : GPUImageFilter

@property(nonatomic) NSTimeInterval animateInterval;
@property(nonatomic) int animateRepeatCnt;

- (void)renderObjectsWithAnimationRepeatCount:(int)repeatCnt repeatInterval:(NSTimeInterval)interval;
@end
