//
//  Formation.h
//  RePlayed
//
//  Created by Stuart Varrall on 10/04/2014.
//  Copyright (c) 2014 Fluid Pixel Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerPositions.h"

@interface Formation : NSObject

-(Formation*)initWithFormation:(NSString*)formation;

@property (nonatomic, strong) NSString* formationId;
@property (nonatomic, strong) NSString* formationDescription;
@property (nonatomic, strong) NSMutableArray* playerPositions;

@end
