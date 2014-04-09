//
//  SubstituteEvent.h
//  RePlayed
//
//  Created by Stuart Varrall on 09/04/2014.
//  Copyright (c) 2014 Fluid Pixel Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SubstituteEvent : NSObject

@property (nonatomic, strong) NSString* subOff;
@property (nonatomic, strong) NSString* subOn;
@property (nonatomic, strong) NSString* substitutePosition;
@property (nonatomic, strong) NSString* reason;

@end
