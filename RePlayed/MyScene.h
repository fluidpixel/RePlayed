//
//  MyScene.h
//  RePlayed
//

//  Copyright (c) 2014 Fluid Pixel Ltd. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "DataParser.h"

@interface MyScene : SKScene
{
	DataParser* data;
	int runningTime;
	NSTimer* gameTimer;
		
	int nextEventIndex;
	int nextGameEventIndex;
	int matchTime;
	BOOL gameEnded;
	
	SKSpriteNode* ball;
	
	SKNode* actionLayer;
}
@end
