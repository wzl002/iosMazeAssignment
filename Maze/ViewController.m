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
    [_view preRender];
    
    [_maze draw:rect];
    
    [_view render];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
