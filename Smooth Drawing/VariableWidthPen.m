//
//  VariableWidthPen.m
//  Smooth Drawing
//
//  Created by tony on 13-5-22.
//
//

#import "VariableWidthPen.h"
#import "SynthesizeSingleton.h"
#import "cocos2d.h"
#import "LinePoint.h"
#import "ToolHeader.h"
@interface VariableWidthPen ()
{
    id <ToolDelegate> _delegate;
}

@property (nonatomic, strong) NSMutableArray *velocities;

@end

@implementation VariableWidthPen
SINGLETON(VariableWidthPen);

- (id)init
{
    self = [super init];
    if (self) {
        self.velocities = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)touchBeganWithPoint:(CGPoint)point velocity:(CGPoint)velocity
{
    CGPoint glPoint = [[CCDirector sharedDirector] convertToGL:point];
    [self.points removeAllObjects];
    [self.velocities removeAllObjects];
    
    float size = [self extractSize:velocity];
    
    [self startNewLineFrom:glPoint withSize:size];
    [self addPoint:glPoint withSize:size];
    [self addPoint:glPoint withSize:size];
}

- (void)touchMovedWithPoint:(CGPoint)point velocity:(CGPoint)velocity
{
    CGPoint glPoint = [[CCDirector sharedDirector] convertToGL:point];
    float eps = 1.5f;
    if ([self.points count] > 0) {
        float length = ccpLength(ccpSub([(LinePoint *)[self.points lastObject] pos], glPoint));
        
        if (length < eps) {
            return;
        }
    }
    float size = [self extractSize:velocity];
    [self addPoint:glPoint withSize:size];
}

- (void)touchEndedWithPoint:(CGPoint)point velocity:(CGPoint)velocity
{
    CGPoint glPoint = [[CCDirector sharedDirector] convertToGL:point];
    float size = [self extractSize:velocity];
    [self endLineAt:glPoint withSize:size];
}

- (void)toolShouldDrawInTexture:(CCRenderTexture*)renderTexture
{

    [renderTexture begin];
    
    NSMutableArray *smoothedPoints = [self calculateSmoothLinePoints];
    if (smoothedPoints) {
        [self drawLines:smoothedPoints withColor:[self.delegate fillColor]];
    }
    [renderTexture end];
}

- (float)extractSize:(CGPoint)velocity
{
    //! result of trial & error
    
    float vel = ccpLength(velocity);
    //    NSLog(@"vel:%f vel in view:%@",vel, NSStringFromCGPoint([panGestureRecognizer velocityInView:panGestureRecognizer.view]));
    float size = vel / 166.0f;
    size = clampf(size, 1, 40);
    
    if ([self.velocities count] > 1) {
        size = size * 0.2f + [[self.velocities objectAtIndex:[self.velocities count] - 1] floatValue] * 0.8f;
    }
    [self.velocities addObject:[NSNumber numberWithFloat:size]];
    return size;
}

#pragma mark - get & set method for @property delegate
- (id<ToolDelegate>)delegate
{
    return _delegate;
}

- (void)setDelegate:(id<ToolDelegate>)delegate
{
    _delegate = delegate;
}
@end
