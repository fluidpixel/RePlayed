//
//  MyScene.m
//  RePlayed
//
//  Created by Stuart Varrall on 08/04/2014.
//  Copyright (c) 2014 Fluid Pixel Ltd. All rights reserved.
//

#import "MyScene.h"
#import "DataParser.h"
#import "Event.h"

@implementation MyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:60./255. green:149./255. blue:42./255. alpha:1.0];
        
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
	
	SKSpriteNode* pitch = [SKSpriteNode spriteNodeWithImageNamed:@"pitch"];
	pitch.size = CGSizeMake(self.size.width - 40, self.size.height - 120);
	pitch.position = CGPointMake(20, 10);
	pitch.anchorPoint = CGPointZero;
	pitch.zPosition = -1;
	[self addChild:pitch];
	
    return self;
}

-(void)dataReady
{
	
	SKLabelNode* loading = (SKLabelNode*)[self childNodeWithName:@"loading"];
	[loading removeFromParent];
	
	[self addHeaderTeamInfo];
	
	runningTime = 0;
	nextEventIndex = 0;
	
	matchTime = 91;
	SKSpriteNode* gameTimeLabel = [self labelNodeFromString:@"00:00" andSize:30];
	gameTimeLabel.position = CGPointMake(self.size.width/2 - gameTimeLabel.size.width/2, self.size.height - 95);
	gameTimeLabel.name = @"timeLabel";
	[self addChild:gameTimeLabel];
	
	gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
	
}

-(void)updateTimer:(NSTimer *)timer
{
	runningTime ++;
	
	//pause timer for tempTimer time to "wait" for half time
	if (runningTime == 45)
	{
		if([gameTimer isValid])
		{
		[gameTimer invalidate];

		[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updateTimer:) userInfo:nil repeats: NO];
		}
	}
	if (runningTime == 46)
	{
		gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
	}
	[self populateLabelwithTime:runningTime];
	
	Event* nextEvent = [dataParser.eventArray objectAtIndex:nextEventIndex];
		
	if(runningTime == [nextEvent.time intValue])
	{
		if([nextEvent.type isEqualToString:@"goal"])
		{
			if([nextEvent.team.teamRef isEqualToString:dataParser.team1.teamRef])
			{
				SKLabelNode* scoreLabel = (SKLabelNode*)[[[self childNodeWithName:@"teamInfo"] childNodeWithName:@"score1"] childNodeWithName:@"label"];
				int score = [scoreLabel.text intValue];
				score ++;
				scoreLabel.text = [NSString stringWithFormat:@"%i", score];
			}
			else
			{
				SKLabelNode* scoreLabel = (SKLabelNode*)[[[self childNodeWithName:@"teamInfo"] childNodeWithName:@"score2"] childNodeWithName:@"label"];
				int score = [scoreLabel.text intValue];
				score ++;
				scoreLabel.text = [NSString stringWithFormat:@"%i", score];
			}
		}
		
		NSLog(@"%@! %@", nextEvent.type, nextEvent.time);
		if (nextEventIndex < dataParser.eventArray.count-1)
			nextEventIndex++;
	}
	
	if (runningTime == matchTime)
	{
		[self endGame];
	}
}

- (void)endGame
{
	[gameTimer invalidate];
	
	SKSpriteNode* endGame = [self labelNodeFromString:@"End Game" andSize:34];
	endGame.position = CGPointMake(self.size.width/2 - endGame.size.width/2, self.size.height/2);
	[self addChild:endGame];
	
}

- (void)populateLabelwithTime:(int)seconds
{
	
	//SpriteText* spriteText = [[SpriteText alloc] init];
	
	SKSpriteNode* timeLabelNode = (SKSpriteNode*)[self childNodeWithName:@"timeLabel"];
	SKLabelNode * label = (SKLabelNode*)[timeLabelNode childNodeWithName:@"label"];
	
	label.text = [NSString stringWithFormat:@"%02d:00", runningTime];
	
}

-(void)addHeaderTeamInfo
{
	SKSpriteNode *teamInfo = [[SKSpriteNode alloc] initWithColor:[UIColor colorWithWhite:1.0 alpha:0.0]
															size:CGSizeMake(self.size.width, 80)];
	teamInfo.anchorPoint = CGPointMake(0, 1);
	teamInfo.position = CGPointMake(0, self.size.height);
	teamInfo.name = @"teamInfo";
	
	SKSpriteNode *team1 = [self labelNodeFromString:dataParser.team1.name andSize:12];
	team1.position = CGPointMake(self.size.width/2 - team1.size.width - 20, -40);
	[teamInfo addChild:team1];
	
	SKSpriteNode *team2 = [self labelNodeFromString:dataParser.team2.name andSize:12];
	team2.position = CGPointMake(self.size.width/2 + 20, -40);
	[teamInfo addChild:team2];
	
	SKSpriteNode* vs = [self labelNodeFromString:@"VS" andSize:18];
	vs.position = CGPointMake(self.size.width/2 - vs.size.width/2, -60);
	[teamInfo addChild:vs];
	
	SKSpriteNode* score1 = [self labelNodeFromString:@"0" andSize:26];
	score1.name = @"score1";
	score1.position = CGPointMake(self.size.width/2 - score1.size.width - 40, -70);
	[teamInfo addChild:score1];
	
	SKSpriteNode* score2 = [self labelNodeFromString:@"0" andSize:26];
	score2.name = @"score2";
	score2.position = CGPointMake(self.size.width/2 + 40, -70);
	[teamInfo addChild:score2];
	
	[self addChild:teamInfo];
}

-(SKSpriteNode*)labelNodeFromString:(NSString*)string andSize:(int)size
{
	
	SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Heavy"];
	label.fontSize = size;
	label.text = string;
	label.position = CGPointMake(label.frame.size.width / 2, 0);
	label.name = @"label";
	
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
