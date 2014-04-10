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
		self.playerPositions = [[PlayerPositions alloc] init];
		
//	Formation
//	if ([formation isEqualToString:@"2"])
//	{

		NSLog(@"442 formation");
		
		self.playerPositions.player1 = CGPointMake(50, 5);
		
		self.playerPositions.player2 = CGPointMake(10, 20);
		self.playerPositions.player3 = CGPointMake(40, 20);
		self.playerPositions.player4 = CGPointMake(60, 20);
		self.playerPositions.player5 = CGPointMake(90, 20);
		
		self.playerPositions.player6 = CGPointMake(10, 30);
		self.playerPositions.player7 = CGPointMake(40, 30);
		self.playerPositions.player8 = CGPointMake(60, 30);
		self.playerPositions.player9 = CGPointMake(90, 30);
		
		self.playerPositions.player10 = CGPointMake(30, 45);
		self.playerPositions.player11 = CGPointMake(70, 45);
//	}
	}
	return self;
}
@end
