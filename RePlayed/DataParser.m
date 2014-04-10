//
//  DataParser.m
//  RePlayed
//
//  Created by Stuart Varrall on 08/04/2014.
//  Copyright (c) 2014 Fluid Pixel Ltd. All rights reserved.
//

#import "DataParser.h"
#import "Player.h"
#import "Team.h"
#import "Event.h"
#import "GameEvent.h"
#import "Formation.h"

@implementation DataParser

@synthesize team1;
@synthesize team2;
@synthesize eventArray;
@synthesize complete;
@synthesize playerList;
@synthesize gameEventArray;

+ (id)sharedData {
    static DataParser *sharedData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedData = [[self alloc] init];
    });
    return sharedData;
}

-(void)loadPlayerData
{
	//NSString *path = [[NSBundle mainBundle] pathForResource:@"optaPlayers" ofType:@"xml"];
	//NSData *data = [[NSData alloc] initWithContentsOfFile:path];
	//NSXMLParser* xmlParser = [[NSXMLParser alloc] initWithData:data];
	NSURL *dataURL = [[NSBundle mainBundle]
					URLForResource: @"players131898" withExtension:@"xml"];
	
	// this is the parsing machine
	
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:dataURL];
    
    // this class will handle the events
    [xmlParser setDelegate:self];
    [xmlParser setShouldResolveExternalEntities:NO];
	
	
    // now parse the document
    BOOL ok = [xmlParser parse];
    if (ok == NO)
        NSLog(@"Parse Error");
    else
        NSLog(@"Parse OK");
    
}

-(void)loadGameData
{
	//NSString *path = [[NSBundle mainBundle] pathForResource:@"optaPlayers" ofType:@"xml"];
	//NSData *data = [[NSData alloc] initWithContentsOfFile:path];
	//NSXMLParser* xmlParser = [[NSXMLParser alloc] initWithData:data];
	NSURL *dataURL = [[NSBundle mainBundle]
					  URLForResource: @"optaGame" withExtension:@"xml"];
	
	// this is the parsing machine
	
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:dataURL];
    
    // this class will handle the events
    [xmlParser setDelegate:self];
    [xmlParser setShouldResolveExternalEntities:NO];
	
    // now parse the document
    BOOL ok = [xmlParser parse];
    if (ok == NO)
        NSLog(@"Parse Error");
    else
        NSLog(@"Parse OK");
}

-(void)parserDidStartDocument:(NSXMLParser *)parser {
    NSLog(@"didStartDocument");

	if(!completedPlayerData)
	{
		team1 = [[Team alloc] init];
		team2 = [[Team alloc] init];
		eventArray = [[NSMutableArray alloc] init];
	}
	else
	{
		gameEventArray = [[NSMutableArray alloc] init];
	}
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"didEndDocument");
	//NSLog(@"%@", team1);
	//NSLog(@"%@", team2);
	
	if(!completedPlayerData)
	{
		NSSortDescriptor *sortDescriptor;
		sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time"
													 ascending:YES];
		NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
		eventArray = [NSMutableArray arrayWithArray:[eventArray sortedArrayUsingDescriptors:sortDescriptors]];
			
		playerList = [[NSMutableArray alloc] initWithArray:team1.players];
		[playerList addObjectsFromArray:team2.players];
		
		completedPlayerData = TRUE;
		[self loadGameData];
	}
	else
	{
		complete = TRUE;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"finishedParsing" object:nil];
		
	}
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
//    NSLog(@"didStartElement: %@", elementName);
//    
//    if (namespaceURI != nil)
//        NSLog(@"namespace: %@", namespaceURI);
//    
//    if (qName != nil)
//        NSLog(@"qualifiedName: %@", qName);
//    
//    // print all attributes for this element
//    NSEnumerator *attribs = [attributeDict keyEnumerator];
//    NSString *key, *value;
//    
//    while((key = [attribs nextObject]) != nil) {
//        value = [attributeDict objectForKey:key];
//        NSLog(@"  attribute: %@ = %@", key, value);
//    }

#pragma mark Player Data
	if ([elementName isEqualToString:@"TeamData"])
	{
		Team* team = [[Team alloc] init];
		team.teamRef = [attributeDict objectForKey:@"TeamRef"];
		team.score = [attributeDict objectForKey:@"Score"];
		team.side = [attributeDict objectForKey:@"Side"];
		
		if(!firstTeam)
		{
			team1 = team;
			firstTeam = TRUE;
			currentTeam = team1;
		}
		else
		{
			team2 = team;
			firstTeam = FALSE;
			currentTeam = team2;
		}
		
	}
	else if ([elementName isEqualToString:@"Goal"])
	{
		Event* event = [[Event alloc] init];
		event.team = currentTeam;
		event.eventID = [attributeDict objectForKey:@"EventID"];
		event.eventNumber = [attributeDict objectForKey:@"EventNumber"];
		event.period = [attributeDict objectForKey:@"Period"];
		event.uID = [attributeDict objectForKey:@"uID"];
		event.time = [NSNumber numberWithInt:[[attributeDict objectForKey:@"Time"] intValue]];
		event.timeStamp = [attributeDict objectForKey:@"TimeStamp"];
		event.type = @"goal";
		
		event.goalEvent = [[GoalEvent alloc] init];
		event.goalEvent.playerRef = [attributeDict objectForKey:@"PlayerRef"];
		event.goalEvent.type = [attributeDict objectForKey:@"Type"];

		[eventArray addObject:event];
	}
	else if ([elementName isEqualToString:@"Assist"])
	{
		Event* event = [eventArray lastObject];
		event.goalEvent.playerAssistRef = [attributeDict objectForKey:@"PlayerRef"];
	}
	else if ([elementName isEqualToString:@"Booking"])
	{
		Event* event = [[Event alloc] init];
		event.team = currentTeam;
		event.eventID = [attributeDict objectForKey:@"EventID"];
		event.eventNumber = [attributeDict objectForKey:@"EventNumber"];
		event.period = [attributeDict objectForKey:@"Period"];
		event.uID = [attributeDict objectForKey:@"uID"];
		event.time = [NSNumber numberWithInt:[[attributeDict objectForKey:@"Time"] intValue]];
		event.timeStamp = [attributeDict objectForKey:@"TimeStamp"];
		event.type = @"booking";
		
		event.booking = [[BookingEvent alloc] init];
		event.booking.card = [attributeDict objectForKey:@"Card"];
		event.booking.cardType = [attributeDict objectForKey:@"CardType"];
		event.booking.reason = [attributeDict objectForKey:@"Reason"];
		event.booking.playerRef = [attributeDict objectForKey:@"PlayerRef"];
		
		[eventArray addObject:event];
	}
	else if ([elementName isEqualToString:@"Substitution"])
	{
		Event* event = [[Event alloc] init];
		event.team = currentTeam;
		event.eventID = [attributeDict objectForKey:@"EventID"];
		event.eventNumber = [attributeDict objectForKey:@"EventNumber"];
		if ([[attributeDict objectForKey:@"Period"] isEqualToString:@"1"])
			event.period = @"FirstHalf";
		else
			event.period = @"SecondHalf";
		event.uID = [attributeDict objectForKey:@"uID"];
		event.time = [NSNumber numberWithInt:[[attributeDict objectForKey:@"Time"] intValue]];
		event.timeStamp = [attributeDict objectForKey:@"TimeStamp"];
		event.type = @"substitution";
		
		event.substituteEvent = [[SubstituteEvent alloc] init];
		event.substituteEvent.reason = [attributeDict objectForKey:@"Reason"];
		event.substituteEvent.subOff = [attributeDict objectForKey:@"SubOff"];
		event.substituteEvent.subOn = [attributeDict objectForKey:@"SubOn"];
				
		[eventArray addObject:event];
	}
	
	else if ([elementName isEqualToString:@"MatchPlayer"])
	{
		Player* player = [[Player alloc] init];
		
		player.position = [attributeDict objectForKey:@"Position"];
		player.shirtNumber = [attributeDict objectForKey:@"ShirtNumber"];
		player.playerRef = [attributeDict objectForKey:@"PlayerRef"];
		player.status = [attributeDict objectForKey:@"Status"];

		if(firstTeam)
		{
			[team1.players addObject:player];
		}
		else
		{
			[team2.players addObject:player];
		}
		
	}
    
	else if ([elementName isEqualToString:@"Team"])
	{
		if([team1.teamRef isEqualToString:[attributeDict objectForKey:@"uID"]])
		{
			currentTeam = team1;
			firstTeam = TRUE;
		}
		else if([team2.teamRef isEqualToString:[attributeDict objectForKey:@"uID"]])
		{
			currentTeam = team2;
			firstTeam = FALSE;
		}
	}
	
	else if ([elementName isEqualToString:@"Player"])
	{
		
		for (Player* player in team1.players)
		{
			if([player.playerRef isEqualToString:[attributeDict objectForKey:@"uID"]])
			{
				currentPlayerIndex = [team1.players indexOfObject:player];
				currentPlayer = player;
				break;
			}
		}
		for (Player* player in team2.players)
		{
			if([player.playerRef isEqualToString:[attributeDict objectForKey:@"uID"]])
			{
				currentPlayerIndex = [team1.players indexOfObject:player];
				currentPlayer = player;
				break;
			}
		}
		
	}
#pragma mark Game Data
	else if ([elementName isEqualToString:@"Game"])
	{
		team1.teamId = [attributeDict objectForKey:@"home_team_id"];
		team2.teamId = [attributeDict objectForKey:@"away_team_id"];
	}
	
	else if ([elementName isEqualToString:@"Event"])
	{
		if([[attributeDict objectForKey:@"type_id"] isEqualToString:@"34"])
		{
			NSLog(@"lineup");
		}
		
		GameEvent* gameEvent = [[GameEvent alloc] initWithDictionary: attributeDict];
		
		[gameEventArray addObject:gameEvent];
	}
	else if ([elementName isEqualToString:@"Q"])
	{
		EventQualifier* qualifier = [[EventQualifier alloc] initWithDictionary: attributeDict];
		GameEvent* gameEvent = gameEventArray.lastObject;
		
		if ([qualifier.qualifierId isEqualToString:@"130"])
		{
			if([gameEvent.teamId isEqualToString:team1.teamId])
			{
				team1.formation = [[Formation alloc] initWithFormation:[attributeDict objectForKey:@"value"]];
			}
			else
			{
				team2.formation = [[Formation alloc] initWithFormation:[attributeDict objectForKey:@"value"]];
			}
		}
		
		
		gameEvent.eventQualifier = qualifier;
	}
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	elementString = [[NSMutableString alloc] init];
	[elementString appendString:string];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    //NSLog(@"didEndElement: %@", elementName);
	
	if([elementName isEqualToString:@"First"])
	{
		if (currentPlayer)
		{
			currentPlayer.firstName = elementString;
		}
	}
	else if ([elementName isEqualToString:@"Last"])
	{
		if (currentPlayer)
		{
			currentPlayer.lastName = elementString;
		}
	}
	else if ([elementName isEqualToString:@"Name"])
	{
		currentTeam.name = elementString;
	}
		
	elementString = nil;
}

// error handling
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"XMLParser error: %@", [parseError localizedDescription]);
}

-(void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
    NSLog(@"XMLParser error: %@", [validationError localizedDescription]);
}

@end
