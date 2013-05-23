//
//  Pen.m
//  Smooth Drawing
//
//  Created by tony on 13-5-23.
//
//

#import "Pen.h"
#import "SynthesizeSingleton.h"
#import "ToolHeader.h"
#import "LinePoint.h"

@interface Pen ()
{
    id <ToolDelegate> _delegate;
}

@end

@implementation Pen
SINGLETON(Pen);

- (id)init
{
    self = [super init];
    if (self) {
        self.points = [[NSMutableArray alloc] init];
        self.circlesPoints = [[NSMutableArray alloc] init];
        self.overdraw = 3;
    }
    return self;
}

- (void)touchBeganWithPoint:(CGPoint)point velocity:(CGPoint)velocity
{
    CGPoint glPoint = [[CCDirector sharedDirector] convertToGL:point];
    [self.points removeAllObjects];

    float size = [self.delegate lineWidth];
    
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
    float size = [self.delegate lineWidth];
    [self addPoint:glPoint withSize:size];
}

- (void)touchEndedWithPoint:(CGPoint)point velocity:(CGPoint)velocity
{
    CGPoint glPoint = [[CCDirector sharedDirector] convertToGL:point];
    float size = [self.delegate lineWidth];
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

- (void)drawLines:(NSArray *)linePoints withColor:(ccColor4F)color
{
    unsigned int numberOfVertices = ([linePoints count] - 1) * 18;
    LineVertex *vertices = calloc(sizeof(LineVertex), numberOfVertices);
    
    CGPoint prevPoint = [(LinePoint *)[linePoints objectAtIndex:0] pos];
    float prevValue = [(LinePoint *)[linePoints objectAtIndex:0] width];
    float curValue;
    int index = 0;
    for (int i = 1; i < [linePoints count]; ++i) {
        LinePoint *pointValue = [linePoints objectAtIndex:i];
        CGPoint curPoint = [pointValue pos];
        curValue = [pointValue width];
        
        //! equal points, skip them
        if (ccpFuzzyEqual(curPoint, prevPoint, 0.0001f)) {
            continue;
        }
        
        CGPoint dir = ccpSub(curPoint, prevPoint);
        CGPoint perpendicular = ccpNormalize(ccpPerp(dir));
        CGPoint A = ccpAdd(prevPoint, ccpMult(perpendicular, prevValue / 2));
        CGPoint B = ccpSub(prevPoint, ccpMult(perpendicular, prevValue / 2));
        CGPoint C = ccpAdd(curPoint, ccpMult(perpendicular, curValue / 2));
        CGPoint D = ccpSub(curPoint, ccpMult(perpendicular, curValue / 2));
        
        //! continuing line
        if (self.connectingLine || index > 0) {
            A = self.prevC;
            B = self.prevD;
        } else if (index == 0) {
            //! circle at start of line, revert direction
            [self.circlesPoints addObject:pointValue];
            [self.circlesPoints addObject:[linePoints objectAtIndex:i - 1]];
        }
        
        ADD_TRIANGLE(A, B, C, 1.0f);
        ADD_TRIANGLE(B, C, D, 1.0f);
        
        self.prevD = D;
        self.prevC = C;
        if (self.finishingLine && (i == [linePoints count] - 1)) {
            [self.circlesPoints addObject:[linePoints objectAtIndex:i - 1]];
            [self.circlesPoints addObject:pointValue];
            self.finishingLine = NO;
        }
        prevPoint = curPoint;
        prevValue = curValue;
     
        //! Add overdraw
        CGPoint F = ccpAdd(A, ccpMult(perpendicular, self.overdraw));
        CGPoint G = ccpAdd(C, ccpMult(perpendicular, self.overdraw));
        CGPoint H = ccpSub(B, ccpMult(perpendicular, self.overdraw));
        CGPoint I = ccpSub(D, ccpMult(perpendicular, self.overdraw));
        
        //! end vertices of last line are the start of this one, also for the overdraw
        if (self.connectingLine || index > 6) {
            F = self.prevG;
            H = self.prevI;
        }
        
        self.prevG = G;
        self.prevI = I;
        
        ADD_TRIANGLE(F, A, G, 2.0f);
        ADD_TRIANGLE(A, G, C, 2.0f);
        ADD_TRIANGLE(B, H, D, 2.0f);
        ADD_TRIANGLE(H, D, I, 2.0f);

    }
    [self fillLineTriangles:vertices count:index withColor:color];
    
    if (index > 0) {
        self.connectingLine = YES;
    }
    
    free(vertices);
}

- (void)fillLineTriangles:(LineVertex *)vertices count:(NSUInteger)count withColor:(ccColor4F)color
{
    [[self.delegate shaderProgram] use];
    [[self.delegate shaderProgram] setUniformForModelViewProjectionMatrix];
    
    ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color);
    
    ccColor4F fullColor = color;
    ccColor4F fadeOutColor = color;
    fadeOutColor.a = 0;
    
    for (int i = 0; i < count / 18; ++i) {
        for (int j = 0; j < 6; ++j) {
            vertices[i * 18 + j].color = color;
        }

        //! FAG
        vertices[i * 18 + 6].color = fadeOutColor;
        vertices[i * 18 + 7].color = fullColor;
        vertices[i * 18 + 8].color = fadeOutColor;
        
        //! AGD
        vertices[i * 18 + 9].color = fullColor;
        vertices[i * 18 + 10].color = fadeOutColor;
        vertices[i * 18 + 11].color = fullColor;
        
        //! BHC
        vertices[i * 18 + 12].color = fullColor;
        vertices[i * 18 + 13].color = fadeOutColor;
        vertices[i * 18 + 14].color = fullColor;
        
        //! HCI
        vertices[i * 18 + 15].color = fadeOutColor;
        vertices[i * 18 + 16].color = fullColor;
        vertices[i * 18 + 17].color = fadeOutColor;

    }
    
    glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, sizeof(LineVertex), &vertices[0].pos);
    glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_FLOAT, GL_FALSE, sizeof(LineVertex), &vertices[0].color);
    
    
    glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glDrawArrays(GL_TRIANGLES, 0, (GLsizei)count);
    
    for (unsigned int i = 0; i < [self.circlesPoints count] / 2; ++i) {
        LinePoint *prevPoint = [self.circlesPoints objectAtIndex:i * 2];
        LinePoint *curPoint = [self.circlesPoints objectAtIndex:i * 2 + 1];
        CGPoint dirVector = ccpNormalize(ccpSub(curPoint.pos, prevPoint.pos));
        
        [self fillLineEndPointAt:curPoint.pos direction:dirVector radius:curPoint.width * 0.5f andColor:color];
    }
    [self.circlesPoints removeAllObjects];
}

- (void)fillLineEndPointAt:(CGPoint)center direction:(CGPoint)aLineDir radius:(CGFloat)radius andColor:(ccColor4F)color
{
    int numberOfSegments = 32;
    LineVertex *vertices = malloc(sizeof(LineVertex) * numberOfSegments * 9);
    float anglePerSegment = (float)(M_PI / (numberOfSegments - 1));
    
    //! we need to cover M_PI from this, dot product of normalized vectors is equal to cos angle between them... and if you include rightVec dot you get to know the correct direction :)
    CGPoint perpendicular = ccpPerp(aLineDir);
    float angle = acosf(ccpDot(perpendicular, CGPointMake(0, 1)));
    float rightDot = ccpDot(perpendicular, CGPointMake(1, 0));
    if (rightDot < 0.0f) {
        angle *= -1;
    }
    
    CGPoint prevPoint = center;
    CGPoint prevDir = ccp(sinf(0), cosf(0));
    for (unsigned int i = 0; i < numberOfSegments; ++i) {
        CGPoint dir = ccp(sinf(angle), cosf(angle));
        CGPoint curPoint = ccp(center.x + radius * dir.x, center.y + radius * dir.y);
        vertices[i * 9 + 0].pos = center;
        vertices[i * 9 + 1].pos = prevPoint;
        vertices[i * 9 + 2].pos = curPoint;
        
        //! fill rest of vertex data
        for (unsigned int j = 0; j < 9; ++j) {
            vertices[i * 9 + j].z = j < 3 ? 1.0f : 2.0f;
            vertices[i * 9 + j].color = color;
        }
        
        //! add overdraw
        vertices[i * 9 + 3].pos = ccpAdd(prevPoint, ccpMult(prevDir, self.overdraw));
        vertices[i * 9 + 3].color.a = 0;
        vertices[i * 9 + 4].pos = prevPoint;
        vertices[i * 9 + 5].pos = ccpAdd(curPoint, ccpMult(dir, self.overdraw));
        vertices[i * 9 + 5].color.a = 0;
        
        vertices[i * 9 + 6].pos = prevPoint;
        vertices[i * 9 + 7].pos = curPoint;
        vertices[i * 9 + 8].pos = ccpAdd(curPoint, ccpMult(dir, self.overdraw));
        vertices[i * 9 + 8].color.a = 0;

            prevPoint = curPoint;
        prevDir = dir;
        angle += anglePerSegment;
    }
    
    glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, sizeof(LineVertex), &vertices[0].pos);
    glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_FLOAT, GL_FALSE, sizeof(LineVertex), &vertices[0].color);
    glDrawArrays(GL_TRIANGLES, 0, numberOfSegments * 9);
    
    free(vertices);
}
#pragma mark - Handling points
- (void)startNewLineFrom:(CGPoint)newPoint withSize:(CGFloat)aSize
{
    self.connectingLine = NO;
    [self addPoint:newPoint withSize:aSize];
}

- (void)endLineAt:(CGPoint)aEndPoint withSize:(CGFloat)aSize
{
    [self addPoint:aEndPoint withSize:aSize];
    self.finishingLine = YES;
}

- (void)addPoint:(CGPoint)newPoint withSize:(CGFloat)size
{
    LinePoint *point = [[LinePoint alloc] init];
    point.pos = newPoint;
    point.width = size;
    [self.points addObject:point];
}



- (NSMutableArray *)calculateSmoothLinePoints
{
    if ([self.points count] > 2) {
        NSMutableArray *smoothedPoints = [NSMutableArray array];
        for (unsigned int i = 2; i < [self.points count]; ++i) {
            LinePoint *prev2 = [self.points objectAtIndex:i - 2];
            LinePoint *prev1 = [self.points objectAtIndex:i - 1];
            LinePoint *cur = [self.points objectAtIndex:i];
            
            CGPoint midPoint1 = ccpMult(ccpAdd(prev1.pos, prev2.pos), 0.5f);
            CGPoint midPoint2 = ccpMult(ccpAdd(cur.pos, prev1.pos), 0.5f);
            
            int segmentDistance = 2;
            float distance = ccpDistance(midPoint1, midPoint2);
            int numberOfSegments = MIN(128, MAX(floorf(distance / segmentDistance), 32));
            
            float t = 0.0f;
            float step = 1.0f / numberOfSegments;
            for (NSUInteger j = 0; j < numberOfSegments; j++) {
                LinePoint *newPoint = [[LinePoint alloc] init];
                newPoint.pos = ccpAdd(ccpAdd(ccpMult(midPoint1, powf(1 - t, 2)), ccpMult(prev1.pos, 2.0f * (1 - t) * t)), ccpMult(midPoint2, t * t));
                newPoint.width = powf(1 - t, 2) * ((prev1.width + prev2.width) * 0.5f) + 2.0f * (1 - t) * t * prev1.width + t * t * ((cur.width + prev1.width) * 0.5f);
                
                [smoothedPoints addObject:newPoint];
                t += step;
            }
            LinePoint *finalPoint = [[LinePoint alloc] init];
            finalPoint.pos = midPoint2;
            finalPoint.width = (cur.width + prev1.width) * 0.5f;
            [smoothedPoints addObject:finalPoint];
        }
        //! we need to leave last 2 points for next draw
        [self.points removeObjectsInRange:NSMakeRange(0, [self.points count] - 2)];
        return smoothedPoints;
    } else {
        return nil;
    }
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
