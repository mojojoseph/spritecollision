//
//  BonusGenerator.h
//  spritecollision
//
//  Created by Joseph Bell on 2/16/14.
//  Copyright (c) 2014 iAchieved.it LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BonusSprite;
@class SKScene;

@interface BonusGenerator : NSObject

-(BonusGenerator*)init;
-(void)spawnBonusOnScene:(SKScene*)scene;

@end
