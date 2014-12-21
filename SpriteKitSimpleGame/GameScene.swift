//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by Padraig Hession on 12/20/14.
//  Copyright (c) 2014 Podge. All rights reserved.
//

import SpriteKit

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}
func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}
func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}
func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}
#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
    return sqrt(x*x + y*y)
    }
    func normalized() -> CGPoint {
    return self / length()
    } }


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
        
        
    
        
        override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        // 1 - Choose one of the touches to work with
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        // 2 - Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position
        // 3 - Determine offset of location to projectile -- Subtract projectiles current position from touch location to get a vector from current position to the touch location
        let offset = touchLocation - projectile.position
        // 4 - Bail out if you are shooting down or backwards
        if (offset.x < 0) { return }
        // 5 - OK to add now - you've double checked position
        addChild(projectile)
        // 6 - Get the direction of where to shoot -- Convert the offset into a unit vector(of length 1) by calling normalised(). This will make it easier to make a vector with a fixed length in the same direction because 1 * length = length.
        let direction = offset.normalized()
        // 7 - Make it shoot far enough to be guaranteed off screen -- Remember a vector has a magnitude (how long it is) and a direction. Here i'm multiplying the vector by a thousand (this will be 1000 * 1)so it will go off the screen
        let shootAmount = direction * 1000
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        }
}