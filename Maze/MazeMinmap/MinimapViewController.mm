//
//  MinimapViewController.m
//  Maze
//
//  Created by Zilong Wang on 2019/3/10.
//  Copyright © 2019 bcit. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>

#import "MinimapViewController.h"

@interface MinimapViewController ()
{
    Maze * _maze;
    GLKVector3 _location;
    GLKVector3 _rotation;
    CAShapeLayer * _circleLayer;
    
    UIView *containerView;
    
    float oWidth, oHeight, unit;
}

@end

@implementation MinimapViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    UIView * pView = self.parentViewController.view;
    oWidth = pView.bounds.size.width/2;
    oHeight = pView.bounds.size.height/2;
    unit = oWidth/5;
    
    float size =  pView.frame.size.width * 0.8;

    containerView = [[UIView alloc] initWithFrame:CGRectMake(
                                     oWidth - size/2,
                                     oHeight - size/2,
                                     size,
                                     size)];

    [containerView setBackgroundColor:[[UIColor alloc] initWithRed:0.3f green:0.3f blue:0.3f alpha:0.68f] ];
    [self.view addSubview:containerView];
}

- (void) didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController: parent];
    
    [self createMinimap];
}

- (Maze *) mazeGenerate { return _maze; }

- (void) setMazeGenerate:(Maze *)maze
{
    _maze = maze;
}

- (void) setCurrentPosition:(GLKVector3)location rotation:(GLKVector3)rotation {
    _location = location;
    _rotation = rotation;
    [self updatePlayerLocation];
}

- (void) createMinimap
{
    
    
    int numRows = _maze->rows, numCols = _maze->cols;
    int i, j;
    
    for (i=numRows-1; i>=0; i--) {
        for (j=numCols-1; j>=0; j--) {
            if(_maze->GetCell(i, j).southWallPresent){ // up
                [self drawRow: -j col:i];
            }
            if(_maze->GetCell(i, j).northWallPresent){ // down
                [self drawRow: -j col:i-1];
            }
            if(_maze->GetCell(i, j).eastWallPresent){ // left
                [self drawCol: -j col:i];
            }
            if(_maze->GetCell(i, j).westWallPresent){ // right
                [self drawCol: -j+1 col:i];
            }
        }
    }
    
    [self updatePlayerLocation];
}

- (void) updatePlayerLocation
{
    if(oWidth < 1){
        return;
    }
    float x = oWidth + unit/4 + _location.x * unit;
    float y = oHeight + unit/2 - _location.y * unit;
    
    NSLog(@"draw player at %f : %f => %f : %f  ow = %f ", _location.x, _location.y, x, y, oWidth);
    
    CAShapeLayer * circleLayer = [CAShapeLayer layer];
    [circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(x, y, unit/2, unit/2)] CGPath]];
    circleLayer.fillColor = [UIColor redColor].CGColor;
    
    if(_circleLayer == nil){
        _circleLayer = circleLayer;
        [[self.view layer] addSublayer:_circleLayer];
    }
    else
    {
        [[self.view layer] replaceSublayer:_circleLayer with:circleLayer];
        _circleLayer = circleLayer;
    }
}

- (void) drawRow:(int) row col:(int) col
{
    // NSLog(@"draw row at %d : %d => %f : %f ow = %f", row, col, oWidth + row * unit, oHeight + col * unit, oWidth);//
    
    UIView* rowView = [[UIView alloc] initWithFrame:CGRectMake(oWidth + row * unit, oHeight - col * unit, unit, 8)];
    rowView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:rowView];
}

- (void) drawCol:(int) row col:(int) col
{
    UIView* colView = [[UIView alloc] initWithFrame:CGRectMake(oWidth + row * unit, oHeight - col * unit, 8, unit)];
    colView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:colView];
}


@end
