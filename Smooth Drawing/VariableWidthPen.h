//
//  VariableWidthPen.h
//  Smooth Drawing
//
//  Created by tony on 13-5-22.
//
//

#import <Foundation/Foundation.h>
#import "Tool.h"
@interface VariableWidthPen : NSObject <Tool>

+ (VariableWidthPen*)sharedVariableWidthPen;

@end
