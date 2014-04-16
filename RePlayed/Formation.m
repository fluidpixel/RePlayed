//
//  Formation.m
//  RePlayed
//
//  Created by Stuart Varrall on 10/04/2014.
//  Copyright (c) 2014 Fluid Pixel Ltd. All rights reserved.
//

#import "Formation.h"
#import "PlayerPositions.h"

@implementation Formation

-(Formation*)initWithFormation:(NSString*)formation
{
	
	self = [super init];
		
	if (self)
	{
		self.formationDescription = @"442";
		self.formationId = @"formation";
		//self.playerPositions = [[PlayerPositions alloc] init];
		self.playerPositions = [[NSMutableArray alloc] initWithCapacity:11];
		
//	Formation
//	if ([formation isEqualToString:@"2"])
//	{

		NSLog(@"442 formation");
		[self.playerPositions addObject:[NSValue valueWithCGPoint:CGPointMake(50, 5)]];
		
		[self.playerPositions addObject:[NSValue valueWithCGPoint:CGPointMake(10, 20)]];
		[self.playerPositions addObject:[NSValue valueWithCGPoint:CGPointMake(40, 20)]];
		[self.playerPositions addObject:[NSValue valueWithCGPoint:CGPointMake(60, 20)]];
		[self.playerPositions addObject:[NSValue valueWithCGPoint:CGPointMake(90, 20)]];
		
		[self.playerPositions addObject:[NSValue valueWithCGPoint:CGPointMake(10, 30)]];
		[self.playerPositions addObject:[NSValue valueWithCGPoint:CGPointMake(40, 30)]];
		[self.playerPositions addObject:[NSValue valueWithCGPoint:CGPointMake(60, 30)]];
		[self.playerPositions addObject:[NSValue valueWithCGPoint:CGPointMake(90, 30)]];
		
		[self.playerPositions addObject:[NSValue valueWithCGPoint:CGPointMake(30, 45)]];
		[self.playerPositions addObject:[NSValue valueWithCGPoint:CGPointMake(70, 45)]];
		
//	}
	}
	return self;
}
@end
