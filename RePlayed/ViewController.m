//
//  ViewController.m
//  RePlayed
//
//  Created by Stuart Varrall on 08/04/2014.
//  Copyright (c) 2014 Fluid Pixel Ltd. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"
#import "DataParser.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	DataParser *dataParser = [DataParser sharedData];
	[dataParser loadPlayerData];
	
    // Present the scene.
    [self presentScene];
}

-(void)presentScene
{
	// Configure the view.
    SKView* skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [MyScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
	[skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
