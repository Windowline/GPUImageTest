//
//  GPUImageOldPhotoStyleDateFilter.h
//  FilterShowcase
//
//  Created by Naver on 2017. 8. 20..
//  Copyright © 2017년 Cell Phone. All rights reserved.
//

#import <GPUImage.h>
#import <GLKit/GLKit.h>
@interface  DateDrawingObject : NSObject
@property (nonatomic) GLKMatrix4 vertexMat;
@property (nonatomic, strong) GLKTextureInfo* normalTextureInfo;
@property (nonatomic, strong) GLKTextureInfo* addTextureInfo;
- (id)initWithNormalTextureInfo:(GLKTextureInfo *)normalTexInfo addTextureInfo:(GLKTextureInfo *)addTexInfo vertexMat:(GLKMatrix4)vertexMat;
@end

@interface GPUImageOldPhotoStyleDateFilter : GPUImageFilter

@end
