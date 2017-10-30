//
//  DefualtMesh.h
//  SimpleImageFilter
//
//  Created by Naver on 2017. 10. 28..
//  Copyright © 2017년 Cell Phone. All rights reserved.
//

#ifndef DefualtMesh_h
#define DefualtMesh_h

GLfloat testV[12] = {
    -1.0, -1.0, -1.0,
    1.0, -1.0, -1.0,
    -1.0, 1.0, -1.0,
    1.0, 1.0, -1.0
    //    -1.0, -1.0, -0.1,
    //    1.0, -1.0, -0.1,
    //    -1.0, 1.0, -0.1,
    //    1.0, 1.0, -0.1
};

GLfloat testT[8] = {
    0.0, 0.0,
    1.0, 0.0,
    0.0, 1.0,
    1.0, 1.0
};

GLfloat testN[12] = {
    0.0, 0.0, 1.0,
    0.0, 0.0, 1.0,
    0.0, 0.0, 1.0,
    0.0, 0.0, 1.0,
    0.0, 0.0, 1.0,
};


#endif /* DefualtMesh_h */
