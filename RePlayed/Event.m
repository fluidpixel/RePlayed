//
//  Event.m
//  RePlayed
//
//  Created by Stuart Varrall on 09/04/2014.
//  Copyright (c) 2014 Fluid Pixel Ltd. All rights reserved.
//

#import "Event.h"

@implementation Event

-(NSString*)description
{
	return [NSString stringWithFormat:@"<Event: %p, time: %@, period: %@, type: %@, team %@", self, self.time, self.period, self.type, self.team.teamRef];
}

@end
