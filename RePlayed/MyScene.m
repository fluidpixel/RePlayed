//
//  MyScene.m
//  RePlayed
//
//  Created by Stuart Varrall on 08/04/2014.
//  Copyright (c) 2014 Fluid Pixel Ltd. All rights reserved.
//

#import "MyScene.h"
#import "DataParser.h"

@implementation MyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.4 blue:0.2 alpha:1.0];
        
		SKLabelNode *loading = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Heavy"];
		loading.text = @"loading...";
		loading.name = @"loading";
		loading.fontSize = 15;
		loading.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
		[self addChild:loading];
		
		dataParser = [DataParser sharedData];
		
		if (dataParser.complete)
		{
			[self dataReady];
		}
		else
		{
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(dataReady)
														 name:@"finishedParsing"
													   object:nil];
		}
    }
    return self;
}

-(void)dataReady
{
	
	SKLabelNode* loading = (SKLabelNode*)[self childNodeWithName:@"loading"];
	[loading removeFromParent];
	
	SKSpriteNode *team1 = [self labelNodeFromString:dataParser.team1.name];
	
	team1.position = CGPointMake(self.size.width/2 - team1.size.width - 10, self.size.height - 40);
	[self addChild:team1];
	
	SKSpriteNode *team2 = [self labelNodeFromString:dataParser.team2.name];
	
	team2.position = CGPointMake(self.size.width/2 + 10, self.size.height - 40);
	[self addChild:team2];
	
	SKSpriteNode* vs = [self labelNodeFromString:@"VS"];
	vs.position = CGPointMake(self.size.width/2 - vs.size.width/2, self.size.height - 40);
	[self addChild:vs];
}

-(SKSpriteNode*)labelNodeFromString:(NSString*)string
{
	
	SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Heavy"];
	label.fontSize = 12;
	label.text = string;
	label.position = CGPointMake(label.frame.size.width / 2, 0);
	
	SKSpriteNode* sprite = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(label.frame.size.width, label.frame.size.height)];
	[sprite setAnchorPoint:CGPointZero];
	[sprite addChild:label];
	
	return sprite;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
//    for (UITouch *touch in touches) {
//        CGPoint location = [touch locationInNode:self];
//        
//        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
//        
//        sprite.position = location;
//        
//        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
//        
//        [sprite runAction:[SKAction repeatActionForever:action]];
//        
//        [self addChild:sprite];
//    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
