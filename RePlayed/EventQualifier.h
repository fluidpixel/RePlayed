//
//  eventQualifier.h
//  RePlayed
//
//  Created by Stuart Varrall on 10/04/2014.
//  Copyright (c) 2014 Fluid Pixel Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventQualifier : NSObject

@property (nonatomic, strong) NSString* uniqueId;
@property (assign) int qualifierId;
@property (nonatomic, strong) NSString* value;

-(EventQualifier*)initWithDictionary:(NSDictionary*)dictionary;

@end
