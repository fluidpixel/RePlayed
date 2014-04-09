//
//  Event.h
//  RePlayed
//
//  Created by Stuart Varrall on 09/04/2014.
//  Copyright (c) 2014 Fluid Pixel Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BookingEvent.h"
#import "SubstituteEvent.h"
#import "GoalEvent.h"
#import "Team.h"

@interface Event : NSObject

@property (nonatomic, strong) NSNumber* time;
@property (nonatomic, strong) NSString* timeStamp;
@property (nonatomic, strong) NSString* uID;
@property (nonatomic, strong) NSString* eventID;
@property (nonatomic, strong) NSString* eventNumber;
@property (nonatomic, strong) NSString* period;
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) Team* team;

@property (nonatomic, strong) BookingEvent* booking;
@property (nonatomic, strong) SubstituteEvent* substituteEvent;
@property (nonatomic, strong) GoalEvent* goalEvent;

@end
