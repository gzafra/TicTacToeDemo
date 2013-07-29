//
//  HelloWorldLayer.h
//  TicTacToeDemo
//
//  Created by Guillermo Zafra on 29/07/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// Game values
#define kGridSize 3

enum EGameState{
    Playing,
    Finished
};

enum EPlayerType {
    Player1 = -1,
    Player2 = 1
    };

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
    int grid[kGridSize][kGridSize];
    enum EPlayerType currentPlayer;
    enum EGameState gameState;
    CCSprite *gridBg;
    CCLabelTTF *label;
    int numMoves;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
