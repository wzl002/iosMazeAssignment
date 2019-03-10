//
//  ViewController.m
//  Maze
//
//  Created by Zilong Wang on 2019/2/6.
//  Copyright © 2019 bcit. All rights reserved.
//

#import "ViewController.h"
#import "MazeView.h"
#import "NGLView.h"

@interface ViewController ()
{
    NGLView * _view;
    BOOL isLongPressing;
}
@property (nonatomic , strong) MazeView*   maze;

@end

@implementation ViewController

- (void)viewDidLoad {
    NSLog(@"Start: viewDidLoad");
    
    [super viewDidLoad];
    
    _view = (NGLView *)self.view;
    
    _maze = [[MazeView alloc] init];
    [_maze setup:_view];
    
    NSLog(@"Debug: End: viewDidLoad");
    
    [self addGestureRecognizer];
    isLongPressing = NO;
}

- (void)update
{
    [_maze update:self.timeSinceLastUpdate];
}
/**
 *  渲染场景代码
 */
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // [self.view drawRect:rect];
    if(isLongPressing){
        [_maze moveForward];
    }
    
    [_view preRender];
    
    [_maze draw:rect];
    
    [_view render];
}

#pragma mark Buttons

//- (void) swithDayNight;
//
//- (void) swithFlashLight;
//
//- (void) swithFog;
//
//- (void) setFogIntensity:(float) value;

-(void)switchFogIntensityLabel
{
    // Integer_Label.text = [NSString stringWithFormat:s, value];
}

#pragma mark Gestures

- (void)addGestureRecognizer {
    [self.view setUserInteractionEnabled:YES];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
//    longPress.numberOfTapsRequired = 1;
//    longPress.minimumPressDuration = 0.5; // second
    [self.view addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    UIPanGestureRecognizer *pen = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    pen.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:pen];
    
    //[longPress requireGestureRecognizerToFail:pen];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPinch:)];
    [self.view addGestureRecognizer:pinch];
}


- (IBAction)didSingleTap:(UITapGestureRecognizer *)sender {
    NSLog(@"Tapped");
    // CGPoint location = [sender locationInView:self.view];
}

- (IBAction)didDoubleTap:(UITapGestureRecognizer *)sender {
    NSLog(@"Double Tapped");
    
    [_maze resetCamera];
}

- (IBAction)didPan:(UIPanGestureRecognizer *)sender {
    NSLog(@"Pan ");
    // CGPoint location = [sender locationInView:self.view];
    CGPoint translation = [sender translationInView:self.view];
    // CGPoint velocity = [sender velocityInView:self.view];
    
    [_maze lookAround:translation isEnd:sender.state == UIGestureRecognizerStateEnded];
}

- (IBAction)didLongPress:(UILongPressGestureRecognizer *)sender {
    // NSLog(@"Long Pressing ");
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Long Press start ");
        isLongPressing = true;
    }else if (sender.state == UIGestureRecognizerStateEnded){
        NSLog(@"Long Press end ");
        isLongPressing = false;
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
