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
#import "Logging.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_ERROR;
#endif

@interface BonusGenerator()

@property (nonatomic, strong) NSDictionary* bonuses;

@end


@implementation BonusGenerator

@synthesize bonuses = _bonuses;

-(BonusGenerator*)init {
  self = [super init];
  
  if (self) {
    
    self.bonuses = @{@0:  @"cherry.png",
                     @1:  @"banana.png",
                     @2:  @"orange.png"};
    
  }
  
  return self;
  
}

-(void)spawnBonusOnScene:(SKScene*)scene {
  
  ENTRY_LOG;
  
  DDLogVerbose(@"scene frame origin = %f,%f",   scene.frame.origin.x, scene.frame.origin.y);
  DDLogVerbose(@"scene frame size   = %f x %f", scene.frame.size.width, scene.frame.size.height);
  
  /*
   * Randomize bonus location in "top" section of the screen
   */
  int minX = CGRectGetMidX(scene.frame) + 40; // Give us some buffer
  int maxX = CGRectGetMaxX(scene.frame) - 20;
  int minY = CGRectGetMinY(scene.frame) + 20;
  int maxY = CGRectGetMaxY(scene.frame) - 20;
  
  int randX = (arc4random() % (maxX-minX))+minX;
  int randY = (arc4random() % (maxY-minY))+minY;
  
  NSNumber*  r = [NSNumber numberWithInt:arc4random_uniform(2)];
  NSString* bonusFruit = [self.bonuses objectForKey:r];


  BonusSprite* bs = [[BonusSprite alloc] initWithImageNamed:bonusFruit andPoints:100];
  
  bs.position = CGPointMake(randX, randY);
  
  [scene addChild:bs];
  
  return;

  
}


@end
