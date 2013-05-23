//
//  RootViewController.m
//  Smooth Drawing
//
//  Created by tony on 13-5-22.
//
//

#import "RootViewController.h"
#import "cocos2d.h"
#import "LineDrawer.h"
#import "Pen.h"
#import "VariableWidthPen.h"
@interface RootViewController ()
@property (nonatomic, strong) UIView *dashboard;
@property (nonatomic, strong) UIButton *oilPenButton;
@property (nonatomic, strong) UIButton *variableWidthSmoothLineButton;
@property (nonatomic, strong) UIButton *clearScreenButton;
@property (nonatomic, strong) LineDrawer *lineDrawer;
@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.dashboard = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.dashboard.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:0.8];
    [self.view addSubview:self.dashboard];
    
    UIColor *buttonColor = [UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:1.0];
    self.oilPenButton = [[UIButton alloc] initWithFrame:CGRectMake(2, 2, 40, 40)];
    [self.oilPenButton addTarget:self action:@selector(oilPenButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.oilPenButton setBackgroundColor:buttonColor];
    [self.oilPenButton setTitle:@"1" forState:UIControlStateNormal];
    [self.dashboard addSubview:self.oilPenButton];
    
    self.variableWidthSmoothLineButton = [[UIButton alloc] initWithFrame:CGRectMake(44, 2, 40, 40)];
    [self.variableWidthSmoothLineButton addTarget:self action:@selector(variableWidthSmoothLineButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.variableWidthSmoothLineButton setBackgroundColor:buttonColor];
    [self.variableWidthSmoothLineButton setTitle:@"2" forState:UIControlStateNormal];
    [self.dashboard addSubview:self.variableWidthSmoothLineButton];
    
    self.clearScreenButton = [[UIButton alloc] initWithFrame:CGRectMake(88, 2, 40, 40)];
    [self.clearScreenButton addTarget:self action:@selector(clearScreenButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.clearScreenButton setBackgroundColor:buttonColor];
    [self.clearScreenButton setTitle:@"X" forState:UIControlStateNormal];
    [self.dashboard addSubview:self.clearScreenButton];
    
    self.view.backgroundColor = [UIColor yellowColor];
    [self setUpCocos2D];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUpCocos2D
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    NSLog(@"screen size:%f",screenSize.height);
    CGRect glViewFrame = CGRectMake(0, 44, 320, screenSize.height-44);
    CCGLView *glView = [CCGLView viewWithFrame:glViewFrame
                                   pixelFormat:kEAGLColorFormatRGB565
                                   depthFormat:0
                            preserveBackbuffer:NO
                                    sharegroup:nil
                                 multiSampling:NO
                               numberOfSamples:0];

    [self.view insertSubview:glView atIndex:0];
    
    CCDirectorIOS* director = (CCDirectorIOS*) [CCDirector sharedDirector];

    [director setView:glView];
    CCScene *scene = [CCScene node];
    self.lineDrawer = [[LineDrawer alloc] initWithDrawingFrame:glViewFrame];
    self.lineDrawer.currentTool = [VariableWidthPen sharedVariableWidthPen];
    [scene addChild:self.lineDrawer];
	[director runWithScene: scene];
    
}

#pragma mark - Dashboard Handler
- (void)oilPenButtonTouched:(id)sender
{
    NSLog(@"oil Pen touched");
    self.lineDrawer.currentTool = [Pen sharedPen];
}

- (void)variableWidthSmoothLineButtonTouched:(id)sender
{
    NSLog(@"variable width touched");
    self.lineDrawer.currentTool = [VariableWidthPen sharedVariableWidthPen];
}

- (void)clearScreenButtonTouched:(id)sender
{
    NSLog(@"clear touched");
    [self.lineDrawer clearScreen];
    
}

@end
