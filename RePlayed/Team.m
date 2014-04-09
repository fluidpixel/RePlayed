//
//  Team.m
//  RePlayed
//
//  Created by Stuart Varrall on 09/04/2014.
//  Copyright (c) 2014 Fluid Pixel Ltd. All rights reserved.
//

#import "Team.h"

@implementation Team
-(id)init{
    self = [super init];
	
	self.players = [[NSMutableArray alloc] init];
    return self;
}

-(NSString*)description
{
	return [NSString stringWithFormat:@"<Team: %p, teamRef: %@, side: %@, Players: %@", self, self.teamRef, self.side, self.players];
}


@end
