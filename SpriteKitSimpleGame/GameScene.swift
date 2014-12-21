//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by Padraig Hession on 12/20/14.
//  Copyright (c) 2014 Podge. All rights reserved.
//

import SpriteKit
class GameScene: SKScene {
    //create player sprite 
    // 1 -- declare a private constant for the player (i.e. the ninja) which is an eg of a sprite
    let player = SKSpriteNode(imageNamed: "player")
    override func didMoveToView(view: SKView) {
    // 2 -- set background color
    backgroundColor = SKColor.whiteColor()
    // 3 -- Position the sprite to be 10% across vertically and centered horizontally
    player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
    // 4 -- to make the sprite appear on the screen, you just add it as a child of the scene (this is similar to how you make views children of other views)
    addChild(player)
    
    
    //call the addMonster function to create monsters
    runAction(SKAction.repeatActionForever(
        SKAction.sequence([
        SKAction.runBlock(addMonster),
        SKAction.waitForDuration(1.0)
        ])
    ))
    }
    
    
    
    //Monster Enemy methods
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(#min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    func addMonster() {
        // Create sprite
        let monster = SKSpriteNode(imageNamed: "monster")
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: monster.size.height/2, max: size.height -
        monster.size.height/2)
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above 
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
       // Add the monster to the scene
        addChild(monster)
        
        //actions
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -monster.size.width/2, y: actualY),
        duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        monster.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
}