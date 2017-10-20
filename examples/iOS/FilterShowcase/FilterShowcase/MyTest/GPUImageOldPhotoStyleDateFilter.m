//
//  GPUImageOldPhotoStyleDateFilter.m
//  FilterShowcase
//
//  Created by Naver on 2017. 8. 20..
//  Copyright © 2017년 Cell Phone. All rights reserved.
//

#import "GPUImageOldPhotoStyleDateFilter.h"


NSString *const kGPUImageOldPhtoDateStyleVertexShaderString = SHADER_STRING(
                                                                                
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


NSString *const kGPUImageOldPhtoDateStyleVertexFragmentShaderString = SHADER_STRING(
                                                                                    
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


@implementation DateDrawingObject

- (id)initWithNormalTextureInfo:(GLKTextureInfo *)normalTexInfo addTextureInfo:(GLKTextureInfo *)addTexInfo vertexMat:(GLKMatrix4)vertexMat
{
    self = [super init];
    _normalTextureInfo = normalTexInfo;
    _addTextureInfo = addTexInfo;
    _vertexMat = vertexMat;
    return self;
}

@end


@implementation GPUImageOldPhotoStyleDateFilter
{
    NSDateFormatter *_dateFormatter;
    NSString *_curYear;
    NSString *_curMonth;
    NSString *_curDay;
    
    NSArray *_addNumberTextures;
    NSArray *_normalNumberTextures;
    
    GLuint _vtxMatUniform;
    GLuint _isAddBlendUniform;
    GLuint _modelTexture;
    
    NSArray *_drawingObjs;
    
    CGSize _preFBOSize;
    
    int _date, _date2;
    int _month, _month2;
    int _year, _year2;
}

- (id)init
{
    self =  [super initWithVertexShaderFromString:kGPUImageOldPhtoDateStyleVertexShaderString fragmentShaderFromString:kGPUImageOldPhtoDateStyleVertexFragmentShaderString];
    _preFBOSize = CGSizeZero;
    [self setDate];
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

//- (void)setDate
//{
//    NSDateFormatter *yearFormat = [[NSDateFormatter alloc] init];
//    NSDateFormatter *monthFormat = [[NSDateFormatter alloc] init];
//    NSDateFormatter *dayFormat = [[NSDateFormatter alloc] init];
//    
//    [yearFormat setDateFormat:@"yyyy"];
//    [monthFormat setDateFormat:@"mm"];
//    [dayFormat setDateFormat:@"dd"];
//    
//    NSString *newYear = [yearFormat stringFromDate:[NSDate date]];
//    NSString *newMonth = [monthFormat stringFromDate:[NSDate date]];
//    NSString *newDay = [dayFormat stringFromDate:[NSDate date]];
//    
//    _date = [newDay intValue] % 10;
//    _date2 = [newDay intValue] / 10;
//    
//    _month =  [newMonth intValue] % 10;
//    _month2 = [newMonth intValue] / 10;
//    
//    _year = [newYear intValue] % 10;
//    _year2 = ([newYear intValue] / 10) % 10;
//    
//    _curYear = newYear;
//    _curMonth = newMonth;
//    _curDay = newDay;
//}

- (void)setDate
{
    NSDate *date = [NSDate date];
    NSCalendar *caleneder = [NSCalendar currentCalendar];
    unsigned int flag = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *dateComponents = [caleneder components:flag fromDate:date];
    
    _date = (int)[dateComponents day] % 10;
    _date2 = (int)[dateComponents day] / 10;

    _month =  (int)[dateComponents month] % 10;
    _month2 = (int)[dateComponents month] / 10;

    _year = [dateComponents year] % 10;
    _year2 = ([dateComponents year] / 10) % 10;
    
}

- (void)loadNumberTextures
{
    //load add
    
    NSMutableArray *addNumTextures = [NSMutableArray array];
    NSMutableArray *normalNumTextures = [NSMutableArray array];
    
    for(int i=0; i<10; i++) {
        
        UIImage *addImg = [UIImage imageNamed:[NSString stringWithFormat:@"addNumber_%d", i]];
        GLKTextureInfo *addTextureInfo = [GLKTextureLoader textureWithCGImage:[addImg CGImage] options:nil error:NULL];
        glActiveTexture(GL_TEXTURE3);
        glBindTexture(GL_TEXTURE_2D, addTextureInfo.name); // 현 텍스처 유닛에 텍스처id 로드
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST); // 텍스처 파라미터 지정
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        
        [addNumTextures addObject:addTextureInfo];
        
        
        UIImage *normalImg = [UIImage imageNamed:[NSString stringWithFormat:@"normalNumber_%d", i]];
        GLKTextureInfo *normalTextureInfo = [GLKTextureLoader textureWithCGImage:[normalImg CGImage] options:nil error:NULL];
        glActiveTexture(GL_TEXTURE3);
        glBindTexture(GL_TEXTURE_2D, normalTextureInfo.name); // 현 텍스처 유닛에 텍스처id 로드
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST); // 텍스처 파라미터 지정
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        
        [normalNumTextures addObject:normalTextureInfo];
    }
    
    UIImage *addImg = [UIImage imageNamed:@"addNumber_'"];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:[addImg CGImage] options:nil error:NULL];
    [addNumTextures addObject:textureInfo];
    
    UIImage *normalImg = [UIImage imageNamed:@"normalNumber_'"];
    GLKTextureInfo *normalTextureInfo = [GLKTextureLoader textureWithCGImage:[normalImg CGImage] options:nil error:NULL];
    [normalNumTextures addObject:normalTextureInfo];
    
    _addNumberTextures = addNumTextures;
    _normalNumberTextures = normalNumTextures;
}
    
    

-(void) renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates
{
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        return;
    }
    
    if(!CGSizeEqualToSize(_preFBOSize, self.sizeOfFBO)) {
        [self generateDrawingObjects];
    }
    _preFBOSize = self.sizeOfFBO;
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture)
    {
        [outputFramebuffer lock];
    }
    
    [self setUniformsForProgramAtIndex:0];
    

    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    
    glUniform1i(filterInputTextureUniform, 2);
    glUniformMatrix4fv(_vtxMatUniform, 1, FALSE, GLKMatrix4Identity.m);
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [self drawDateDrawingObjectsWithhVertices:vertices textureCoordinates:textureCoordinates];
    
    [firstInputFramebuffer unlock];
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

-(void) drawDateDrawingObjectsWithhVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates
{
    NSArray *drawObjs = _drawingObjs;
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    glUniform1f(_isAddBlendUniform, 0.0);

    for(DateDrawingObject *drawObj in drawObjs) {
        
        
        glActiveTexture(GL_TEXTURE2);
        glBindTexture(GL_TEXTURE_2D, drawObj.normalTextureInfo.name);
        glUniform1i(filterInputTextureUniform, 2);
        
        glUniformMatrix4fv(_vtxMatUniform, 1, FALSE, drawObj.vertexMat.m);
        glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
        glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
        
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
    }
    
    glDisable(GL_BLEND);
    
//    glActiveTexture(GL_TEXTURE2);
//    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
//    glUniform1i(filterInputTextureUniform, 2);
//    
//    glUniform1f(_isAddBlendUniform, 1.0);
//    
//    for(DateDrawingObject *drawObj in drawObjs) {
//
//        glActiveTexture(GL_TEXTURE4);
//        glBindTexture(GL_TEXTURE_2D, drawObj.addTextureInfo.name);
//        glUniform1i(_modelTexture, 4);
//        glUniformMatrix4fv(_vtxMatUniform, 1, FALSE, drawObj.vertexMat.m);
//        glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
//        glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
//        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
//    }
//    
    
}


//-(void) generateDrawingObjects
//{
//    if(CGSizeEqualToSize(self.sizeOfFBO, CGSizeZero)) {
//        return;
//    }
//    
//    NSMutableArray *drawingObjs = [NSMutableArray array];
//    
//    const CGSize designSize = CGSizeMake(1080.f, 1920.f);
//    
//    const CGSize size = CGSizeMake(62.f, 42.f);
//    const GLfloat leftMarign = 60.f;
//    const GLfloat dateBottom = 190.f;
//    const GLfloat monthBottom = dateBottom + (42.f*2) + 24.f;
//    const GLfloat yearBottom = monthBottom + (42.f*2) + 24.f;
//    const GLfloat quotBottom = yearBottom + (42.f*2);
//    
//    const GLfloat applyRatio = self.sizeOfFBO.width / designSize.width;
////    const GLfloat applyRatio = 1.0f;
//    const GLfloat aspectRatio = self.sizeOfFBO.width / self.sizeOfFBO.height;
//    
//    CGSize normalize = CGSizeMake(1.f / self.sizeOfFBO.width * 2.0,  1.f / self.sizeOfFBO.height * 2.0);
//    CGSize scale = CGSizeMake(size.width * applyRatio * normalize.width, size.height * applyRatio * normalize.height);
//    
//    GLKMatrix4 scaleMat = GLKMatrix4MakeScale(scale.width * aspectRatio, scale.height, 1.0);
//    GLKMatrix4 projectionMat = GLKMatrix4MakeOrtho(-aspectRatio, aspectRatio, -1, 1, -1, 1);
//    
//    
//    
//    
//      //make date draw objs-1
// //   GLKMatrix4 dateVertexMat = GLKMatrix4Identity;
//    
//    GLKMatrix4 dateVertexMat = scaleMat;
////    dateVertexMat = GLKMatrix4Multiply(dateVertexMat, GLKMatrix4MakeOrtho(-aspectRatio, aspectRatio, -1.0, 1.0, -1.0, 1.0));
////    dateVertexMat = GLKMatrix4Multiply(dateVertexMat, GLKMatrix4MakeTranslation(-aspectRatio ,-1.f, 0));
////    dateVertexMat = GLKMatrix4Multiply(dateVertexMat, scaleMat);
//    
//    
////    dateVertexMat = GLKMatrix4Multiply(
////                                       GLKMatrix4MakeTranslation((-1.f + (scale.width / 2.f) +(leftMarign * applyRatio * normalize.width)) * aspectRatio,
////                                                                  (-1.f + (scale.height / 2.f) + (dateBottom * applyRatio * normalize.height))
////                                                                 *(-1.0),
////                                                                 0), dateVertexMat);
//    
//    dateVertexMat = GLKMatrix4Multiply(
//                                       GLKMatrix4MakeTranslation((-1.f + (scale.width / 2.f)) * aspectRatio,
//                                                                 (-1.f + (scale.height / 2.f))
//                                                                 *(-1.0),
//                                                                 0), dateVertexMat);
//    
////    dateVertexMat = GLKMatrix4Multiply(
////                                       GLKMatrix4MakeTranslation(-aspectRatio ,1.f, 0), dateVertexMat);
//
//    dateVertexMat = GLKMatrix4Multiply(projectionMat, dateVertexMat);
//
//  
//    DateDrawingObject *dateDrawingObj = [[DateDrawingObject alloc] initWithNormalTextureInfo:_normalNumberTextures[_date] addTextureInfo:_addNumberTextures[_date] vertexMat:dateVertexMat];
//    
//    [drawingObjs addObject:dateDrawingObj];
//    
//    
//    
//    //make date draw objs-2
//    GLKMatrix4 dateVertexMat2 = scaleMat;
//
//    dateVertexMat2 = GLKMatrix4Multiply(
//                                       GLKMatrix4MakeTranslation((-1.f + (scale.width / 2.f) +(leftMarign * applyRatio * normalize.width)) * aspectRatio,
//                                                                 (-1.f + (scale.height / 2.f) + ((dateBottom + 42.f) * applyRatio * normalize.height))*(-1.0),
//                                                                 0), dateVertexMat2);
//
//    
//    dateVertexMat2 = GLKMatrix4Multiply(projectionMat, dateVertexMat2);
//    
//    DateDrawingObject *dateDrawingObj2 = [[DateDrawingObject alloc] initWithNormalTextureInfo:_normalNumberTextures[_date2] addTextureInfo:_addNumberTextures[_date2] vertexMat:dateVertexMat2];
//    
//    [drawingObjs addObject:dateDrawingObj2];
//    
//    
//    
//    
//    //month
//    GLKMatrix4 monthMat = scaleMat;
//    monthMat = GLKMatrix4Multiply( GLKMatrix4MakeTranslation((-1.f + (scale.width / 2.f) +(leftMarign * applyRatio * normalize.width)) * aspectRatio,
//                                                             (-1.f + (scale.height / 2.f) + (monthBottom * applyRatio * normalize.height))
//                                                             *(-1.0),
//                                                             0), monthMat);
//
//    monthMat = GLKMatrix4Multiply(projectionMat, monthMat);
//    
//    DateDrawingObject *mothDrawingObj = [[DateDrawingObject alloc] initWithNormalTextureInfo:_normalNumberTextures[_month] addTextureInfo:_addNumberTextures[_month] vertexMat:monthMat];
//    
//    [drawingObjs addObject:mothDrawingObj];
//    
//    
//    //month 2
//    GLKMatrix4 monthMat2 = scaleMat;
//    monthMat2 = GLKMatrix4Multiply( GLKMatrix4MakeTranslation((-1.f + (scale.width / 2.f) +(leftMarign * applyRatio * normalize.width)) * aspectRatio,
//                                                             (-1.f + (scale.height / 2.f) + ((monthBottom + 42.f) * applyRatio * normalize.height))
//                                                             *(-1.0),
//                                                             0), monthMat2);
//    
//    monthMat2 = GLKMatrix4Multiply(projectionMat, monthMat2);
//    
//    DateDrawingObject *mothDrawingObj2 = [[DateDrawingObject alloc] initWithNormalTextureInfo:_normalNumberTextures[_month2] addTextureInfo:_addNumberTextures[_month2] vertexMat:monthMat2];
//    
//    [drawingObjs addObject:mothDrawingObj2];
//
//    
//    
//    _drawingObjs = drawingObjs;
//}

-(void) generateDrawingObjects
{
    if(CGSizeEqualToSize(self.sizeOfFBO, CGSizeZero)) {
        return;
    }
    
    NSMutableArray *drawingObjs = [NSMutableArray array];
    
    const CGSize designSize = CGSizeMake(1080.f, 1920.f);
    
    const CGSize size = CGSizeMake(62.f, 42.f);
    const GLfloat leftMarign = 60.f;
    const GLfloat dateBottom = 190.f;
    const GLfloat monthBottom = dateBottom + (42.f*2) + 24.f;
    const GLfloat yearBottom = monthBottom + (42.f*2) + 24.f;
    const GLfloat quotBottom = yearBottom + (42.f*2);
    
    const GLfloat applyRatio = self.sizeOfFBO.width / designSize.width;
    //    const GLfloat applyRatio = 1.0f;
    const GLfloat aspectRatio = self.sizeOfFBO.width / self.sizeOfFBO.height;
    
    CGSize normalize = CGSizeMake(1.f / self.sizeOfFBO.width * 2.0,  1.f / self.sizeOfFBO.height * 2.0);
    CGSize scale = CGSizeMake(size.width * applyRatio, size.height * applyRatio);
    
    GLKMatrix4 scaleMat = GLKMatrix4MakeScale(scale.width / 2.f, scale.height / 2.f, 1.0); //원본이 2
    GLKMatrix4 projectionMat = GLKMatrix4MakeOrtho(0, self.sizeOfFBO.width, 0, self.sizeOfFBO.height, -1, 1);
    
    
    
    
    //make date draw objs-1
    GLKMatrix4 dateVertexMat = scaleMat;
    dateVertexMat = GLKMatrix4Multiply(GLKMatrix4MakeTranslation((scale.width / 2.f) + (leftMarign * applyRatio),
                                                                 self.sizeOfFBO.height - ((scale.height / 2.f) + (dateBottom * applyRatio)),
                                                                 0),
                                                                dateVertexMat);

    dateVertexMat = GLKMatrix4Multiply(projectionMat, dateVertexMat);
   
    DateDrawingObject *dateDrawingObj = [[DateDrawingObject alloc] initWithNormalTextureInfo:_normalNumberTextures[_date] addTextureInfo:_addNumberTextures[_date] vertexMat:dateVertexMat];
    
    [drawingObjs addObject:dateDrawingObj];

    
    
    //make date draw objs-2
    GLKMatrix4 dateVertexMat2 = scaleMat;

    dateVertexMat2 = GLKMatrix4Multiply(
                                        GLKMatrix4MakeTranslation((scale.width / 2.f) +(leftMarign * applyRatio),
                                                                  self.sizeOfFBO.height - ((scale.height / 2.f) + ((dateBottom + 42.f) * applyRatio)),
                                                                  0), dateVertexMat2);
    
    
    dateVertexMat2 = GLKMatrix4Multiply(projectionMat, dateVertexMat2);

    DateDrawingObject *dateDrawingObj2 = [[DateDrawingObject alloc] initWithNormalTextureInfo:_normalNumberTextures[_date2] addTextureInfo:_addNumberTextures[_date2] vertexMat:dateVertexMat2];

    [drawingObjs addObject:dateDrawingObj2];

    
    
    
    //month
    GLKMatrix4 monthMat = scaleMat;
    monthMat = GLKMatrix4Multiply( GLKMatrix4MakeTranslation((scale.width / 2.f) +(leftMarign * applyRatio),
                                                             self.sizeOfFBO.height - ((scale.height / 2.f) + (monthBottom * applyRatio)),
                                                    
                                                             0), monthMat);
    
    monthMat = GLKMatrix4Multiply(projectionMat, monthMat);
    
    DateDrawingObject *mothDrawingObj = [[DateDrawingObject alloc] initWithNormalTextureInfo:_normalNumberTextures[_month] addTextureInfo:_addNumberTextures[_month] vertexMat:monthMat];
    
    [drawingObjs addObject:mothDrawingObj];
    
    
    //month 2
    GLKMatrix4 monthMat2 = scaleMat;
    monthMat2 = GLKMatrix4Multiply( GLKMatrix4MakeTranslation( (scale.width / 2.f) + (leftMarign * applyRatio),
                                                               self.sizeOfFBO.height - ((scale.height / 2.f) + ((monthBottom + 42.f) * applyRatio)), 0), monthMat2);
                                   
    
    monthMat2 = GLKMatrix4Multiply(projectionMat, monthMat2);
    
    DateDrawingObject *mothDrawingObj2 = [[DateDrawingObject alloc] initWithNormalTextureInfo:_normalNumberTextures[_month2] addTextureInfo:_addNumberTextures[_month2] vertexMat:monthMat2];
    
    [drawingObjs addObject:mothDrawingObj2];
    
    
    
    
    
//    GLKMatrix4 yearMat = scaleMat;
//    yearMat = GLKMatrix4Multiply( GLKMatrix4MakeTranslation((scale.width / 2.f) +(leftMarign * applyRatio),
//                                                             self.sizeOfFBO.height - ((scale.height / 2.f) + (yearBottom * applyRatio)),
//                                                             
//                                                             0), yearMat);
//    
//    yearMat = GLKMatrix4Multiply(projectionMat, yearMat);
//    
//    DateDrawingObject *yearDrawingObj = [[DateDrawingObject alloc] initWithNormalTextureInfo:_normalNumberTextures[_month] addTextureInfo:_addNumberTextures[_month] vertexMat:monthMat];
//    
//    [drawingObjs addObject:mothDrawingObj];
//    
//    
//    //month 2
//    GLKMatrix4 yearMat2 = scaleMat;
//    monthMat2 = GLKMatrix4Multiply( GLKMatrix4MakeTranslation( (scale.width / 2.f) + (leftMarign * applyRatio),
//                                                              self.sizeOfFBO.height - ((scale.height / 2.f) + ((monthBottom + 42.f) * applyRatio)), 0), monthMat2);
//    
//    
//    monthMat2 = GLKMatrix4Multiply(projectionMat, monthMat2);
//    
//    DateDrawingObject *mothDrawingObj2 = [[DateDrawingObject alloc] initWithNormalTextureInfo:_normalNumberTextures[_month2] addTextureInfo:_addNumberTextures[_month2] vertexMat:monthMat2];
//    
//    [drawingObjs addObject:mothDrawingObj2];
    
    
    
    _drawingObjs = drawingObjs;
}

@end
