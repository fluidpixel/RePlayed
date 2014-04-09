//
//  GoalEvent.h
//  RePlayed
//
//  Created by Stuart Varrall on 09/04/2014.
//  Copyright (c) 2014 Fluid Pixel Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoalEvent : NSObject

//<Goal EventID="1995195640" EventNumber="14316" Period="FirstHalf" PlayerRef="p5064" Time="43" TimeStamp="20070812T134254+0100" Type="Goal" uID="g2012-1">
//<Assist PlayerRef="p8987">p8987</Assist>

@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSString* playerAssistRef;
@property (nonatomic, strong) NSString* playerRef;

@end
