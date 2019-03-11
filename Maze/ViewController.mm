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

#include "maze.hpp"


@interface ViewController ()
{
    NGLView * _view;
    BOOL isLongPressing;
    BOOL isMapShowing;
    MinimapViewController * _minimapViewController;
    
    __weak IBOutlet UILabel *_fogIntensityText;
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
    
    [self addGestureRecognizer];
    isLongPressing = NO;
    isMapShowing = NO;
    
    _fogIntensityText.text = @"0.5";
    
    _minimapViewController = [[MinimapViewController alloc] init];
    
    NSLog(@"Debug: End: viewDidLoad");
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

- (IBAction)swicthDayNight:(UISwitch *)sender {
    [_maze switchDayNight];
}

- (IBAction)switchFlashLight:(UISwitch *)sender {
    [_maze switchFlashLight];
}

- (IBAction)switchFog:(UISwitch *)sender {
    [_maze switchFog];
}

- (IBAction)setFogIntensity:(UISlider *)sender {
    [_maze setFogIntensity:sender.value];
    _fogIntensityText.text = [NSString stringWithFormat:@"%.1f", sender.value];
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
    
    UITapGestureRecognizer *twoFingersDoubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTwoFingersDoubleTap:)];
    twoFingersDoubleTap.numberOfTapsRequired = 2;
    twoFingersDoubleTap.numberOfTouchesRequired = 2;
    [self.view addGestureRecognizer:twoFingersDoubleTap];
    
    [doubleTap requireGestureRecognizerToFail:twoFingersDoubleTap];
    
    UIPanGestureRecognizer *pen = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    pen.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:pen];
    
    //[longPress requireGestureRecognizerToFail:pen];
//
//    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPinch:)];
//    [self.view addGestureRecognizer:pinch];
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

- (IBAction)didTwoFingersDoubleTap:(UITapGestureRecognizer *)sender {
    Maze* _mazeGenerate =_maze.mazeGenerate;
    
    if(!isMapShowing){

        _minimapViewController.mazeGenerate = _mazeGenerate;
        [_minimapViewController setCurrentPosition:_maze.camera.position rotation:_maze.camera.rotation];
        [self loadScene:_minimapViewController];
        
        isMapShowing = YES;
    } else {
         [self unloadScene:_minimapViewController];
        isMapShowing = NO;
    }
    
}

#pragma mark load screen


- (void)loadScene:(UIViewController *)viewController {
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    
    viewController.view.frame = self.view.bounds;
    
    // load Scene Animation
    [self loadSceneAnimation:viewController];
    
}

// Animation: load Scene
- (void) loadSceneAnimation :(UIViewController *)viewController {
    // From
    viewController.view.alpha = 0;
    
    // offscreen coordinate (above the top)
    // self.view.bounds.origin.x -> height
    viewController.view.frame = CGRectMake(CGRectGetMinX(self.view.bounds),
                                           -CGRectGetHeight(self.view.bounds),
                                           CGRectGetWidth(self.view.bounds),
                                           CGRectGetHeight(self.view.bounds));
    // To
    [UIView animateWithDuration:0.5 animations:^{
        viewController.view.alpha = 1;
        viewController.view.frame = self.view.bounds;
    }];
}

- (void)unloadScene:(UIViewController *)viewController {
    [viewController didMoveToParentViewController:nil];
    [viewController removeFromParentViewController];
    
    // [viewController.view removeFromSuperview];
    
    // Animation
    [UIView animateWithDuration:.5 animations:^{
        viewController.view.alpha = 0;
        
        // Move offscreen
        viewController.view.frame = CGRectMake(CGRectGetMinX(self.view.bounds),
                                               -CGRectGetHeight(self.view.bounds),
                                               CGRectGetWidth(self.view.bounds),
                                               CGRectGetHeight(self.view.bounds));
        
    } completion:^(BOOL finish) {
        [viewController.view removeFromSuperview];
    }];
}

// hide iphone status bar
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
