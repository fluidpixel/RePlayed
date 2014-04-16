//
//  Team.h
//  RePlayed
//
//  Created by Stuart Varrall on 09/04/2014.
//  Copyright (c) 2014 Fluid Pixel Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Formation.h"

@interface Team : NSObject

@property (nonatomic, strong) NSMutableArray *players;
@property (nonatomic, strong) NSString *teamRef;
@property (nonatomic, strong) NSString *score;
@property (nonatomic, strong) NSString *side;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *teamId;
@property (nonatomic, strong) Formation *formation;
@property (nonatomic, strong) UIColor *teamColor;
@end
