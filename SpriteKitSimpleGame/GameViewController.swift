//
//  GameViewController.swift
//  SpriteKitSimpleGame
//
//  Created by Padraig Hession on 12/20/14.
//  Copyright (c) 2014 Podge. All rights reserved.
//

import UIKit
import SpriteKit
class GameViewController: UIViewController {
    //use viewDidLoad to create an instance of the GameScene on startup w/ the same size of the view itself
    override func viewDidLoad() {
    super.viewDidLoad()
    let scene = GameScene(size: view.bounds.size)
    let skView = view as SKView
    skView.showsFPS = true
    skView.showsNodeCount = true
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .ResizeFill
    skView.presentScene(scene)
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}