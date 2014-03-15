//
//  SpaceshipScene.m
//  spritecollision
//
//  Created by Joseph Bell on 2/14/14.
//  Copyright (c) 2014 iAchieved.it LLC. All rights reserved.
//

#import "SpaceshipScene.h"
#import "SpaceGame.h"
#import "Spaceship.h"
#import "BonusGenerator.h"
#import "BonusSprite.h"
#import "Constants.h"
#import "Logging.h"
#import <AVFoundation/AVFoundation.h>

#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_ERROR;
#endif


@interface SpaceshipScene() <SKPhysicsContactDelegate>

@property AVAudioPlayer* backgroundPlayer;
@property SpaceGame* game;
@property Spaceship* spaceship;
@property BonusGenerator* bonusGenerator;
@property SKLabelNode* healthLabel;
@property SKLabelNode* health;
@property SKLabelNode* scoreLabel;
@property SKLabelNode* score;
@property BOOL contentCreated;

@end

@implementation SpaceshipScene

@synthesize backgroundPlayer = _backgroundPlayer;
@synthesize game      = _game;
@synthesize spaceship = _spaceship;
@synthesize score     = _score;
@synthesize health    = _health;


-(id)initWithSize:(CGSize)size {
  ENTRY_LOG;
  if (self = [super initWithSize:size]) {
    
    self.physicsWorld.contactDelegate = self;
    self.physicsWorld.gravity         = CGVectorMake(0.0, -0.5);
    
    self.game = [[SpaceGame alloc]init];
    self.bonusGenerator = [[BonusGenerator alloc]init];

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
  
  [self addLabels];
  
  [self addShieldButton];
  [self addRotateLeftButton];
  [self addRotateRightButton];
  [self addFireButton];
  
  /* Make some rocks */
  SKAction* makeRocks = [SKAction sequence: @[
                                              [SKAction performSelector:@selector(addRock) onTarget:self],
                                              [SKAction waitForDuration:1.0 withRange:0.15]
                                              ]];
  [self runAction: [SKAction repeatActionForever:makeRocks]];
  
  /* Bonus object generation */
  SKAction* makeBonus = [SKAction sequence:@[
                                             [SKAction performSelector:@selector(addBonus) onTarget:self],
                                             [SKAction waitForDuration:10 withRange:5]
                                             ]];
  [self runAction:[SKAction repeatActionForever:makeBonus]];
  
  NSError* error;
  NSURL* backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"SureShot" withExtension:@"caf"];
  self.backgroundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
  self.backgroundPlayer.numberOfLoops = -1;
  [self.backgroundPlayer prepareToPlay];
  [self.backgroundPlayer play];
  
  // Start the game
  [self.game startGame];
  
}

-(void)addLabels {
  self.scoreLabel = [[SKLabelNode alloc]initWithFontNamed:@"Arial"];
  self.scoreLabel.text = @"SCORE";
  self.scoreLabel.fontSize = 18;
  self.scoreLabel.fontColor = [SKColor redColor];
  self.scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame)-200, CGRectGetMidY(self.frame)-200);
  [self addChild:self.scoreLabel];
  
  self.score = [[SKLabelNode alloc]initWithFontNamed:@"Arial"];
  self.score.text = @"000000";
  self.score.fontSize = 18;
  self.score.fontColor = [SKColor yellowColor];
  self.score.position = CGPointMake(CGRectGetMidX(self.frame)-200, CGRectGetMidY(self.frame)-240);
  [self addChild:self.score];

  self.healthLabel = [[SKLabelNode alloc]initWithFontNamed:@"Arial"];
  self.healthLabel.text = @"HEALTH";
  self.healthLabel.fontSize = 18;
  self.healthLabel.fontColor = [SKColor redColor];
  self.healthLabel.position = CGPointMake(CGRectGetMidX(self.frame)+200, CGRectGetMidY(self.frame)-200);
  [self addChild:self.healthLabel];

  self.health = [[SKLabelNode alloc]initWithFontNamed:@"Arial"];
  self.health.text = @"05";
  self.health.fontSize = 18;
  self.health.fontColor = [SKColor yellowColor];
  self.health.position = CGPointMake(CGRectGetMidX(self.frame)+200, CGRectGetMidY(self.frame)-240);
  [self addChild:self.health];
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent *)event {
  //  UITouch* touch = [touches anyObject];
  for (UITouch* touch in touches) {
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

}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  ENTRY_LOG;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  //  UITouch* touch    = [touches anyObject];
  
  for (UITouch* touch in touches) {

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
  button.fillColor = [SKColor yellowColor];
  button.strokeColor = [SKColor yellowColor];
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
  button.fillColor = [SKColor blueColor];
  button.strokeColor = [SKColor blueColor];
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
#pragma mark Asteroids
static inline CGFloat skRandf() {
  return rand() / (CGFloat)RAND_MAX;
}

static inline CGFloat skRand(CGFloat low, CGFloat high) {
  return skRandf() * (high - low) + low;
}

-(void)addRock {
  //  SKSpriteNode* rock = [[SKSpriteNode alloc] initWithColor:[SKColor brownColor]
  //                                                      size:CGSizeMake(16,16)];
  
  
  SKSpriteNode* rock = [[SKSpriteNode alloc]initWithImageNamed:@"asteroid.png"];
  rock.position      = CGPointMake(skRand(0, self.size.width), self.size.height - 50);
  rock.name          = @"rock";
  rock.physicsBody   = [SKPhysicsBody bodyWithRectangleOfSize:rock.size];
  rock.physicsBody.velocity                      = CGVectorMake(-1.0, 0);
  rock.physicsBody.mass                          = 100;
  rock.physicsBody.usesPreciseCollisionDetection = YES;
  rock.physicsBody.categoryBitMask               = rockCategory;
  rock.physicsBody.contactTestBitMask            = shipCategory;
  rock.physicsBody.collisionBitMask              = shieldCategory;
  
  
  [self addChild:rock];
}

#pragma mark Bonus
-(void)addBonus {
  [self.bonusGenerator spawnBonusOnScene:self];
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

  uint32_t collision = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask);
  
  if (collision == (rockCategory | shipCategory)) {
    NSLog(@"rock and ship");
    NSInteger healthLeft = [self.spaceship takeDamage];
    
    SKNode* rock;
    if (contact.bodyA.categoryBitMask == rockCategory) {
      rock = contact.bodyA.node;
    } else {
      rock = contact.bodyB.node;
    }
    
    SKAction* fadeAndExplode =
      [SKAction group:@[[SKAction fadeOutWithDuration:0.1],
                        [SKAction playSoundFileNamed:@"explosion.caf" waitForCompletion:NO]]];
    
    SKAction* remove =   [SKAction removeFromParent];
    SKAction* sequence = [SKAction sequence:@[fadeAndExplode, remove]];
    [rock runAction:sequence];
    
    SKEmitterNode *ex = [self newExplosion];
    ex.position = contact.bodyB.node.position;
    
    if (healthLeft == 0) {
      [self gameOver];

    }
    
  }
  
  if (collision == (rockCategory | missileCategory)) {
    NSLog(@"rock and missle");
    
    SKNode* rock;
    if (contact.bodyA.categoryBitMask == rockCategory) {
      rock = contact.bodyA.node;
    } else {
      rock = contact.bodyB.node;
    }
    
    SKAction* fadeAndExplode = [SKAction group:@[
                                                 [SKAction fadeOutWithDuration:0.1],
                                                 [SKAction playSoundFileNamed:@"explosion.caf" waitForCompletion:NO]]];
    SKAction* remove =   [SKAction removeFromParent];
    SKAction* sequence = [SKAction sequence:@[fadeAndExplode, remove]];
    [rock runAction:sequence];
    
    SKEmitterNode *ex = [self newExplosion];
    ex.position = contact.bodyB.node.position;

    
    [self.game scorePoints:10];
  }
  
  if (collision == (missileCategory | bonusCategory)) {
    NSLog(@"missle and bonus");
    
    BonusSprite* bonus;
    if (contact.bodyA.categoryBitMask == bonusCategory) {
      bonus = (BonusSprite*)contact.bodyA.node;
    } else {
      bonus = (BonusSprite*)contact.bodyB.node;
    }
    NSInteger pointsScored = [bonus bonusPoints];
    [self.game scorePoints:pointsScored];
    
    
    SKAction* fadeAndExplode = [SKAction group:@[
                                                 [SKAction fadeOutWithDuration:0.1],
                                                 [SKAction playSoundFileNamed:@"oooh.caf" waitForCompletion:NO]]];
    SKAction* remove =   [SKAction removeFromParent];
    SKAction* sequence = [SKAction sequence:@[fadeAndExplode, remove]];
    [bonus runAction:sequence];
 
  }
  
}

-(void)update:(NSTimeInterval)currentTime {
  /* Update the score */
  [self updateScore];
  
  /* Update the health */
  [self updateHealth];
}

-(void)updateScore {
  NSInteger currentScore = [self.game currentScore];
  NSString* score = [NSString stringWithFormat:@"%06d", currentScore];
  self.score.text = score;
}

-(void)updateHealth {
  NSInteger currentHealth = [self.spaceship currentHealth];
  NSString* health = [NSString stringWithFormat:@"%02d", currentHealth];
  self.health.text = health;
}

-(void)gameOver {

  [self.spaceship explode];
  
  SKSpriteNode* gameOver = [[SKSpriteNode alloc]initWithTexture:[SKTexture textureWithImageNamed:@"gameover.png"]];
  gameOver.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
  
  SKAction* gameOverSound = [SKAction playSoundFileNamed:@"gameover.caf" waitForCompletion:NO];
  [self.scene runAction:[SKAction sequence:@[[SKAction waitForDuration:2.0],
                                             gameOverSound,
                                             [SKAction runBlock:^{
    [self.scene addChild:gameOver];
  }]]]];
  
  //  [self.backgroundPlayer stop];
  
  [self.game endGame];
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
