//
//  BookingEvent.h
//  RePlayed
//
//  Created by Stuart Varrall on 09/04/2014.
//  Copyright (c) 2014 Fluid Pixel Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookingEvent : NSObject

@property (nonatomic, strong) NSString* card;
@property (nonatomic, strong) NSString* cardType;
@property (nonatomic, strong) NSString* playerRef;
@property (nonatomic, strong) NSString* reason;

@end
