//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by Padraig Hession on 12/20/14.
//  Copyright (c) 2014 Podge. All rights reserved.
//

import SpriteKit

//collision detection and physics struct -- this will set up constants for the physics categories
//note that the category on the spritekit is just a single 32 bit integer, and acts as a bitmask 
//i.e. each of the 32 bits in the integer represents a category(i.e. there are 32 categories max because 1 int = 1 category) 
//here I'm setting the 1st bit to indicate a monster and the next bit over to indicate a projectile etc.
struct PhysicsCategory {
static let None : UInt32 = 0
static let All : UInt32 = UInt32.max
static let Monster : UInt32 = 0b1 // 1
static let Projectile: UInt32 = 0b10 // 2
}

//vector functions for shooting projectiles
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


class GameScene: SKScene, SKPhysicsContactDelegate {
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
    
    //physicsWorld -- set to have no gravity + set the scene as the delegate to be notified when 2 physics bodies collide 
    physicsWorld.gravity = CGVectorMake(0, 0)
    physicsWorld.contactDelegate = self
    
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
            
        //physicsWorld
        //create the physics body for the sprite -- define it as a recangle as the same size of the sprite
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size)
        //set the sprite to be dynamic -- means that the physics engine will not control the movement of the monster. I will through the actions i've written below
        monster.physicsBody?.dynamic = true
        //set the category bitmask to be the monster category I defined earlier in the struct at the top of this page
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        //The contactTestBitMask indicates what categories of objects this object should notify the contact listner when they intersect. Projectiles will therefore be chosen here 
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        //collisionBitMask indicates how contacts between objects are handled (e.g. will they bounce off each other?) Here, I want both objects to go right through each other i.e. i'll set it to 0
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None
        
            
            
            
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
        
        
        
        //Touch
        override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        // 1 - Choose one of the touches to work with
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        // 2 - Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position
        
        
        //physicsWorld
        //set physicsBody of projectile sprite -- defined as a circle
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        //set the sprite to be dynamic -- means the physics engine won't control the movement of the projectile. I will control it using the actions i've created below
        projectile.physicsBody?.dynamic = true
        //set the categoryBitMask to be the projectile category -- defined in the struct at the top of the page
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        //set the contactTestBitMask --  decides when to contact when it comes into contact with a specified category. the specified category here should therefore be Monster
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        //set the collisionBitMask -- decides what to do when the categories collide (e.g. they could bounce off each other) but i'm going to let them pass each other when they collide 
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        //usesPreciseCollisionDetection: Important to use this for fast moving objects + if this was set to false, bodies would pass each other without any collision being detected i.e. I set it to true
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        
        
        
        
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
        
        
        //this function will be called when the projectile collides with the monster
        //it will remove the projectile and the monster from the scene when they collide
        func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode) {
            println("Hit")
            projectile.removeFromParent()
            monster.removeFromParent()
        }
        
        //implement contact delegate method
        //remember the contactDelagate of the physicsWorld is the scene 
        //this method will be called when two physics bodies collide 
        
        func didBeginContact(contact: SKPhysicsContact) {
            // 1 -- arranges the bodies so they are sorted by their category bitmasks
            var firstBody: SKPhysicsBody
            var secondBody: SKPhysicsBody
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
            }
            else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
            }
            // 2 -- check to see if the two bodies that collide are monster and projectile -- id=f so, calls the method
            if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            projectileDidCollideWithMonster(firstBody.node as SKSpriteNode, monster: secondBody.node as SKSpriteNode)
            }
        }
        
        
}