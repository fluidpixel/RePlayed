//
//  DataParser.m
//  RePlayed
//
//  Created by Stuart Varrall on 08/04/2014.
//  Copyright (c) 2014 Fluid Pixel Ltd. All rights reserved.
//

#import "DataParser.h"

@implementation DataParser

-(void)loadPlayerData
{
	//NSString *path = [[NSBundle mainBundle] pathForResource:@"optaPlayers" ofType:@"xml"];
	//NSData *data = [[NSData alloc] initWithContentsOfFile:path];
	//NSXMLParser* xmlParser = [[NSXMLParser alloc] initWithData:data];
	NSURL *dataURL = [[NSBundle mainBundle]
					URLForResource: @"optaPlayers" withExtension:@"xml"];
	
	// this is the parsing machine
	
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:dataURL];
    
    // this class will handle the events
    [xmlParser setDelegate:self];
    [xmlParser setShouldResolveExternalEntities:NO];
	
    // now parse the document
    BOOL ok = [xmlParser parse];
    if (ok == NO)
        NSLog(@"error");
    else
        NSLog(@"OK");
    
}

-(void)parserDidStartDocument:(NSXMLParser *)parser {
    NSLog(@"didStartDocument");
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"didEndDocument");
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    NSLog(@"didStartElement: %@", elementName);
    
    if (namespaceURI != nil)
        NSLog(@"namespace: %@", namespaceURI);
    
    if (qName != nil)
        NSLog(@"qualifiedName: %@", qName);
    
    // print all attributes for this element
    NSEnumerator *attribs = [attributeDict keyEnumerator];
    NSString *key, *value;
    
    while((key = [attribs nextObject]) != nil) {
        value = [attributeDict objectForKey:key];
        NSLog(@"  attribute: %@ = %@", key, value);
    }
	
    // add code here to load any data members
    // that your custom class might have
	
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    NSLog(@"didEndElement: %@", elementName);
}

// error handling
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"XMLParser error: %@", [parseError localizedDescription]);
}

-(void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
    NSLog(@"XMLParser error: %@", [validationError localizedDescription]);
}

@end
