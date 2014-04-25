//
//  MyScene.h
//  RePlayed
//

//  Copyright (c) 2014 Fluid Pixel Ltd. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "DataParser.h"
#import "GameEvent.h"

@interface MyScene : SKScene
{
	DataParser* data;
	int runningTime;
	NSTimer* gameTimer;
		
	int nextEventIndex;
	int nextGameEventIndex;
	GameEvent* currentGameEvent;
	
	int matchTime;
	
	BOOL gameEnded;
	BOOL resetPlayers;
	
	SKSpriteNode* ball;
	
	float updateRate;
	float playerSize;
	
	SKNode* actionLayer;
}
@end
