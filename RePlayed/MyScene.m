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
#import "GameEvent.h"


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
		
		updateRate = 0.02;
		
		data = [DataParser sharedData];
		
		if (data.complete)
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
	pitch.size = CGSizeMake(self.size.width - 0, self.size.height - 120);
	pitch.position = CGPointMake(0, 10);
	pitch.anchorPoint = CGPointZero;
	pitch.zPosition = -1;
	[self addChild:pitch];
	
	ball = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
	ball.position = [self pointOnPitchWithX:50.0 andY:50.0];
	ball.zPosition = 1;
	
	[self addChild:ball];
	
	actionLayer = [[SKNode alloc] init];
	actionLayer.name = @"actionLayer";
	[self addChild:actionLayer];
	
    return self;
}

-(void)dataReady
{
	
	SKLabelNode* loading = (SKLabelNode*)[self childNodeWithName:@"loading"];
	[loading removeFromParent];
	
	[self addHeaderTeamInfo];
	
	runningTime = 0;
	nextEventIndex = 0;
	nextGameEventIndex = 0;
	
	matchTime = 91*60;
	SKSpriteNode* gameTimeLabel = [self labelNodeFromString:@"00:00" andSize:30];
	gameTimeLabel.position = CGPointMake(self.size.width/2 - gameTimeLabel.size.width/2, self.size.height - 95);
	gameTimeLabel.name = @"timeLabel";
	[self addChild:gameTimeLabel];
	
	[self showEventDetailLabelWithString:@"KICK OFF"];
	
	[self pauseGameFor:updateRate * 200];
	
}

-(void)updateTimer:(NSTimer *)timer
{
	runningTime ++;
	
	//pause timer for tempTimer time to "wait" for half time
	if (runningTime == (45 * 60))
	{
		[self pauseGameFor:updateRate * 200];
		
		//reset action grid
		[actionLayer removeAllChildren];
		
			[self showEventDetailLabelWithString:@"HALF TIME"];
	}
	
	[self populateLabelwithTime:runningTime];
	
	if(!gameEnded)
	{
		//[self processBasicEvents];
		[self processDetailedEvents];
	}
	
	if (runningTime >= matchTime)
	{
		[self endGame];
	}
}

-(void)processDetailedEvents
{
	GameEvent* nextGameEvent = [data.gameEventArray objectAtIndex:nextGameEventIndex];
	
	while(nextGameEvent.min == 0 && nextGameEvent.sec == 0)
	{
		if(nextGameEventIndex < data.gameEventArray.count-1)
		{
			nextGameEventIndex++;
			nextGameEvent = [data.gameEventArray objectAtIndex:nextGameEventIndex];
		}
		else
		{
			break;
		}
	}
	
	int seconds = runningTime;
	
	int minutes = seconds / 60;
    seconds -= minutes * 60;
    seconds = floorf(seconds);
	
	while(minutes == nextGameEvent.min && seconds == nextGameEvent.sec)
	{
		//NSLog(@"event: %02i at %02i:%02i %.01f,%.01f", nextGameEvent.eventType, nextGameEvent.min, nextGameEvent.sec, nextGameEvent.posX, nextGameEvent.posY);
		UIColor* color;
		CGPoint point;
		if ([nextGameEvent.teamId isEqualToString:data.team1.teamId])
		{
			color = [UIColor redColor];
			if(nextGameEvent.periodId == 1)
				point = [self pointOnPitchWithX:nextGameEvent.posY andY:nextGameEvent.posX];
			else
				point = [self pointOnPitchWithX:100-nextGameEvent.posY andY:100-nextGameEvent.posX];
		}
		else
		{
			color = [UIColor blueColor];
			if(nextGameEvent.periodId == 1)
				point = [self pointOnPitchWithX:100-nextGameEvent.posY andY:100-nextGameEvent.posX];
			else
				point = [self pointOnPitchWithX:nextGameEvent.posY andY:nextGameEvent.posX];
		}
	
		//ignore formations, start/stop delays from action points  ball out = 5
		if (nextGameEvent.eventType != 17 && nextGameEvent.eventType != 18 && nextGameEvent.eventType != 19 && nextGameEvent.eventType != 24 && nextGameEvent.eventType != 34 && nextGameEvent.eventType != 32 && nextGameEvent.eventType != 43 && nextGameEvent.eventType != 27 && nextGameEvent.eventType != 28 && nextGameEvent.eventType != 30 && nextGameEvent.eventType != 40 && nextGameEvent.eventType != 5)
		{
			
			[self moveBallWithEvent:nextGameEvent andPosition:point];

			//goal 16, miss 13, saved attempt 15, save 10
			if (nextGameEvent.eventType == 16 || nextGameEvent.eventType == 13 || nextGameEvent.eventType == 15) // || nextGameEvent.eventType == 10)
			{
				if ([nextGameEvent.teamId isEqualToString:data.team1.teamId])
				{
					if(nextGameEvent.periodId == 1)
						[self addActionPointatPoint:[self pointOnPitchWithX:nextGameEvent.posY andY:nextGameEvent.posX] withColor:color andSize:CGSizeMake(10,10)];
					else
						[self addActionPointatPoint:[self pointOnPitchWithX:100-nextGameEvent.posY andY:100-nextGameEvent.posX] withColor:color andSize:CGSizeMake(10,10)];
				}
				else
				{
					if(nextGameEvent.periodId == 1)
						[self addActionPointatPoint:[self pointOnPitchWithX:100-nextGameEvent.posY andY:100-nextGameEvent.posX] withColor:color andSize:CGSizeMake(10,10)];
					else
						[self addActionPointatPoint:[self pointOnPitchWithX:nextGameEvent.posY andY:nextGameEvent.posX] withColor:color andSize:CGSizeMake(10,10)];
				}
				
				if (nextGameEvent.eventType == 16)//goal
				{
					[self scoredGoal:nextGameEvent];
				}
				else if (nextGameEvent.eventType == 13)//miss
				{
					[self missedChance:nextGameEvent];
				}
				else if (nextGameEvent.eventType == 10)//save
				{
					//[self saveEvent:nextGameEvent];
				}
				
			}
			else
			{
				[self addActionPointatPoint:point withColor:color andSize:CGSizeMake(4,4)];
			}
		}
		
		//Game restarts so reset ball
		if(nextGameEvent.eventType == 32 || nextGameEvent.eventType == 30)
		{
			[ball runAction:[SKAction moveTo:[self pointOnPitchWithX:50.0 andY:50.0] duration:updateRate * 10]];
		}
		
		//check if there's any more events at this time
		if (nextGameEventIndex < data.gameEventArray.count-1)
		{
			nextGameEventIndex++;
			nextGameEvent = [data.gameEventArray objectAtIndex:nextGameEventIndex];
		}
		else
		{
			nextGameEvent = nil;
			break;
		}
	}
}

-(CGPoint)pointOnPitchWithX:(float)x andY:(float)y
{
	float pitchWidth = self.size.width * 0.82;
	float pitchHeight = self.size.height * 0.75;
	float pitchXOffset = 28;
	float pitchYOffset = 20;
	
	return CGPointMake(x * pitchWidth * 0.01 + pitchXOffset, y * pitchHeight * 0.01 + pitchYOffset);
}

-(void)addActionPointatPoint:(CGPoint)point withColor:(UIColor*)color andSize:(CGSize)size
{
	SKSpriteNode* actionPoint = [SKSpriteNode spriteNodeWithColor:color size:size];
	actionPoint.position = point;
	
	NSArray* actionArray = [actionLayer children];
	if(actionArray.count > 15)
	{
	   [[actionArray objectAtIndex:0] removeFromParent];
	}
	
	[actionLayer addChild:actionPoint];
}

-(void)moveBallWithEvent:(GameEvent*)event andPosition:(CGPoint)point
{
	
	if (event.eventType == 16 || event.eventType == 13) //goal 16 or miss 13
	{
		CGPoint goalPoint;
		
		for (EventQualifier* qualifier in event.qualifiers)
		{
			if (qualifier.qualifierId == 102)
			{
				float y = 0.0;
				if(event.posX > 50)
				{
					y = 100.0;
				}
				
				if ([event.teamId isEqualToString:data.team1.teamId])
				{
					if (event.periodId == 1)
						goalPoint = [self pointOnPitchWithX:[qualifier.value floatValue] andY:y];
					else
						goalPoint = [self pointOnPitchWithX:[qualifier.value floatValue] andY:100-y];
				}
				else
				{
					if (event.periodId == 1)
						goalPoint = [self pointOnPitchWithX:[qualifier.value floatValue] andY:100-y];
					else
						goalPoint = [self pointOnPitchWithX:[qualifier.value floatValue] andY:y];
				}
				
				break;
			}
		}
		
		if (event.eventType == 16)
		{
			[ball runAction:[SKAction sequence:@[
												 [SKAction moveTo:point duration:updateRate*10],
												 [SKAction moveTo:goalPoint duration:updateRate*10],[SKAction waitForDuration:updateRate*180],
												 [SKAction moveTo:[self pointOnPitchWithX:50.0 andY:50.0] duration:0.0]]]];
		}
		else //miss
		{
			[ball runAction:[SKAction sequence:@[
												 [SKAction moveTo:point duration:updateRate*10],
												 [SKAction moveTo:goalPoint duration:updateRate*10]]]];
		}
	}
//	else if(event.eventType == 10) //saved
//	{
//
//		float x = 0.0;
//		float y = 0.0;
//		
//		for (EventQualifier* qualifier in event.qualifiers)
//		{
//			
//			
//			if (qualifier.qualifierId == 146) //save x
//			{
//				x = [qualifier.value floatValue];
//			}
//			else if (qualifier.qualifierId == 147) //save y
//			{
//				y = [qualifier.value floatValue];
//			}
//			
//		}
//		
//		[ball runAction:[SKAction sequence:@[
//											 [SKAction moveTo:point duration:0.1],
//											 [SKAction moveTo:[self createPointonPitchWithX:y andY:x] duration:0.1]]]];
//	}
	else
	{
		BOOL inAir = FALSE;
		for (EventQualifier* qualifier in event.qualifiers)
		{
			if(qualifier.qualifierId == 155)//in the air
			{
				[ball runAction:
				 [SKAction group:@[[SKAction sequence:@[[SKAction scaleTo:2.0 duration:updateRate*10], [SKAction scaleTo:1.0 duration:updateRate*10]]], [SKAction moveTo:point duration:updateRate*20]]]];
				inAir = TRUE;
				break;
				
			}
		}
		if (!inAir)
		{
			[ball runAction:[SKAction moveTo:point duration:updateRate*10]];
		}
	}
	
}

-(void)scoredGoal:(GameEvent*)nextEvent
{
	[self pauseGameFor:updateRate * 200];
	
	if([nextEvent.teamId isEqualToString:data.team1.teamId])
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
	
	NSString* eventDetails;
	
	for(Player* player in data.playerList)
	{
		NSString* playerId = [NSString stringWithFormat:@"p%@", nextEvent.playerId];
		
		if([playerId isEqualToString:player.playerRef])
		{
			eventDetails = [NSString stringWithFormat:@"%@ %@'s %@", player.firstName, player.lastName, @"Goal"];
			break;
		}
	}
	
	[self showEventDetailLabelWithString:eventDetails];
	
}

-(void)missedChance:(GameEvent*)nextEvent
{
	[self pauseGameFor:updateRate * 100];
	
	NSMutableString* eventDetails;
	
	for(Player* player in data.playerList)
	{
		NSString* playerId = [NSString stringWithFormat:@"p%@", nextEvent.playerId];
		
		if([playerId isEqualToString:player.playerRef])
		{
			eventDetails = [NSMutableString stringWithFormat:@"%@ %@ %@", player.firstName, player.lastName, @"Missed"];
			break;
		}
	}
	
	for(EventQualifier* qualifier in nextEvent.qualifiers)
	{
		if (qualifier.qualifierId == 15)
		{
			[eventDetails appendString:@" with Head"];
		}
	}
	
	[self showEventDetailLabelWithString:eventDetails];
	
}

-(void)saveEvent:(GameEvent*)nextEvent
{
	[self pauseGameFor:updateRate * 100];
	
	NSMutableString* eventDetails;
	
	for(Player* player in data.playerList)
	{
		NSString* playerId = [NSString stringWithFormat:@"p%@", nextEvent.playerId];
		
		if([playerId isEqualToString:player.playerRef])
		{
			eventDetails = [NSMutableString stringWithFormat:@"%@ %@ %@", player.firstName, player.lastName, @"Shot Saved"];
			break;
		}
	}
	
	[self showEventDetailLabelWithString:eventDetails];
	
}

-(void)showEventDetailLabelWithString:(NSString*)string
{
	SKSpriteNode* details = [self labelNodeFromString:string andSize:14];
	details.position = CGPointMake(self.size.width/2 - details.size.width/2, self.size.height/2);
	details.name = @"eventLabel";
	[self addChild:details];
}
#pragma mark Timer Stuff
-(void)pauseGameFor:(float)seconds
{
	//NSLog(@"timer paused");
	[gameTimer invalidate];
	
	//pause for x seconds before restarting timer
	[NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(startTimer:) userInfo:nil repeats: NO];
}

-(void)startTimer:(NSTimer*)timer
{
	[actionLayer removeAllChildren];
	
	if(!gameEnded)
	{
		//NSLog(@"timer started");
		gameTimer = [NSTimer scheduledTimerWithTimeInterval:updateRate target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
		
		[[self childNodeWithName:@"eventLabel"] removeFromParent];
	}
	
}

- (void)endGame
{
	gameEnded = TRUE;
	[gameTimer invalidate];
	[[self childNodeWithName:@"eventLabel"] removeFromParent];
	[actionLayer removeAllChildren];
	
	[self showEventDetailLabelWithString:@"END GAME"];
	
}

- (void)populateLabelwithTime:(int)currentTime
{
	
	//SpriteText* spriteText = [[SpriteText alloc] init];
	
	SKSpriteNode* timeLabelNode = (SKSpriteNode*)[self childNodeWithName:@"timeLabel"];
	SKLabelNode * label = (SKLabelNode*)[timeLabelNode childNodeWithName:@"label"];
	
	int seconds = currentTime;
	int minutes = seconds / 60;
    seconds -= minutes * 60;
    seconds = floorf(seconds);
	
	label.text = [NSString stringWithFormat:@"%02i:%02i", minutes, seconds];
	
}

#pragma mark Interface
-(void)addHeaderTeamInfo
{
	SKSpriteNode *teamInfo = [[SKSpriteNode alloc] initWithColor:[UIColor colorWithWhite:1.0 alpha:0.0]
															size:CGSizeMake(self.size.width, 80)];
	teamInfo.anchorPoint = CGPointMake(0, 1);
	teamInfo.position = CGPointMake(0, self.size.height);
	teamInfo.name = @"teamInfo";
	
	SKSpriteNode *team1 = [self labelNodeFromString:data.team1.name andSize:12];
	team1.position = CGPointMake(self.size.width/2 - team1.size.width - 20, -40);
	[teamInfo addChild:team1];
	
	SKSpriteNode *team2 = [self labelNodeFromString:data.team2.name andSize:12];
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

#pragma Mark Node from String
-(SKSpriteNode*)labelNodeFromString:(NSString*)string andSize:(int)size
{
	
	SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
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
