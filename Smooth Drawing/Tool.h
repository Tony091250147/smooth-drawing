//
//  Tool.h
//  Smooth Drawing
//
//  Created by tony on 13-5-22.
//
//

#import "cocos2d.h"
@protocol ToolDelegate;

@protocol Tool <NSObject>


@property (nonatomic, strong) id <ToolDelegate> delegate;
/**
 * In touchBeganWithPoint:, touchMovedWithPoint:, touchEndedWithPoint:
 * @param point is UIPoint
 */
- (void)touchBeganWithPoint:(CGPoint)point velocity:(CGPoint)velocity;
- (void)touchMovedWithPoint:(CGPoint)point velocity:(CGPoint)velocity;
- (void)touchEndedWithPoint:(CGPoint)point velocity:(CGPoint)velocity;

- (void)toolShouldDrawInTexture:(CCRenderTexture*)renderTexture;


@end

@protocol ToolDelegate  <NSObject>

- (UIView*)viewForUseWithTool:(id<Tool>)t;
- (ccColor4F)fillColor;
- (CGFloat)lineWidth;
- (CCGLProgram *)shaderProgram;

@end