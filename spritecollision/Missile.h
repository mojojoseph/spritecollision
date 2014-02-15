//
//  Missle.h
//  spritecollision
//
//  Created by Joseph Bell on 2/15/14.
//  Copyright (c) 2014 iAchieved.it LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Missile : SKSpriteNode

-(Missile*)initAtPoint:(CGPoint)point inDirection:(CGPoint)direction;

@end
