//
//  SpaceGame.m
//  spritecollision
//
//  Created by Joseph Bell on 2/15/14.
//  Copyright (c) 2014 iAchieved.it LLC. All rights reserved.
//

#import "SpaceGame.h"

@interface SpaceGame()

@property (nonatomic) NSInteger score;

@end

@implementation SpaceGame

@synthesize score = _score;

-(SpaceGame*)init {
  self = [super init];
  if (self) {
  }
  return self;
}

-(void)startGame {
  self.score = 0;
}

-(void)endGame {
  self.score = 0;
}

-(void)scorePoints:(NSInteger)points {
  self.score += points;
}

-(NSInteger)currentScore {
  return self.score;
}

@end
