//
//  ToolHeader.h
//  Smooth Drawing
//
//  Created by tony on 13-5-23.
//
//

#import "cocos2d.h"

#ifndef Smooth_Drawing_ToolHeader_h
#define Smooth_Drawing_ToolHeader_h

typedef struct _LineVertex {
    CGPoint pos;
    float z;
    ccColor4F color;
} LineVertex;

#define ADD_TRIANGLE(A, B, C, Z) vertices[index].pos = A, vertices[index++].z = Z, vertices[index].pos = B, vertices[index++].z = Z, vertices[index].pos = C, vertices[index++].z = Z

#endif
