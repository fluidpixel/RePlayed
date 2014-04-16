//
//  Player.h
//  RePlayed
//
//  Created by Stuart Varrall on 08/04/2014.
//  Copyright (c) 2014 Fluid Pixel Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Team.h"

@interface Player : NSObject

@property (strong, nonatomic) NSString *playerRef;
@property (strong, nonatomic) NSString *position;
@property (assign) int formationPosition;
@property (strong, nonatomic) NSString *shirtNumber;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) Team *team;

@end
