//
//  BonusSprite.h
//  spritecollision
//
//  Created by Joseph Bell on 2/15/14.
//  Copyright (c) 2014 iAchieved.it LLC. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface BonusSprite : SKSpriteNode

-(BonusSprite*)initWithImageNamed:(NSString*)imageName andPoints:(NSInteger)points;
-(NSInteger)bonusPoints;

@end
