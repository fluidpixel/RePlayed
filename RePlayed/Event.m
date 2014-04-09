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
	return [NSString stringWithFormat:@"<Event: %p, time: %02i period: %@ type: %@ team: %@", self, [self.time intValue], [self.period stringByPaddingToLength:10 withString:@" " startingAtIndex:0], [self.type stringByPaddingToLength:12 withString:@" " startingAtIndex:0], self.team.name];
}



@end
