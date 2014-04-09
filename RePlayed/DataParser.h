//
//  DataParser.h
//  RePlayed
//
//  Created by Stuart Varrall on 08/04/2014.
//  Copyright (c) 2014 Fluid Pixel Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Team.h"
#import "Player.h"

@interface DataParser : NSObject <NSXMLParserDelegate>
{
	Team* team1;
	Team* team2;
	
	Team* currentTeam;
	Player* currentPlayer;
	int currentPlayerIndex;
	
	NSMutableArray* eventArray;
	
	NSString* characterElement;
	NSMutableString* elementString;
	
	BOOL firstTeam;
	
	BOOL complete;
}

@property (nonatomic, retain) NSMutableArray* eventArray;
@property (nonatomic, retain) Team* team1;
@property (nonatomic, retain) Team* team2;
@property (nonatomic, assign) BOOL complete;

-(void)loadPlayerData;

+ (id)sharedData;

@end
