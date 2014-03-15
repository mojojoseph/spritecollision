//
//  SpaceGame.h
//  spritecollision
//
//  Created by Joseph Bell on 2/15/14.
//  Copyright (c) 2014 iAchieved.it LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpaceGame : NSObject

-(SpaceGame*)init;
-(void)startGame;
-(void)endGame;
-(void)scorePoints:(NSInteger)points;
-(NSInteger)currentScore;

@end
