//
//  MyScene.m
//  spritecollision
//
//  Created by Joseph Bell on 2/14/14.
//  Copyright (c) 2014 iAchieved.it LLC. All rights reserved.
//

#import "MyScene.h"
#import "SpaceshipScene.h"

@implementation MyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
      SKLabelNode* myLabel = [SKLabelNode labelNodeWithFontNamed:@"Optima-ExtraBlack"];
      
      myLabel.name = @"helloNode";
      myLabel.text = @"Death to the Asteroids!";
      myLabel.fontSize = 30;
      myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                    CGRectGetMidY(self.frame));
      [self addChild:myLabel];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

  SKNode *helloNode = [self childNodeWithName:@"helloNode"];
  if (helloNode != nil)
  {
    helloNode.name = nil;
    SKAction* moveUp = [SKAction moveByX: 0 y: 100.0 duration: 0.5];
    SKAction* zoom = [SKAction scaleTo: 2.0 duration: 0.25];
    SKAction* pause = [SKAction waitForDuration: 0.5];
    SKAction* rotateAndFade = [SKAction group:@[[SKAction rotateByAngle:M_PI duration:1.0],
                                                [SKAction fadeOutWithDuration: 1.0]]];
    
    SKAction* remove = [SKAction removeFromParent];
    SKAction *moveSequence = [SKAction sequence:@[moveUp, zoom, pause, rotateAndFade, remove]];
    [helloNode runAction: moveSequence completion:^{
      NSLog(@"frame size = %f,%f", self.size.width, self.size.height);
      SKScene* spaceshipScene = [[SpaceshipScene alloc] initWithSize:self.size];
      SKTransition* doors = [SKTransition doorsOpenHorizontalWithDuration:0.5];
      [self.view presentScene:spaceshipScene transition:doors];
    }];
  }

}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
