//
//  GameOverScene.swift
//  SpriteKitSimpleGame
//
//  Created by Padraig Hession on 12/21/14.
//  Copyright (c) 2014 Podge. All rights reserved.
//

import Foundation
import SpriteKit
class GameOverScene: SKScene {
    init(size: CGSize, won:Bool) {
    super.init(size: size)
    // 1 -- set background to white
    backgroundColor = SKColor.whiteColor()
    // 2 -- based on the won parameter, set the message to you won or you lose
    var message = won ? "You Won!" : "You Lose :["
    // 3 -- display text to the screen
    let label = SKLabelNode(fontNamed: "Helvetica Neue Ultralight")
    label.text = message
    label.fontSize = 80
    label.fontColor = SKColor.blackColor()
    label.position = CGPoint(x: size.width/2, y: size.height/2)
    addChild(label)
    // 4 -- set up and run the sequence of two actions
    runAction(SKAction.sequence([
    SKAction.waitForDuration(3.0),
    SKAction.runBlock() {
    // 5 -- transition to GameScene
    let reveal = SKTransition.flipHorizontalWithDuration(0.5)
    let scene = GameScene(size: size)
    self.view?.presentScene(scene, transition:reveal)
    }]))
    }
    
    // 6 -- override initialiser on the scene 
    required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
    }
}