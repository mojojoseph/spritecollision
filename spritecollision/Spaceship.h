//
//  Spaceship.h
//  spritecollision
//
//  Created by Joseph Bell on 2/15/14.
//  Copyright (c) 2014 iAchieved.it LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Spaceship : SKSpriteNode

-(Spaceship*)init;
-(void)raiseShields;
-(void)lowerShields;
-(void)rotateLeft:(BOOL)rotate;
-(void)rotateRight:(BOOL)rotate;
-(void)fire;

-(void)takeDamage;
-(void)explode;

@end
