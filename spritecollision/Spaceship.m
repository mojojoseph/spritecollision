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
#import "Logging.h"

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_ERROR;
#endif

@interface Spaceship()

@property BOOL shieldRaised;
@property (nonatomic) NSInteger health;

@end

@implementation Spaceship

@synthesize health = _health;

static const NSInteger initialHealth = 5;

-(Spaceship*)init {
  
  self = [super initWithTexture:[SKTexture textureWithImageNamed:@"rocket.png"]];
  
  if (self) {
    self.position = CGPointMake(100,100);
    self.physicsBody = [self shieldsDownPhysicsBody];
    self.shieldRaised = NO;
    self.health       = initialHealth;

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
    
    SKAction* shieldsUpSound = [SKAction playSoundFileNamed:@"shieldon.caf" waitForCompletion:NO];
    [self addChild:shield];
    [self runAction:[SKAction group:@[shieldsUpSound]]];
    
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
    SKAction* remove       = [SKAction removeFromParent];
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

  //  NSLog(@"Current z-rotation is %f, unit velocity vector is %f, %f", self.zRotation, xDirection, yDirection);
  
  Missile* m = [[Missile alloc]initAtPoint:self.position
                               inDirection:CGPointMake(xDirection, yDirection)];
  
  SKAction* playSound = [SKAction playSoundFileNamed:@"fire.caf" waitForCompletion:NO];
  
  [self.scene runAction:playSound completion:^{
    [self.scene addChild:m];
  }];

  

}

#pragma mark Rotation
-(void)rotateLeft:(BOOL)rotate {
  ENTRY_LOG;
  [self removeActionForKey:@"rotating_right"];

  if (rotate) {
    SKAction* oneRevolution = [SKAction rotateByAngle:M_PI*2 duration: 2.0];
    SKAction* repeat        = [SKAction repeatActionForever:oneRevolution];
    [self runAction:repeat withKey:@"rotating_left"];
  } else {
    [self removeActionForKey:@"rotating_left"];
  }
  
}

-(void)rotateRight:(BOOL)rotate {
  ENTRY_LOG;
  [self removeActionForKey:@"rotating_left"];

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
-(NSInteger)takeDamage {

  
  self.health--;
  
  SKAction* pulseRed =
    [SKAction sequence:@[
                         [SKAction colorizeWithColor:[SKColor redColor] colorBlendFactor:1.0 duration:0.15],
                         [SKAction waitForDuration:0.1],
                         [SKAction colorizeWithColorBlendFactor:0.0 duration:0.15]]];
  
  [self runAction: pulseRed];
  
  NSLog(@"takeDamage, health is now %d", self.health);
  
  return self.health;
  
}

-(NSInteger)currentHealth {
  return self.health;
}

-(void)explode {
  
  ENTRY_LOG;
  
  
  SKAction* fadeAndExplode =
  [SKAction group:@[[SKAction fadeOutWithDuration:0.1],
                    [SKAction playSoundFileNamed:@"explosion.caf" waitForCompletion:NO]]];
  
  SKAction* remove =   [SKAction removeFromParent];
  SKAction* sequence = [SKAction sequence:@[fadeAndExplode, remove]];
  
  [self runAction:sequence];
  
  SKEmitterNode* explosion = [self newExplosion];
  explosion.position = self.position;
  
  // Add this node to parent node
  [self.scene addChild:explosion];
  
  EXIT_LOG;
  
}

-(SKEmitterNode*)newExplosion {
  
  ENTRY_LOG;
    
    
    SKEmitterNode *explosion = [[SKEmitterNode alloc] init];
    [explosion setParticleTexture:[SKTexture textureWithImageNamed:@"spark.png"]];
    [explosion setParticleColor:[UIColor blueColor]];
    [explosion setNumParticlesToEmit:100];
    [explosion setParticleBirthRate:450];
    [explosion setParticleLifetime:2];
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
    
  
    return explosion;
  }



@end
