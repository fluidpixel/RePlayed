//
//  eventQualifier.m
//  RePlayed
//
//  Created by Stuart Varrall on 10/04/2014.
//  Copyright (c) 2014 Fluid Pixel Ltd. All rights reserved.
//

#import "EventQualifier.h"

@implementation EventQualifier

-(EventQualifier*)initWithDictionary:(NSDictionary*)dictionary
{
	self = [super init];
	
	if (self)
	{
		self.uniqueId = [dictionary objectForKey:@"id"];
		self.qualifierId = [[dictionary objectForKey:@"qualifier_id"] intValue];
		self.value = [dictionary objectForKey:@"value"];
	}
	
	return  self;
}

-(NSString*)description
{
	//<Q id="715088221" qualifier_id="140" value="52.1" />
	return [NSString stringWithFormat:@"<Qualifier: %p, uniqueId: %@, id: %i, value: %@", self, self.uniqueId, self.qualifierId, self.value];
}

@end
