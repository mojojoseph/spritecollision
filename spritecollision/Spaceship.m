//
//  Spaceship.m
//  spritecollision
//
//  Created by Joseph Bell on 2/15/14.
//  Copyright (c) 2014 iAchieved.it LLC. All rights reserved.
//

#import "Spaceship.h"
#import "Missile.h"
#import "Constants.h"

@interface Spaceship()

@property BOOL shieldRaised;
@property (nonatomic) NSInteger health;

@end

@implementation Spaceship

@synthesize health = _health;

-(Spaceship*)init {
  
  self = [super initWithTexture:[SKTexture textureWithImageNamed:@"rocket.png"]];
  
  if (self) {
    self.position = CGPointMake(100,100);
    
    SKSpriteNode *light1 = [self newLight];
    light1.position = CGPointMake(-28.0, 6.0);
    [self addChild:light1];
    
    SKSpriteNode *light2 = [self newLight];
    light2.position = CGPointMake(28.0, 6.0);
    [self addChild:light2];
    
    self.physicsBody = [self shieldsDownPhysicsBody];
    self.shieldRaised = NO;
    self.health       = 20;

  }
  
  return self;
}

- (SKSpriteNode *)newLight
{
  SKSpriteNode *light = [[SKSpriteNode alloc] initWithColor:[SKColor yellowColor] size:CGSizeMake(8,8)];
  
  SKAction *blink = [SKAction sequence:@[
                                         [SKAction fadeOutWithDuration:0.25],
                                         [SKAction fadeInWithDuration:0.25]]];
  SKAction *blinkForever = [SKAction repeatActionForever:blink];
  [light runAction: blinkForever];
  
  return light;
}

#pragma mark Shields
-(void)raiseShields {
  [self shieldOnSpaceship:YES];
}

-(void)lowerShields {
  [self shieldOnSpaceship:NO];
}

-(void)shieldOnSpaceship:(BOOL)raise {
  if (raise && !self.shieldRaised) {
    NSLog(@"Raise the shields");
    SKShapeNode* shield = [[SKShapeNode alloc]init];
    shield.position     = CGPointMake(0, 0);
    
    CGMutablePathRef thePath = CGPathCreateMutable();
    CGPathAddArc(thePath, NULL, 0, 0, 40, 0.f, (360* M_PI)/180, NO);
    CGPathCloseSubpath(thePath);
    
    shield.name = @"shield";
    shield.path = thePath;
    shield.strokeColor = [SKColor yellowColor];
    shield.glowWidth = 10;
    
    [self addChild:shield];
    self.physicsBody = [self shieldsUpPhysicsBody];
    self.shieldRaised = YES;
    return;
  }
  
  if (!raise && self.shieldRaised) {
    
    NSLog(@"Lower the shields");
    
    SKNode* shield = [self childNodeWithName:@"shield"];
    
    SKAction* fadeAway = [SKAction fadeOutWithDuration: 1.0];
    SKAction* shieldsDownPhysics = [SKAction runBlock:^{
      self.physicsBody = [self shieldsDownPhysicsBody];
    }];
    SKAction* remove   = [SKAction removeFromParent];
    SKAction* moveSequence = [SKAction sequence:@[fadeAway, shieldsDownPhysics, remove]];
    [shield runAction: moveSequence completion:^{
      self.shieldRaised = NO;
    }];
    
    return;
  }
  
}

#pragma mark Fire
/*
 * 3 lines of code, 3 hours to figure out the right lines
 */
-(void)fire {
  CGFloat xDirection = -sinf(self.zRotation);
  CGFloat yDirection =  cosf(self.zRotation);

  NSLog(@"Current z-rotation is %f, unit velocity vector is %f, %f", self.zRotation, xDirection, yDirection);
  
  Missile* missle = [[Missile alloc]initAtPoint:self.position inDirection:CGPointMake(xDirection, yDirection)];
  [self.scene addChild:missle];
}

#pragma mark Rotation
-(void)rotateLeft:(BOOL)rotate {
  
  if (rotate) {
    SKAction* oneRevolution = [SKAction rotateByAngle:M_PI*2 duration: 2.0];
    SKAction* repeat        = [SKAction repeatActionForever:oneRevolution];
    [self runAction:repeat withKey:@"rotating_left"];
  } else {
    [self removeActionForKey:@"rotating_left"];
  }
  
}

-(void)rotateRight:(BOOL)rotate {
  
  if (rotate) {
    SKAction* oneRevolution = [SKAction rotateByAngle:-M_PI*2 duration: 2.0];
    SKAction* repeat        = [SKAction repeatActionForever:oneRevolution];
    [self runAction:repeat withKey:@"rotating_right"];
  } else {
    [self removeActionForKey:@"rotating_right"];
  }
  
}

#pragma mark Physics
-(SKPhysicsBody*)shieldsDownPhysicsBody {
  SKPhysicsBody* body = [SKPhysicsBody bodyWithCircleOfRadius:40.f];
  body.dynamic = NO;
  body.categoryBitMask    = shipCategory;
  body.collisionBitMask   = 0;
  body.contactTestBitMask = 0;
  return body;
}

-(SKPhysicsBody*)shieldsUpPhysicsBody {
  SKPhysicsBody* body = [SKPhysicsBody bodyWithCircleOfRadius:40.f];
  body.dynamic            = NO;
  body.categoryBitMask    = shieldCategory;
  body.collisionBitMask   = 0;
  body.contactTestBitMask = 0;
  return body;
}

#pragma mark Damage
-(void)takeDamage {

  
  self.health--;
  
  SKAction* pulseRed =
    [SKAction sequence:@[
                         [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration:0.15],
                         [SKAction waitForDuration:0.1],
                         [SKAction colorizeWithColorBlendFactor:0.0 duration:0.15]]];
  
  [self runAction: pulseRed];
  
  NSLog(@"takeDamage, health is now %d", self.health);
  
  if (self.health == 0) {
    [self explode];
  }
  
}

-(void)explode {
  
}

@end
