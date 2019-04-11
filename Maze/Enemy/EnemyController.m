//
//  EnemyController.m
//  Maze
//
//  Created by Zilong Wang on 2019/4/10.
//  Copyright © 2019 bcit. All rights reserved.
//

#import "EnemyController.h"

@interface EnemyController()
{
    NGLModel * _enemy;
    
    float rotAngle_x, rotAngle_y, lastRotation_x, lastRotation_y,
    scale, lastEndScale, posX, lastPosX, posY, lastPosY;
    char isMoving;
    
    BOOL _moveSpeed;
    
    NSMutableArray<Wall *> * _walls;
    CGRect *_wallRects;
    NSMutableArray<Wall *> * onlyWalls;
    int wallCount;
    CGRect rects[100];

    
    float borderTop, borderBottom, borderLeft, borderRight;
    
    CGRect enemyRect;
    GLKVector3 direction;
    
    float sinceLastCollisionTime;
    
}

@end

@implementation EnemyController

- (instancetype) initWithEnemy: (NGLModel * ) enemy walls:(NSMutableArray<Wall *> *)walls{
    
    if ((self = [super init])) {
        _enemy = enemy;
        _walls = walls;
        [self setup];
        
        wallCount=0;
        
        onlyWalls = [[NSMutableArray alloc] init];
        
        for (Wall* wall in _walls) {
            if(wall.position.z >= 0) // not floor
            {
                rects[wallCount++] = CGRectMake(wall.position.x - wall.scale.x/2.0f, -(wall.position.y + wall.scale.y/2.0f), wall.scale.x, wall.scale.y);
                
                [onlyWalls addObject:wall];
                borderTop = MAX(borderTop, wall.position.y);
                borderBottom = MIN(borderBottom, wall.position.y);
                borderLeft = MIN(borderLeft, wall.position.x);
                borderRight = MAX(borderRight, wall.position.x);
                
//                NSLog(@"wall position: (%f ,%f), (%f ,%f)", wall.position.x, wall.position.y, wall.scale.x, wall.scale.y);
//                 NSLog(@"wall rect: (%f ,%f), (%f ,%f)", rects[wallCount-1].origin.x, rects[wallCount-1].origin.y, rects[wallCount-1].size.width, rects[wallCount-1].size.height);
            }
        }
        _wallRects = rects;
//        for (int i = 0; i< wallCount; i++) {
//                NSLog(@"Detected collision wall: [%u] (%f ,%f), (%f ,%f)", i, _wallRects[i].origin.x, _wallRects[i].origin.y, _wallRects[i].size.width, _wallRects[i].size.height);
//        }
    }
    return  self;
}

- (void)setup
{
    isMoving = false;
    lastRotation_x = rotAngle_x = _enemy.rotation.x;
    lastRotation_y = rotAngle_y = _enemy.rotation.y;
    posX = lastPosX = _enemy.position.x;
    posY = lastPosY = _enemy.position.y;
    
    lastEndScale = scale = 1.0f;
    
    _moveSpeed = 0.0002;
    sinceLastCollisionTime = 10;
}

- (void)update:(float)deltaTime
{
    [self autoMoving: deltaTime];
}

// private
- (void)autoMoving:(float)deltaTime
{
    
    if(isMoving){
        
        // detect walls
        BOOL isCollise = false, isOutOfEdge = false;
        float size = 0.25f * _enemy.scale.x / 0.01f, halfSize = size/2.0f;
        Wall * colliseWall;
        // detect edge of maze;
        float pX = _enemy.position.x, pY = _enemy.position.y;
        
        enemyRect = CGRectMake(_enemy.position.x - halfSize, -(_enemy.position.y + halfSize), size, size);
        
        if(pY + halfSize > borderTop || pY - halfSize < borderBottom || pX - halfSize < borderLeft || pX + halfSize > borderRight)
        {
            isOutOfEdge = true;
        }
        else
        {
            for (int i = 0; i< wallCount; i++) {
                if (CGRectIntersectsRect(_wallRects[i], enemyRect)) {
                    //hit
//                    NSLog(@"Detected collision wall: [%u] (%f ,%f), (%f ,%f)", i, _wallRects[i].origin.x, _wallRects[i].origin.y, _wallRects[i].size.width, _wallRects[i].size.height);
//                    NSLog(@"Detected collision enemy: (%f ,%f), (%f ,%f)", enemyRect.origin.x, enemyRect.origin.y, enemyRect.size.width, enemyRect.size.height);
                    isCollise = true;
                    colliseWall = onlyWalls[i];
                }
            }
        }
        
        if(isOutOfEdge){
            // back towards (0, 0)
            float angle = 0;
            if(pX == 0)
            {
                angle = pX > 0 ? 180 : 0; // 180 or 0;
            } else {
             angle = atan(pY/pX) * 180 / M_PI;
            }
            
            // NSLog(@" isOutOfEdge (%f ,%f), (%f ,%f)",pX, pY, angle, angle + 180);
            if(pX > 0)
            {
                angle += 180; // Reverse direction
            }
            _enemy.rotation = GLKVector3Make(0, _enemy.rotation.y,  angle + 90); // default face towards 90
            sinceLastCollisionTime = 0;
        }
        
        sinceLastCollisionTime += deltaTime;
        if(sinceLastCollisionTime > 0.1){
            if(isCollise){
             int randomAngle = arc4random() % 50 - 25; // [-25, 25) degree;
                
                float angle = 0, vx = colliseWall.position.x - pX, vy = colliseWall.position.y - pY; // Reverse direction of wall
                
                
               //  NSLog(@" isCollise (%f ,%f), (%f ,%f)", colliseWall.position.x, colliseWall.position.y, pX, pY);
                
                if(vx == 0)
                {
                    angle = vx > 0 ? 180 : 0; // 180 or 0;
                } else {
                    angle = atan(vy/vx) * 180 / M_PI;
                }
                
               // NSLog(@" isCollise (%f ,%f), (%f ,%f)",vx, vy, angle, angle + 180);
                if(vx > 0)
                {
                    angle += 180; // Reverse direction
                }
                
             _enemy.rotation = GLKVector3Make(0, _enemy.rotation.y,  angle + 90 + randomAngle);
             sinceLastCollisionTime = 0;
            }
        }

        
        direction = GLKVector3Make(cosf((_enemy.rotation.z-90) / 180 * M_PI), sinf((_enemy.rotation.z-90) / 180 * M_PI),  0);
        
        // move forward
        GLKVector3 groundDirection = GLKVector3Normalize(direction);
        
        posX = _enemy.position.x + deltaTime * _moveSpeed * groundDirection.x;
        posY = _enemy.position.y + deltaTime * _moveSpeed * groundDirection.y;
        _enemy.position = GLKVector3Make(posX, posY, _enemy.position.z);
        
        // NSLog(@"enemy.position:(%f ,%f)", _enemy.position.x, _enemy.position.y);
    }
}


// enable / disable auto rotationg - double tap
- (void)switchAutoMoving:(BOOL) moving
{
    isMoving = moving;
    
    lastRotation_x = _enemy.rotation.x;
    lastRotation_y = _enemy.rotation.z;
    
    lastPosX = _enemy.position.x;
    lastPosY = _enemy.position.y;
}

// Rotate cube manually - pan
- (void)rotate:(CGPoint) translation isEnd:(Boolean)isEnd
{
    if(isMoving) return;
    
    rotAngle_x = lastRotation_x + translation.x;
    // rotAngle_y = lastRotation_y + translation.y;
    
    while (rotAngle_x >= 360.0f)
        rotAngle_x -= 360.0f;
    while (rotAngle_y >= 360.0f)
        rotAngle_y -= 360.0f;
    while (rotAngle_x <= -360.0f)
        rotAngle_x += 360.0f;
    while (rotAngle_y <= -360.0f)
        rotAngle_y += 360.0f;
    
    _enemy.rotation = GLKVector3Make(0, rotAngle_y, rotAngle_x); // up down axis is Z
    

    // NSLog(@"%f/%f : %f/%f", translation.x, rotAngle_x, translation.y, rotAngle_y);
    
//    direction = GLKVector3Make(cosf((_enemy.rotation.z-90) / 180 * M_PI), sinf((_enemy.rotation.z-90) / 180 * M_PI),  0);
//    NSLog(@"%f / %f", direction.x, direction.y);
//
    if(isEnd){
        lastRotation_x = _enemy.rotation.z;
        lastRotation_y = _enemy.rotation.y;
    }
}

// Zoom cube - pinch
- (void)zoom:(CGFloat) pinchScale isEnd:(Boolean)isEnd
{
    if(isMoving) return;
    
    // scale = (lastEndScale) * ((pinchScale - 1.0f) / 20.0f + 1.0f) ;
    
    scale = _enemy.scale.x + (pinchScale - 1.0f) / 30.0f;
    
    // orgin scale = 0.01;
    if(scale < 0.002f || scale >= 0.05f)
    {
        return;
    }
    // NSLog(@"%f  => %f", pinchScale, scale);
    
    _enemy.scale = GLKVector3Make(scale, scale, scale);
    
    // NSLog(@"%f, %f, , %f", pinchScale, scale, lastEndScale);
    
    if(isEnd){
        lastEndScale = scale;
    }
}

// Move cube around - two finger pan
- (void)moveAround:(CGPoint) translation isEnd:(Boolean)isEnd
{
    if(isMoving) return;
    
    posX = lastPosX + ( 0.005 * translation.x); // / theView.drawableWidth);
    posY = lastPosY - ( 0.005 * translation.y); // / theView.drawableHeight);
    
    if (posX >= 360.0f)
        posX = 360.0f;
    if (posY >= 360.0f)
        posY -= 360.0f;
    
    float halfSize = 0.1f;
    if(posY + halfSize > borderTop || posY - halfSize < borderBottom || posX - halfSize < borderLeft || posX - halfSize > borderRight)
    {
        // reach edge
        return;
    }
    _enemy.position = GLKVector3Make(posX, posY, _enemy.position.z);
    
    // NSLog(@"%f/%f : %f/%f", translation.x, posX, translation.y, posY);
    
    if(isEnd){
        lastPosX = _enemy.position.x;
        lastPosY = _enemy.position.y;
    }
    // debug
//    enemyRect = CGRectMake(_enemy.position.x - 0.1f, -(_enemy.position.y + 0.1f), 0.2f, 0.2f);
//    NSLog(@"enemy rect: (%f ,%f), (%f ,%f)", enemyRect.origin.x, enemyRect.origin.y, enemyRect.size.width, enemyRect.size.height);
//    NSLog(@"wall rect: [%u] (%f ,%f), (%f ,%f)", wallCount-1, _wallRects[wallCount-1].origin.x, _wallRects[wallCount-1].origin.y, _wallRects[wallCount-1].size.width, _wallRects[wallCount-1].size.height);
//
//    NSLog(@"intersect: [%u]", CGRectIntersectsRect(enemyRect,  _wallRects[wallCount-1]));
}

@end


