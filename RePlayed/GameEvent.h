//
//  gameEvent.h
//  RePlayed
//
//  Created by Stuart Varrall on 10/04/2014.
//  Copyright (c) 2014 Fluid Pixel Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventQualifier.h"

@interface GameEvent : NSObject

@property (nonatomic, strong) NSString* uniqueId;
@property (assign) int periodId;
@property (assign) int min;
@property (assign) int sec;
@property (nonatomic, strong) NSString* teamId;
@property (assign) int outcome;
@property (nonatomic, strong) NSString* timeStamp;
@property (nonatomic, strong) NSString* lastModified;
@property (nonatomic, strong) NSString* eventId;
@property (nonatomic, strong) NSString* playerId;
@property (assign) int	eventType;
@property (assign) float posX;
@property (assign) float posY;
@property (nonatomic, strong) NSMutableArray* qualifiers;

-(GameEvent*)initWithDictionary:(NSDictionary*)dictionary;

@end
