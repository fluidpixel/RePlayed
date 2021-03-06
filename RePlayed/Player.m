//
//  Player.m
//  RePlayed
//
//  Created by Stuart Varrall on 08/04/2014.
//  Copyright (c) 2014 Fluid Pixel Ltd. All rights reserved.
//

#import "Player.h"

@implementation Player

-(Player*)initWithDictionary:(NSDictionary*)dictionary
{
	self = [super init];
	
	if (self)
	{
		self.playerRef = [[dictionary objectForKey:@"playerRef"] substringToIndex:1];
		self.firstName = [dictionary objectForKey:@"firstName"];
		self.lastName = [dictionary objectForKey:@"lastName"];
		self.position = [dictionary objectForKey:@"position"];
		self.shirtNumber = [dictionary objectForKey:@"shirtNumber"];		
	}
	
	return  self;
}

-(NSString*)description
{
	return [NSString stringWithFormat:@"<Player: %p, playerRef: %@, formationPosition: %i, shirt: %@, name: %@ %@", self, self.playerRef, self.formationPosition, self.shirtNumber, self.firstName, self.lastName];
}

@end
