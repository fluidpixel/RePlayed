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
		
		updateRate = 0.1;
		playerSize = 10.0;
		
		SKSpriteNode* pitch = [SKSpriteNode spriteNodeWithImageNamed:@"pitch"];
		//pitch.size = CGSizeMake(self.size.width - 0, self.size.height - 120);
		pitch.size = CGSizeMake(320.0, 671.0);
		
		pitch.position = CGPointMake(0, 20);
		pitch.anchorPoint = CGPointZero;
		pitch.zPosition = -1;
		[self addChild:pitch];
		
		ball = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
		ball.position = [self pointOnPitchWithX:50.0 andY:50.0];
		ball.zPosition = 2;
		
		[self addChild:ball];
		
		actionLayer = [[SKNode alloc] init];
		actionLayer.name = @"actionLayer";
		[self addChild:actionLayer];
		
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
	
	currentGameEvent = [data.gameEventArray objectAtIndex:0];
	
	matchTime = 91*60;
	SKSpriteNode* gameTimeLabel = [self labelNodeFromString:@"00:00" andSize:30];
	gameTimeLabel.position = CGPointMake(self.size.width/2 - gameTimeLabel.size.width/2, self.size.height - 95);
	gameTimeLabel.name = @"timeLabel";
	[self addChild:gameTimeLabel];
	
	[self showEventDetailLabelWithString:@"KICK OFF" andColor:[UIColor clearColor]];
	
	[self pauseGameFor:updateRate * 50];
	
	[self setPlayerFormations];
	
}

-(void)setPlayerFormations
{
	
	SKNode* playerNode = [actionLayer childNodeWithName:@"players"];
	if(!playerNode)
	{
		playerNode = [[SKNode alloc] init];
		playerNode.name = @"players";
		[actionLayer addChild:playerNode];
	}
	
	for(Player* player in data.playerList)
	{
		BOOL existingPlayer = false;
				
		if (player.formationPosition != 0)
		{
						
			CGPoint point;
			if ([player.team isEqual:data.team1])
			{
				CGPoint playerPosition = [data.team1.formation.playerPositions[player.formationPosition - 1] CGPointValue];
				// first half = 1, pre match = 16, first extra time = 3
				if (currentGameEvent.periodId == 1 || currentGameEvent.periodId == 16 || currentGameEvent.periodId == 3)
				{
					point = [self pointOnPitchWithX:playerPosition.x andY:playerPosition.y];
				}
				else
				{
					point = [self pointOnPitchWithX:100-playerPosition.x andY:100-playerPosition.y];
				}
			}
			else
			{
				CGPoint playerPosition = [data.team2.formation.playerPositions[player.formationPosition - 1] CGPointValue];
								// first half = 1, pre match = 16, first extra time = 3
				if (currentGameEvent.periodId == 1 || currentGameEvent.periodId == 16 || currentGameEvent.periodId == 3)
				{
					point = [self pointOnPitchWithX:100 - playerPosition.x andY:100 - playerPosition.y];
				}
				else
				{
					point = [self pointOnPitchWithX:playerPosition.x andY:playerPosition.y];
				}
				
			}
			
			for(SKSpriteNode* playerSprite in playerNode.children)
			{
				if ([[playerSprite.userData objectForKey:@"playerRef"] isEqualToString:player.playerRef])
				{
					[playerSprite removeAllActions];
					[playerSprite setAlpha:1.0];
					
					[playerSprite runAction:[SKAction sequence:@[[SKAction moveTo:point duration:updateRate]]]];
					
					existingPlayer = true;
					break;
				}
			}
			
			if (!existingPlayer) //if we haven't reset a player's position, then we need to create him
			{
					NSString* playerImage = @"playerRed";
					if ([player.team isEqual:data.team2])
					{
						playerImage = @"playerBlue";
					}
					
					SKSpriteNode* playerSprite = [SKSpriteNode spriteNodeWithImageNamed:playerImage];
					playerSprite.position = CGPointMake(point.x, point.y);
					playerSprite.zPosition = 1;
					
					playerSprite.name = @"playerSprite";
					NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithCapacity:1];
					[playerSprite setUserData:dict];
					[[playerSprite userData] setObject:player.playerRef forKey:@"playerRef"];
					
					SKLabelNode* playerLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier-Bold"];
					playerLabel.text = player.shirtNumber;
					playerLabel.fontSize = 10;
					playerLabel.position = CGPointMake(0, -playerLabel.fontSize/2);
					playerLabel.name = @"playerLabel";
					playerLabel.fontColor = [UIColor whiteColor];//player.team.teamColor;
					
					[playerSprite addChild:playerLabel];
					[playerNode addChild:playerSprite];
				
				[playerSprite runAction:[SKAction sequence:@[[SKAction waitForDuration:updateRate * 200]]]];
			}
		}
	}
}

-(void)updateTimer:(NSTimer *)timer
{
	resetPlayers = false;
	runningTime ++;
	
	//pause timer for tempTimer time to "wait" for half time
	if (runningTime == (45 * 60))
	{
		[self pauseGameFor:updateRate * 100];
		
		//reset action grid
		NSMutableArray* childrenToRemove = [NSMutableArray arrayWithArray:[actionLayer children]];
		[childrenToRemove removeObject:[actionLayer childNodeWithName:@"players"]];

		[self setPlayerFormations];
		
		[actionLayer removeChildrenInArray:childrenToRemove];
		
		[self showEventDetailLabelWithString:@"HALF TIME" andColor:[UIColor clearColor]];
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
	currentGameEvent = [data.gameEventArray objectAtIndex:nextGameEventIndex];
	
	while(currentGameEvent.min == 0 && currentGameEvent.sec == 0)
	{
		if(nextGameEventIndex < data.gameEventArray.count-1)
		{
			nextGameEventIndex++;
			currentGameEvent = [data.gameEventArray objectAtIndex:nextGameEventIndex];
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
	
	while(minutes == currentGameEvent.min && seconds == currentGameEvent.sec)
	{
		//NSLog(@"event: %02i at %02i:%02i %.01f,%.01f", nextGameEvent.eventType, nextGameEvent.min, nextGameEvent.sec, nextGameEvent.posX, nextGameEvent.posY);
		UIColor* color;
		CGPoint point;
		if ([currentGameEvent.teamId isEqualToString:data.team1.teamId])
		{
			color = [UIColor redColor];
			if(currentGameEvent.periodId == 1)
				point = [self pointOnPitchWithX:currentGameEvent.posY andY:currentGameEvent.posX];
			else
				point = [self pointOnPitchWithX:100-currentGameEvent.posY andY:100-currentGameEvent.posX];
		}
		else
		{
			color = [UIColor blueColor];
			if(currentGameEvent.periodId == 1)
				point = [self pointOnPitchWithX:100-currentGameEvent.posY andY:100-currentGameEvent.posX];
			else
				point = [self pointOnPitchWithX:currentGameEvent.posY andY:currentGameEvent.posX];
		}
	
		//ignore formations, start/stop delays from action points  ball out = 5
		if (currentGameEvent.eventType != 17 && currentGameEvent.eventType != 18 && currentGameEvent.eventType != 19 && currentGameEvent.eventType != 24 && currentGameEvent.eventType != 34 && currentGameEvent.eventType != 32 && currentGameEvent.eventType != 43 && currentGameEvent.eventType != 27 && currentGameEvent.eventType != 28 && currentGameEvent.eventType != 30 && currentGameEvent.eventType != 40 && currentGameEvent.eventType != 5)
		{
			[self addPlayer:currentGameEvent.playerId atPoint:point withColor:color];
			[self moveBallWithEvent:currentGameEvent andPosition:point];
			
			//goal 16, miss 13, saved attempt 15, save 10
			if (currentGameEvent.eventType == 16 || currentGameEvent.eventType == 13 || currentGameEvent.eventType == 15 || currentGameEvent.eventType == 10)
			{
				color = [UIColor whiteColor];
				CGSize size = CGSizeMake(15, 15);
				
				//show an action marker, but not for the keeper's save
				if (currentGameEvent.eventType != 10)
				{
					if ([currentGameEvent.teamId isEqualToString:data.team1.teamId])
					{
						if(currentGameEvent.periodId == 1)
							[self addActionPointatPoint:[self pointOnPitchWithX:currentGameEvent.posY andY:currentGameEvent.posX] withColor:color andSize:size];
						else
							[self addActionPointatPoint:[self pointOnPitchWithX:100-currentGameEvent.posY andY:100-currentGameEvent.posX] withColor:color andSize:size];
					}
					else
					{
						if(currentGameEvent.periodId == 1)
							[self addActionPointatPoint:[self pointOnPitchWithX:100-currentGameEvent.posY andY:100-currentGameEvent.posX] withColor:color andSize:size];
						else
							[self addActionPointatPoint:[self pointOnPitchWithX:currentGameEvent.posY andY:currentGameEvent.posX] withColor:color andSize:size];
					}
				}
				
				if (currentGameEvent.eventType == 16)//goal
				{
					[self scoredGoal:currentGameEvent];
				}
				else if (currentGameEvent.eventType == 13)//miss
				{
					[self missedChance:currentGameEvent];
				}
				else if (currentGameEvent.eventType == 15)//saved Shot
				{
					[self saveEvent:currentGameEvent];
				}
				else if (currentGameEvent.eventType == 10)//keeper save
				{
					[self keeperSaveEvent:currentGameEvent];
				}
				
			}
			else if (currentGameEvent.eventType == 4) //foul
			{
				if (currentGameEvent.outcome == 1)
				{
					[self foulEvent:currentGameEvent];
				}
				
			}
			else
			{
				//[self addActionPointatPoint:point withColor:color andSize:CGSizeMake(4,4)];
			}
		}
		
		
		//Game restart events, so reset ball
		if(currentGameEvent.eventType == 32 || currentGameEvent.eventType == 30)
		{
			[ball runAction:[SKAction moveTo:[self pointOnPitchWithX:50.0 andY:50.0] duration:updateRate]];
		}
		else if (currentGameEvent.eventType == 17)
		{
			[self foulEvent:currentGameEvent];
		}
		else if (currentGameEvent.eventType == 18) //player off
		{
			for(Player* player in data.playerList)
			{
				if ([player.playerRef isEqualToString:currentGameEvent.playerId])
				{
					NSLog(@"%@ %@ substituted Off", player.firstName, player.lastName);
					[self removePlayerWithId:player.playerRef];
					break;
				}
			}
			
		}
		else if (currentGameEvent.eventType == 19) //player on
		{
			for(Player* player in data.playerList)
			{
				if ([player.playerRef isEqualToString:currentGameEvent.playerId])
				{
					NSLog(@"%@ %@ substituted On", player.firstName, player.lastName);
					int position = 1;
					for (EventQualifier* qualifier in currentGameEvent.qualifiers)
					{
						if(qualifier.qualifierId == 145)
						{
							position = [qualifier.value intValue];
							player.formationPosition = position;
							break;
						}
					}
					
					[self addPlayer:player.playerRef atPoint:[player.team.formation.playerPositions[position-1] CGPointValue] withColor:player.team.teamColor];

					break;
				}
			}
		}
		
		//check if there's any more events at this time
		if (nextGameEventIndex < data.gameEventArray.count-1)
		{
			nextGameEventIndex++;
			currentGameEvent = [data.gameEventArray objectAtIndex:nextGameEventIndex];
		}
		else
		{
			currentGameEvent = nil;
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
		[[actionArray objectAtIndex:1] removeFromParent];
	}
	
	//[actionLayer addChild:actionPoint];
}

-(void)addPlayer:(NSString*)playerId atPoint:(CGPoint)point withColor:(UIColor*)color
{
	
	NSString* playerNumber;
	NSString* playerRef;
	SKNode* playerNode = [actionLayer childNodeWithName:@"players"];
		
	if(!playerNode)
	{
		playerNode = [[SKNode alloc] init];
		playerNode.name = @"players";
		[actionLayer addChild:playerNode];
	}
	
	for(Player* player in data.playerList)
	{
		
		if([playerId isEqualToString:player.playerRef])
		{
			playerNumber = player.shirtNumber;
			playerRef = player.playerRef;
			
			CGPoint playerFormationPoint;
			if ([player.team isEqual:data.team1])
			{
				CGPoint playerPosition = [data.team1.formation.playerPositions[player.formationPosition - 1] CGPointValue];
				
				if (currentGameEvent.periodId == 1)
				{
					playerFormationPoint = [self pointOnPitchWithX:playerPosition.x andY:playerPosition.y];
					point = CGPointMake(point.x, point.y - playerSize);
				}
				else
				{
					playerFormationPoint = [self pointOnPitchWithX:100-playerPosition.x andY:100-playerPosition.y];
					point = CGPointMake(point.x, point.y + playerSize);
				}
			}
			else
			{
				CGPoint playerPosition = [data.team2.formation.playerPositions[player.formationPosition - 1] CGPointValue];
				if (currentGameEvent.periodId == 1)
				{
					playerFormationPoint = [self pointOnPitchWithX:100 - playerPosition.x andY:100 - playerPosition.y];
					point = CGPointMake(point.x, point.y + playerSize);
				}
				else
				{
					playerFormationPoint = [self pointOnPitchWithX:playerPosition.x andY:playerPosition.y];
					point = CGPointMake(point.x, point.y - playerSize);
				}
				
				
			}
			
			BOOL movedPlayer = false;
			
			for(SKSpriteNode* player in playerNode.children)
			{
				if ([[player.userData objectForKey:@"playerRef"] isEqualToString:playerRef])
				{
					[player removeAllActions];
					[player setAlpha:1.0];
					[player runAction:[SKAction sequence:@[[SKAction moveTo:CGPointMake(point.x, point.y) duration:updateRate],
														  [SKAction waitForDuration:updateRate * 200],
														  [SKAction moveTo:playerFormationPoint duration:updateRate * 20]]]];
					
					movedPlayer = true;
					break;
				}
			}
			
			if (!movedPlayer)
			{
				NSString* playerImage = @"playerRed";
				if ([player.team isEqual:data.team2])
				{
					playerImage = @"playerBlue";
				}
				
				SKSpriteNode* playerSprite = [SKSpriteNode spriteNodeWithImageNamed:playerImage];
				playerSprite.position = CGPointMake(point.x, point.y);
				playerSprite.zPosition = 1;
				
				playerSprite.name = @"playerSprite";
				NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithCapacity:1];
				[playerSprite setUserData:dict];
				[[playerSprite userData] setObject:playerRef forKey:@"playerRef"];
				
				SKLabelNode* playerLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier-Bold"];
				playerLabel.text = playerNumber;
				playerLabel.fontSize = 12;
				playerLabel.position = CGPointMake(0, 0 - playerLabel.fontSize/2);
				playerLabel.name = @"playerLabel";
				playerLabel.fontColor = [UIColor whiteColor];
				
				[playerSprite addChild:playerLabel];
				[playerNode addChild:playerSprite];
				
				[playerSprite runAction:[SKAction sequence:@[[SKAction waitForDuration:updateRate * 100],
															[SKAction moveTo:playerFormationPoint duration:updateRate * 20]]]];
			}
			
			break;
		}
	}
}

-(void)removePlayerWithId:(NSString*)playerId
{
	SKNode* playerNode = [actionLayer childNodeWithName:@"players"];
	if(playerNode)
	{
		for(Player* player in data.playerList)
		{
			if([playerId isEqualToString:player.playerRef])
			{
				for(SKLabelNode* label in playerNode.children)
				{
					if ([[label.userData objectForKey:@"playerRef"] isEqualToString:player.playerRef])
					{
						[label removeAllActions];
						[label removeFromParent];
						break;
					}
				}
			}
		}
	}
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
				float y = -2.0;
				if(event.posX > 50)
				{
					y = 102.0;
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
		
		if (event.eventType == 16) //goal
		{
			[ball runAction:[SKAction sequence:@[
												 [SKAction moveTo:point duration:updateRate*1.2],
												 [SKAction moveTo:goalPoint duration:updateRate],[SKAction waitForDuration:updateRate*50],
												 [SKAction moveTo:[self pointOnPitchWithX:50.0 andY:50.0] duration:0.0]]]];
		}
		else //miss
		{
			[ball runAction:[SKAction sequence:@[
												 [SKAction moveTo:point duration:updateRate*1.2],
												 [SKAction moveTo:goalPoint duration:updateRate]]]];
		}
	}
	else if(event.eventType == 15) //saved shot
	{
		float x = 0;
		float y = 0;
		CGPoint eventPosition;
		
		for (EventQualifier* qualifier in event.qualifiers)
		{
			if (qualifier.qualifierId == 146) //x
			{
				y = [qualifier.value floatValue];
			}
			if( qualifier.qualifierId == 147) //y
			{
				x = [qualifier.value floatValue];
			}
		}
		
		if (x != 0 && y != 00)
		{
			if ([event.teamId isEqualToString:data.team1.teamId])
			{
				if (event.periodId == 1)
					eventPosition = [self pointOnPitchWithX:x andY:y];
				else
					eventPosition = [self pointOnPitchWithX:100-x andY:100-y];
			}
			else
			{
				if (event.periodId == 1)
					eventPosition = [self pointOnPitchWithX:100-x andY:100-y];
				else
					eventPosition = [self pointOnPitchWithX:x andY:y];
			}
			
			[ball runAction:[SKAction moveTo:eventPosition duration:updateRate*1.2]];
		}
	}
//	else if(event.eventType == 10) //goalkeeper save
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
				 [SKAction group:@[[SKAction sequence:@[[SKAction scaleTo:2.0 duration:updateRate*0.6], [SKAction scaleTo:1.0 duration:updateRate*0.6]]], [SKAction moveTo:point duration:updateRate*1.2]]]];
				inAir = TRUE;
				break;
				
			}
		}
		if (!inAir)
		{
			[ball runAction:[SKAction moveTo:point duration:updateRate * 1.2]];
		}
	}
	
}

-(void)scoredGoal:(GameEvent*)nextEvent
{
	[self pauseGameFor:updateRate * 50];
	resetPlayers = true;
	
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
	UIColor* color = [UIColor clearColor];
	
	for(Player* player in data.playerList)
	{
			
		if([nextEvent.playerId isEqualToString:player.playerRef])
		{
			eventDetails = [NSString stringWithFormat:@"%@ %@'s %@", player.firstName, player.lastName, @"Goal"];
			color = player.team.teamColor;
			break;
		}
	}
	
	[self showEventDetailLabelWithString:eventDetails andColor:color];
	
}

-(void)missedChance:(GameEvent*)nextEvent
{
	[self pauseGameFor:updateRate * 20];
	
	NSMutableString* eventDetails;
	UIColor* color = [UIColor clearColor];
	for(Player* player in data.playerList)
	{
		//NSString* playerId = [NSString stringWithFormat:@"p%@", nextEvent.playerId];
		
		if([nextEvent.playerId isEqualToString:player.playerRef])
		{
			eventDetails = [NSMutableString stringWithFormat:@"%@ %@ %@", player.firstName, player.lastName, @"Missed"];
			color = player.team.teamColor;
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
	
	[self showEventDetailLabelWithString:eventDetails andColor:color];
	
}

-(void)saveEvent:(GameEvent*)nextEvent
{
	//[self pauseGameFor:updateRate * 100];
	
	NSMutableString* eventDetails;
	UIColor* color = [UIColor clearColor];
	
	for(Player* player in data.playerList)
	{
		if([nextEvent.playerId isEqualToString:player.playerRef])
		{
			eventDetails = [NSMutableString stringWithFormat:@"%@ %@ %@", player.firstName, player.lastName, @"Shot Saved"];
			color = player.team.teamColor;
			break;
		}
	}
	
	[self showEventDetailLabelWithString:eventDetails andColor:color];
	
}

-(void)keeperSaveEvent:(GameEvent*)nextEvent
{
	[self pauseGameFor:updateRate * 20];
	
//	NSMutableString* eventDetails;
//	
//	for(Player* player in data.playerList)
//	{
//		if([nextEvent.playerId isEqualToString:player.playerRef])
//		{
//			eventDetails = [NSMutableString stringWithFormat:@"%@ %@ %@", player.firstName, player.lastName, @"Shot Saved"];
//			break;
//		}
//	}
//	
//	[self showEventDetailLabelWithString:eventDetails];
	
}

-(void)foulEvent:(GameEvent*)nextEvent
{
	[self pauseGameFor:updateRate * 20];
	
	NSMutableString* eventDetails;
	UIColor* color = [UIColor clearColor];
	for(Player* player in data.playerList)
	{
		if([nextEvent.playerId isEqualToString:player.playerRef])
		{
			eventDetails = [NSMutableString stringWithFormat:@"%@ %@ %@", player.firstName, player.lastName, @"Fouled"];
			color = player.team.teamColor;
			break;
		}
	}
	
	for(EventQualifier* qualifier in nextEvent.qualifiers)
	{
		if(qualifier.qualifierId == 31)
		{
			[eventDetails appendString:@". Yellow Card"];
		}
		else if(qualifier.qualifierId == 32)
		{
			[eventDetails appendString:@". Second Yellow Card"];
		}
		else if(qualifier.qualifierId == 33)
		{
			[eventDetails appendString:@". Red Card!"];
		}
	}
	
	[self showEventDetailLabelWithString:eventDetails andColor:color];
	
}
-(void)showEventDetailLabelWithString:(NSString*)string andColor:(UIColor*)color
{
	SKSpriteNode* details = [self labelNodeFromString:string andSize:14];
	details.position = CGPointMake(self.size.width/2 - details.size.width/2, self.size.height-120);
	details.name = @"eventLabel";
	details.color = color;
	details.zPosition = 5;
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
	
	NSMutableArray* childrenToRemove = [NSMutableArray arrayWithArray:[actionLayer children]];
	[childrenToRemove removeObject:[actionLayer childNodeWithName:@"players"]];
	[actionLayer removeChildrenInArray:childrenToRemove];
	
	if (resetPlayers)
	{
		//TODO: this should reset back to formations rather than removing them all
		[self setPlayerFormations];
	}
	
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
	NSMutableArray* childrenToRemove = [NSMutableArray arrayWithArray:[actionLayer children]];
	[childrenToRemove removeObject:[actionLayer childNodeWithName:@"players"]];
	[actionLayer removeChildrenInArray:childrenToRemove];
	
	[self showEventDetailLabelWithString:@"END GAME" andColor:[UIColor clearColor]];
	
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
