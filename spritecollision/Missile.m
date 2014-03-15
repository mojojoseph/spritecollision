//
//  Missle.m
//  spritecollision
//
//  Created by Joseph Bell on 2/15/14.
//  Copyright (c) 2014 iAchieved.it LLC. All rights reserved.
//

#import "Missile.h"
#import "Constants.h"

@implementation Missile

-(Missile*)initAtPoint:(CGPoint)point inDirection:(CGPoint)direction {
  self = [super initWithColor:[SKColor redColor] size:CGSizeMake(8, 8)];
  if (self) {
    self.position = point;
    self.name     = @"missle";
    self.physicsBody                               = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.velocity                      = CGVectorMake(1000.00*direction.x, 1000*direction.y);
    self.physicsBody.mass                          = 0;
    self.physicsBody.usesPreciseCollisionDetection = YES;
    self.physicsBody.categoryBitMask    = missileCategory;
    self.physicsBody.contactTestBitMask = rockCategory | bonusCategory;    // Contact with a rock
                                                                           // or bonus object
    self.physicsBody.collisionBitMask   = 0;
  }
  return self;
}

@end
