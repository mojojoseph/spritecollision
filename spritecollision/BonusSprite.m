//
//  BonusSprite.m
//  spritecollision
//
//  Created by Joseph Bell on 2/15/14.
//  Copyright (c) 2014 iAchieved.it LLC. All rights reserved.
//

#import "BonusSprite.h"
#import "Constants.h"

@interface BonusSprite()

@property NSInteger points;

@end

@implementation BonusSprite

@synthesize points = _points;

-(BonusSprite*)initWithImageNamed:(NSString*)imageName andPoints:(NSInteger)points {
  
  self = [super initWithImageNamed:imageName];
  
  if (self) {
    
    self.points = points;
    self.name     = @"bonus";
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.dynamic = NO;
    self.physicsBody.usesPreciseCollisionDetection = YES;
    self.physicsBody.categoryBitMask    = bonusCategory;
    self.physicsBody.contactTestBitMask = 0;
    self.physicsBody.collisionBitMask   = 0;
    
    SKAction* disappearAfter = [SKAction sequence:@[[SKAction waitForDuration:60.0],
                                                 [SKAction playSoundFileNamed:@"idiot.caf" waitForCompletion:NO],
                                                 [SKAction removeFromParent]]];
    
    [self runAction:disappearAfter];
    
  }
  
  return self;
}

-(NSInteger)bonusPoints {
  return self.points;
}

@end
