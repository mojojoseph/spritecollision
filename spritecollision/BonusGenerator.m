//
//  BonusGenerator.m
//  spritecollision
//
//  Created by Joseph Bell on 2/16/14.
//  Copyright (c) 2014 iAchieved.it LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "BonusGenerator.h"
#import "BonusSprite.h"

@implementation BonusGenerator

-(BonusGenerator*)init {
  self = [super init];
  
  if (self) {
    
  }
  
  return self;
  
}

-(void)spawnBonusOnScene:(SKScene*)scene {
  
  NSLog(@"spawn bonus");
  
  NSLog(@"scene frame origin = %f,%f", scene.frame.origin.x, scene.frame.origin.y);
  NSLog(@"scene frame size   = %f x %f", scene.frame.size.width, scene.frame.size.height);
  
  /*
   * Randomize bonus location in "top" section of the screen
   */
  int minX = CGRectGetMidX(scene.frame) + 40; // Give us some buffer
  int maxX = CGRectGetMaxX(scene.frame) - 20;
  int minY = CGRectGetMinY(scene.frame) + 20;
  int maxY = CGRectGetMaxY(scene.frame) - 20;
  
  int randX = (arc4random() % (maxX-minX))+minX;
  int randY = (arc4random() % (maxY-minY))+minY;

  BonusSprite* bs = [[BonusSprite alloc] initWithImageNamed:@"cherry.png" andPoints:100];
  
  bs.position = CGPointMake(randX, randY);
  
  [scene addChild:bs];
  
  return;

  
}


@end
