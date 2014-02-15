//
//  SpaceshipScene.m
//  spritecollision
//
//  Created by Joseph Bell on 2/14/14.
//  Copyright (c) 2014 iAchieved.it LLC. All rights reserved.
//

#import "SpaceshipScene.h"
#import "Spaceship.h"
#import "Constants.h"

@interface SpaceshipScene() <SKPhysicsContactDelegate>

@property Spaceship* spaceship;
@property BOOL contentCreated;

@end

@implementation SpaceshipScene

@synthesize spaceship = _spaceship;


-(id)initWithSize:(CGSize)size {
  NSLog(@"initWithSize");
  if (self = [super initWithSize:size]) {
    
    self.physicsWorld.contactDelegate = self;
    self.physicsWorld.gravity         = CGVectorMake(0.0, -0.5);

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
  
  self.spaceship = [[Spaceship alloc]init];
  
  self.spaceship.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
  [self addChild:self.spaceship];
  
  [self addShieldButton];
  [self addRotateLeftButton];
  [self addRotateRightButton];
  [self addFireButton];
  
  /* Make some rocks */
  SKAction *makeRocks = [SKAction sequence: @[
                                              [SKAction performSelector:@selector(addRock) onTarget:self],
                                              [SKAction waitForDuration:1.0 withRange:0.15]
                                              ]];
  [self runAction: [SKAction repeatActionForever:makeRocks]];
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent *)event {
  UITouch* touch = [touches anyObject];
  CGPoint  location = [touch locationInNode:self];
  SKNode*  node = [self nodeAtPoint:location];
  
  if ([node.name isEqualToString:@"shields"]) {
    NSLog(@"raise shields!");
    [self.spaceship raiseShields];
  }
  
  if ([node.name isEqualToString:@"fire"]) {
    NSLog(@"fire");
    [self.spaceship fire];
  }
  
  if ([node.name isEqualToString:@"rotate_left"]) {
    NSLog(@"rotate left");
    [self.spaceship rotateLeft:YES];
  }
  
  if ([node.name isEqualToString:@"rotate_right"]) {
    NSLog(@"rotate right");
    [self.spaceship rotateRight:YES];
  }

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch* touch = [touches anyObject];
  CGPoint  location = [touch locationInNode:self];
  SKNode*  node = [self nodeAtPoint:location];
  
  if ([node.name isEqualToString:@"shields"]) {
    NSLog(@"lower shields!");
    [self.spaceship lowerShields];
  }
  
  if ([node.name isEqualToString:@"rotate_left"]) {
    NSLog(@"stop rotate left");
    [self.spaceship rotateLeft:NO];
  }
  
  if ([node.name isEqualToString:@"rotate_right"]) {
    NSLog(@"stop rotate right");
    [self.spaceship rotateRight:NO];
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

-(void)addFireButton {
  SKShapeNode* button = [[SKShapeNode alloc]init];
  button.position     = CGPointMake(self.spaceship.position.x + 300,
                                    self.spaceship.position.y - 100);
  
  CGMutablePathRef thePath = CGPathCreateMutable();
  CGPathAddArc(thePath, NULL, 0, 0, 20, 0.f, (360* M_PI)/180, NO);
  CGPathCloseSubpath(thePath);
  
  button.name = @"fire";
  button.path = thePath;
  button.fillColor = [SKColor redColor];
  button.strokeColor = [SKColor redColor];
  button.glowWidth = 5;
  
  [self addChild:button];
  
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
  rock.physicsBody.velocity = CGVectorMake(-1.0, 0);
  rock.physicsBody.mass     = 100;
  rock.physicsBody.usesPreciseCollisionDetection = YES;
  rock.physicsBody.categoryBitMask    = rockCategory;
  rock.physicsBody.contactTestBitMask = shipCategory;
  rock.physicsBody.collisionBitMask   = shieldCategory;
  [self addChild:rock];
}



#pragma mark Physics
-(void)didSimulatePhysics {
  [self enumerateChildNodesWithName:@"rock" usingBlock:^(SKNode *node, BOOL *stop) {
    if (node.position.y < 0) {
      [node removeFromParent];
    }
  }];
}

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
    
    if ((secondBody.categoryBitMask & shipCategory) != 0) {
      [self.spaceship takeDamage];
    } else {
      NSLog(@"missle hit rock");
    }
    
    SKNode* rock = firstBody.node;
    
    SKAction* fade = [SKAction fadeOutWithDuration:0.5];
    SKAction* remove = [SKAction removeFromParent];
    SKAction* sequence = [SKAction sequence:@[fade, remove]];
    [rock runAction:sequence];

    SKEmitterNode *ex = [self newExplosion];
    ex.position = contact.bodyB.node.position;
  }
}







-(SKEmitterNode*)newExplosion {
  NSLog(@"explode");


  SKEmitterNode *explosion = [[SKEmitterNode alloc] init];
  [explosion setParticleTexture:[SKTexture textureWithImageNamed:@"spark.png"]];
  [explosion setParticleColor:[UIColor redColor]];
  [explosion setNumParticlesToEmit:20];
  [explosion setParticleBirthRate:450];
  [explosion setParticleLifetime:1];
  [explosion setEmissionAngleRange:360];
  [explosion setParticleSpeed:100];
  [explosion setParticleSpeedRange:50];
  [explosion setXAcceleration:0];
  [explosion setYAcceleration:0];
  [explosion setParticleAlpha:0.8];
  [explosion setParticleAlphaRange:0.2];
  [explosion setParticleAlphaSpeed:-0.5];
  [explosion setParticleScale:0.75];
  [explosion setParticleScaleRange:0.4];
  [explosion setParticleScaleSpeed:-0.5];
  [explosion setParticleRotation:0];
  [explosion setParticleRotationRange:0];
  [explosion setParticleRotationSpeed:0];
  
  [explosion setParticleColorBlendFactor:1];
  [explosion setParticleColorBlendFactorRange:0];
  [explosion setParticleColorBlendFactorSpeed:0];
  [explosion setParticleBlendMode:SKBlendModeAdd];
  
  //add this node to parent node
  [self addChild:explosion];
  
  return explosion;
}

@end
