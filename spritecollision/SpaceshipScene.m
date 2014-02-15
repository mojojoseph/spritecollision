//
//  SpaceshipScene.m
//  spritecollision
//
//  Created by Joseph Bell on 2/14/14.
//  Copyright (c) 2014 iAchieved.it LLC. All rights reserved.
//

#import "SpaceshipScene.h"

@interface SpaceshipScene() <SKPhysicsContactDelegate>
@property BOOL contentCreated;
@property (nonatomic, strong) SKSpriteNode* spaceship;
@property BOOL shieldRaised;
@end

@implementation SpaceshipScene

@synthesize spaceship = _spaceship;

-(id)initWithSize:(CGSize)size {
  NSLog(@"initWithSize");
  if (self = [super initWithSize:size]) {
    
    self.physicsWorld.contactDelegate = self;

  }
  
  
  
  return self;
}


-(void)didMoveToView:(SKView *)view {
  if (!self.contentCreated) {
    [self createSceneContents];
    self.contentCreated = YES;
  }
}

-(void)createSceneContents {
  self.backgroundColor = [SKColor blackColor];
  self.scaleMode       = SKSceneScaleModeAspectFill;
  
  self.spaceship = [self newSpaceship];
  
  self.spaceship.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
  [self addChild:self.spaceship];
  
  [self addShieldButton];
  [self addRotateLeftButton];
  [self addRotateRightButton];
  
  self.shieldRaised = NO;
  
  /* Make some rocks */
  SKAction *makeRocks = [SKAction sequence: @[
                                              [SKAction performSelector:@selector(addRock) onTarget:self],
                                              [SKAction waitForDuration:0.10 withRange:0.15]
                                              ]];
  [self runAction: [SKAction repeatActionForever:makeRocks]];
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent *)event {
  UITouch* touch = [touches anyObject];
  CGPoint  location = [touch locationInNode:self];
  SKNode*  node = [self nodeAtPoint:location];
  if ([node.name isEqualToString:@"shields"]) {
    NSLog(@"raise shields!");
    [self shieldOnSpaceship:YES];
  }
  
  if ([node.name isEqualToString:@"rotate_left"]) {
    NSLog(@"rotate left");
    [self rotateLeft:YES];
  }
  
  if ([node.name isEqualToString:@"rotate_right"]) {
    NSLog(@"rotate right");
    [self rotateRight:YES];
  }

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch* touch = [touches anyObject];
  CGPoint  location = [touch locationInNode:self];
  SKNode*  node = [self nodeAtPoint:location];
  
  if ([node.name isEqualToString:@"shields"]) {
    NSLog(@"lower shields!");
    [self shieldOnSpaceship:NO];
  }
  
  if ([node.name isEqualToString:@"rotate_left"]) {
    NSLog(@"stop rotate left");
    [self rotateLeft:NO];
  }
  
  if ([node.name isEqualToString:@"rotate_right"]) {
    NSLog(@"stop rotate right");
    [self rotateRight:NO];
  }

}


-(void)addShieldButton {
  SKShapeNode* button = [[SKShapeNode alloc]init];
  button.position     = CGPointMake(self.spaceship.position.x - 300,
                                    self.spaceship.position.y - 100);

  
  CGMutablePathRef thePath = CGPathCreateMutable();
  CGPathAddArc(thePath, NULL, 0, 0, 20, 0.f, (360* M_PI)/180, NO);
  CGPathCloseSubpath(thePath);
  
  button.name = @"shields";
  button.path = thePath;
  button.fillColor = [SKColor blueColor];
  button.strokeColor = [SKColor blueColor];
  button.glowWidth = 5;
  
  [self addChild:button];

}

-(void)addRotateLeftButton {
  
  SKShapeNode* button = [[SKShapeNode alloc]init];
  button.position     = CGPointMake(self.spaceship.position.x - 200,
                                    self.spaceship.position.y - 100);
  
  CGMutablePathRef thePath = CGPathCreateMutable();
  CGPathAddArc(thePath, NULL, 0, 0, 20, 0.f, (360* M_PI)/180, NO);
  CGPathCloseSubpath(thePath);
  
  button.name = @"rotate_left";
  button.path = thePath;
  button.fillColor = [SKColor greenColor];
  button.strokeColor = [SKColor greenColor];
  button.glowWidth = 5;
  
  [self addChild:button];
  
}

-(void)addRotateRightButton {
  
  SKShapeNode* button = [[SKShapeNode alloc]init];
  button.position     = CGPointMake(self.spaceship.position.x + 200,
                                    self.spaceship.position.y - 100);
  
  CGMutablePathRef thePath = CGPathCreateMutable();
  CGPathAddArc(thePath, NULL, 0, 0, 20, 0.f, (360* M_PI)/180, NO);
  CGPathCloseSubpath(thePath);
  
  button.name = @"rotate_right";
  button.path = thePath;
  button.fillColor = [SKColor yellowColor];
  button.strokeColor = [SKColor yellowColor];
  button.glowWidth = 5;
  
  [self addChild:button];
  
}


-(void)rotateLeft:(BOOL)rotate {
  
  if (rotate) {
    SKAction* oneRevolution = [SKAction rotateByAngle:M_PI*2 duration: 5.0];
    SKAction* repeat        = [SKAction repeatActionForever:oneRevolution];
    [self.spaceship runAction:repeat withKey:@"rotating_left"];
  } else {
    [self.spaceship removeActionForKey:@"rotating_left"];
  }
  
}

-(void)rotateRight:(BOOL)rotate {
  
  if (rotate) {
    SKAction* oneRevolution = [SKAction rotateByAngle:-M_PI*2 duration: 5.0];
    SKAction* repeat        = [SKAction repeatActionForever:oneRevolution];
    [self.spaceship runAction:repeat withKey:@"rotating_right"];
  } else {
    [self.spaceship removeActionForKey:@"rotating_right"];
  }
  
}

-(void)shieldOnSpaceship:(BOOL)raise {
  if (raise && !self.shieldRaised) {
    SKShapeNode* shield = [[SKShapeNode alloc]init];
    shield.position     = CGPointMake(0, 0);
    
    CGMutablePathRef thePath = CGPathCreateMutable();
    CGPathAddArc(thePath, NULL, 0, 0, 40, 0.f, (360* M_PI)/180, NO);
    CGPathCloseSubpath(thePath);
    
    shield.name = @"shield";
    shield.path = thePath;
    shield.strokeColor = [SKColor yellowColor];
    shield.glowWidth = 10;
    
    [self.spaceship addChild:shield];
    self.spaceship.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:40.f];
    self.spaceship.physicsBody.dynamic = NO;
    self.spaceship.physicsBody.categoryBitMask = shieldCategory;
    self.spaceship.physicsBody.collisionBitMask = 0;//shipCategory | asteroidCategory | planetCategory;
    self.spaceship.physicsBody.contactTestBitMask = 0;
    
    self.shieldRaised = YES;
    return;
  }
  
  if (!raise && self.shieldRaised) {
    NSLog(@"lower shields");
    SKNode* shield = [self.spaceship childNodeWithName:@"shield"];
    
    SKAction* fadeAway = [SKAction fadeOutWithDuration: 1.0];
    SKAction* removePhysicsBody = [SKAction runBlock:^{
      
      self.spaceship.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:40.f];
      self.spaceship.physicsBody.dynamic = NO;
      self.spaceship.physicsBody.categoryBitMask = shipCategory;
      self.spaceship.physicsBody.collisionBitMask = 0;//shipCategory | asteroidCategory | planetCategory;
      self.spaceship.physicsBody.contactTestBitMask = 0;//shipCategory | asteroidCategory | planetCategory;
      
      
      
    }];
    SKAction* remove   = [SKAction removeFromParent];
    SKAction* moveSequence = [SKAction sequence:@[fadeAway, removePhysicsBody, remove]];
    [shield runAction: moveSequence completion:^{
      self.shieldRaised = NO;
    }];

    return;
  }
  
}

/* Rocks */
static inline CGFloat skRandf() {
  return rand() / (CGFloat)RAND_MAX;
}

static inline CGFloat skRand(CGFloat low, CGFloat high) {
  return skRandf() * (high - low) + low;
}

-(void)addRock {
  SKSpriteNode* rock = [[SKSpriteNode alloc] initWithColor:[SKColor brownColor]
                                                      size:CGSizeMake(16,16)];
  rock.position = CGPointMake(skRand(0, self.size.width), self.size.height - 50);
  rock.name     = @"rock";
  rock.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rock.size];
  rock.physicsBody.usesPreciseCollisionDetection = YES;
  rock.physicsBody.categoryBitMask = rockCategory;
  rock.physicsBody.contactTestBitMask = shipCategory;
  rock.physicsBody.collisionBitMask   = shieldCategory;
  [self addChild:rock];
}


-(SKSpriteNode*)newSpaceship {
  //  SKSpriteNode* hull = [[SKSpriteNode alloc]initWithColor:[SKColor grayColor] size:CGSizeMake(64, 32)];
  
  SKSpriteNode* hull = [SKSpriteNode spriteNodeWithImageNamed:@"rocket.png"];
  hull.position = CGPointMake(100,100);
  
  
#if 0
  SKAction* hover = [SKAction sequence:@[
                                         [SKAction waitForDuration:1.0],
                                         [SKAction moveByX:100 y:50.0 duration:1.0],
                                         [SKAction waitForDuration:1.0],
                                         [SKAction moveByX:-100 y:-50 duration:1]]];
  [hull runAction:[SKAction repeatActionForever:hover]];
#endif
  
  SKSpriteNode *light1 = [self newLight];
  light1.position = CGPointMake(-28.0, 6.0);
  [hull addChild:light1];
  
  SKSpriteNode *light2 = [self newLight];
  light2.position = CGPointMake(28.0, 6.0);
  [hull addChild:light2];
 
  hull.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:40.f];
  hull.physicsBody.dynamic = NO;
  hull.physicsBody.categoryBitMask = shipCategory;
  hull.physicsBody.collisionBitMask = 0;//shipCategory | asteroidCategory | planetCategory;
  hull.physicsBody.contactTestBitMask = 0;//shipCategory | asteroidCategory | planetCategory;

  
  return hull;
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

#pragma mark Physics
-(void)didSimulatePhysics {
  [self enumerateChildNodesWithName:@"rock" usingBlock:^(SKNode *node, BOOL *stop) {
    if (node.position.y < 0) {
      [node removeFromParent];
    }
  }];
}

static const uint32_t rockCategory   =  0x1 << 0;
static const uint32_t shipCategory   =  0x1 << 1;
static const uint32_t shieldCategory =  0x1 << 2;

- (void)didBeginContact:(SKPhysicsContact*)contact
{
  SKPhysicsBody* firstBody, *secondBody;
  
  if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
    firstBody = contact.bodyA;
    secondBody = contact.bodyB;
  }
  else {
    firstBody = contact.bodyB;
    secondBody = contact.bodyA;
  }
  
  if ((firstBody.categoryBitMask & rockCategory) != 0) {
    NSLog(@"destroy the rock and color the ship");
    SKAction *pulseRed = [SKAction sequence:@[
                                              [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration:0.15],
                                              [SKAction waitForDuration:0.1],
                                              [SKAction colorizeWithColorBlendFactor:0.0 duration:0.15]]];     [self.spaceship runAction: pulseRed];

  }
}

@end
