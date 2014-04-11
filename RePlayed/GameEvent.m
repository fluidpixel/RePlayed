//
//  gameEvent.m
//  RePlayed
//
//  Created by Stuart Varrall on 10/04/2014.
//  Copyright (c) 2014 Fluid Pixel Ltd. All rights reserved.
//

#import "GameEvent.h"

@implementation GameEvent

-(GameEvent*)initWithDictionary:(NSDictionary*)dictionary
{
	self = [super init];
	
	if (self)
	{
		self.eventId = [dictionary objectForKey:@"event_id"];
		self.uniqueId = [dictionary objectForKey:@"id"];
		self.lastModified = [dictionary objectForKey:@"last_modified"];
		self.min = [[dictionary objectForKey:@"min"] intValue];
		self.sec = [[dictionary objectForKey:@"sec"] intValue];
		self.outcome = [dictionary objectForKey:@"outcome"];
		self.periodId = [dictionary objectForKey:@"period_id"];
		self.teamId = [dictionary objectForKey:@"team_id"];
		self.timeStamp = [dictionary objectForKey:@"timedtamp"];
		self.eventType = [[dictionary objectForKey:@"type_id"] intValue];
		self.playerId = [dictionary objectForKey:@"player_id"];
		self.posX = [[dictionary objectForKey:@"x"] floatValue];
		self.posY = [[dictionary objectForKey:@"y"] floatValue];
		self.qualifiers = [[NSMutableArray alloc] init];
	}
	
	return  self;
}

-(NSString*)description
{
	return [NSString stringWithFormat:@"<GameEvent: %p, id: %@, at: %02i:%02i>", self, self.eventId, self.min, self.sec];
}

@end
