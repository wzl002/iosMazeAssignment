//
//  MinimapViewController.m
//  Maze
//
//  Created by Zilong Wang on 2019/3/10.
//  Copyright © 2019年 bcit. All rights reserved.
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
    
    float oWidth, oHeight, unit;
}

@end

@implementation MinimapViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    oWidth = self.view.frame.size.width/2;
    oHeight = self.view.frame.size.height/2;
    unit = oWidth/5;
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
}

- (void) createMinimap
{
    
    
    int numRows = _maze->rows, numCols = _maze->cols;
    int i, j;
    for (i=numRows-1; i>=0; i--) {
        for (j=numCols-1; j>=0; j--) {    // top
            printf(" %c ", _maze->GetCell(i, j).southWallPresent ? '-' : ' ');
        }
        printf("\n");
        for (j=numCols-1; j>=0; j--) {    // left/right
            printf("%c", _maze->GetCell(i, j).eastWallPresent ? '|' : ' ');
            printf("%c", ((i+j)< 1) ? '*' : ' ');
            printf("%c", _maze->GetCell(i, j).westWallPresent ? '|' : ' ');
        }
        printf("\n");
        for (j=numCols-1; j>=0; j--) {    // bottom
            printf(" %c ", _maze->GetCell(i, j).northWallPresent ? '-' : ' ');
        }
        printf("\n");
    }
    
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
    if(oWidth == 0){
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
    NSLog(@"draw row at %d : %d => %f : %f ow = %f", row, col, oWidth + row * unit, oHeight + col * unit, oWidth);
    
    UIView* rowView = [[UIView alloc] initWithFrame:CGRectMake(oWidth + row * unit, oHeight - col * unit, unit, 8)];
    rowView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:rowView];
}

- (void) drawCol:(int) row col:(int) col
{
    UIView* colView = [[UIView alloc] initWithFrame:CGRectMake(oWidth + row * unit, oHeight - col * unit, 8, unit)];
    colView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:colView];
}

-(void)drawRect:(CGRect)rect
{
    NSLog(@"draw");
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));  // top left
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMidY(rect));  // mid right
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));  // bottom left
    CGContextClosePath(ctx);
    
    CGContextSetRGBFillColor(ctx, 1, 1, 0, 1);
    CGContextFillPath(ctx);
}




@end
