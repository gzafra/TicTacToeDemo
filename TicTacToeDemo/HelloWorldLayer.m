//
//  HelloWorldLayer.m
//  TicTacToeDemo
//
//  Created by Guillermo Zafra on 29/07/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		self.isTouchEnabled = YES;
        
		// create and initialize a Label
		label = [CCLabelTTF labelWithString:@"TicTacTow" fontName:@"Marker Felt" fontSize:48];

		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
	
		// position the label on the center of the screen
		label.position =  ccp( size.width /2 , size.height * 0.92 );
		
		// add the label as a child to this Layer
		[self addChild: label];
        
        // Add grid
        gridBg = [CCSprite spriteWithFile:@"grid.png"];
        gridBg.position = ccp(size.width / 2, size.height / 2);
        [self addChild:gridBg z:1];
		
        [self setUpGame];

	}
	return self;
}
- (void) setUpGame
{
    // Set up game values
    currentPlayer = Player2;
    gameState = Playing;
    numMoves = 0;
    
    // Reset grid
    for (int i = 0; i < kGridSize; i++) {
        for (int j = 0; j < kGridSize; j++) {
            grid[i][j] = 0;
        }
    }
    
    // Clean grid of marks
    [gridBg removeAllChildrenWithCleanup:YES];
    
    // Show text
    [self nextTurn];
}

- (void) nextTurn
{
    // Switch to next player
    if (currentPlayer == Player1) {
        currentPlayer = Player2;
    }else{
        currentPlayer = Player1;
    }
    
    // Show help text
    int playerNumber = currentPlayer == Player1 ? 1 : 2;
    [self showText:[NSString stringWithFormat:@"Turn for player %d", playerNumber]];
}

- (void) markGridForCurrentPlayerAtPos:(CGPoint)_location{
    CGPoint realLoc = [gridBg convertToNodeSpace:_location];
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    // Calc the position of the grid based on touch location
    float boxSize = size.width / kGridSize;
    int col = realLoc.x / boxSize;
    int row = realLoc.y / boxSize;
    
    // Check if that position in the grid is available
    if (grid[row][col] == 0) {
        // Set value in the grid
        grid[row][col] = (int)currentPlayer;
        CCLOG(@"Player checked ROW:%d COL:%d",row,col);
        [self logGame];
        
        // Position mark sprite in the grid
        int imgIdx = currentPlayer == Player1 ? 0 : 1;
        CCSprite * mark = [CCSprite spriteWithFile:[NSString stringWithFormat:@"mark_%d.png",imgIdx]];
        mark.position = ccp(col * boxSize + boxSize / 2, row * boxSize + boxSize / 2);
        [gridBg addChild:mark];
        
        // Increase number of moves
        numMoves++;
        
        // Check current game state
        [self checkGame];
    }
}

- (void) checkGame{
    // Check end of game
    
    // Check draw
    if (numMoves == pow(kGridSize, 2)) {
        gameState = Finished;
        [self showText:[NSString stringWithFormat:@"It's a DRAW!"]];
        return;
    }
    
    bool playerWins = NO;
    int sum = 0;
    int sum2 = 0;
    
    // Check cols
    for (int col = 0; col < kGridSize; col++) {
        for (int row = 0; row < kGridSize; row++) {
            sum += grid[row][col];
        }
        CCLOG(@"Sum col %d = %d",col,sum);
        
        if (sum == ((int)currentPlayer * kGridSize)) {
            // current player wins
            playerWins = YES;
            break;
        }
        sum = 0;
    }
    
    if (!playerWins) {
        // Check rows
        for (int row = 0; row < kGridSize; row++) {
            for (int col = 0; col < kGridSize; col++) {
                sum += grid[row][col];
            }
            
            CCLOG(@"Sum row %d = %d",row,sum);
            
            if (sum == ((int)currentPlayer * kGridSize)) {
                // current player wins
                playerWins = YES;
                break;
            }
            sum = 0;
        }
    }
    
    if (!playerWins) {
        // Check diagonals
        int inverse = kGridSize;
        for (int row = 0; row < kGridSize; row++) {
            sum += grid[row][row];
            sum2 += grid[row][--inverse];
        }
        
        if (sum == ((int)currentPlayer * kGridSize)
            || sum2 == ((int)currentPlayer * kGridSize)) {
            playerWins = YES;
        }
    }

    if (playerWins) {
        gameState = Finished;
        int playerNumber = currentPlayer == Player1 ? 1 : 2;
        [self showText:[NSString stringWithFormat:@"Player %d Wins!", playerNumber]];
    }else{
        [self nextTurn];
    }
}

- (void) showText:(NSString*)_text{
    [label setString:_text];
}

- (void) logGame{
    for (int row = kGridSize - 1; row >= 0; row--) {
        CCLOG(@"%d | %d | %d", grid[row][0],grid[row][1],grid[row][2]);
    }
}

#pragma mark Touch Events

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

}

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for( UITouch *touch in touches ) {
        CGPoint location = [touch locationInView: [touch view]];
        location = [[CCDirector sharedDirector] convertToGL: location];
        if (gameState == Playing) {
            [self markGridForCurrentPlayerAtPos:location];
        }else{
            [self setUpGame];
        }
        
        return;
    }
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
