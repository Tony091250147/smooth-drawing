//
//  Pen.h
//  Smooth Drawing
//
//  Created by tony on 13-5-23.
//
//

#import <Foundation/Foundation.h>
#import "Tool.h"

@interface Pen : NSObject <Tool>

@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) NSMutableArray *circlesPoints;
@property (nonatomic, assign) BOOL connectingLine;
@property (nonatomic, assign) CGPoint prevC;
@property (nonatomic, assign) CGPoint prevD;
@property (nonatomic, assign) CGPoint prevG;
@property (nonatomic, assign) CGPoint prevI;
@property (nonatomic, assign) CGFloat overdraw;
@property (nonatomic, strong) CCRenderTexture *renderTexture;
@property (nonatomic, assign) BOOL finishingLine;

- (void)drawLines:(NSArray *)linePoints withColor:(ccColor4F)color;

- (void)startNewLineFrom:(CGPoint)newPoint withSize:(CGFloat)aSize;
- (void)endLineAt:(CGPoint)aEndPoint withSize:(CGFloat)aSize;
- (void)addPoint:(CGPoint)newPoint withSize:(CGFloat)size;

- (NSMutableArray *)calculateSmoothLinePoints;

+ (Pen*)sharedPen;

@end
