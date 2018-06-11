//
//  GameScene.swift
//  Project23
//
//  Created by Sabrina Fletcher on 5/24/18.
//  Copyright © 2018 Sabrina Fletcher. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var touch: Bool = false
    var tapQueue = [Int]()
    var fireBulletBtn: SKShapeNode! = nil
    
    var possibleEnemies = ["ball", "hammer", "tv"]
    var gameTimer: Timer!
    var isGameOver = false
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            //property observer updates score label as needed
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    let bulletSize = CGSize(width: 24 , height: 8)
    //let shipBulletName = "ShipFiredlasers"

    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        
        backgroundColor = UIColor.black
        
        starfield = SKEmitterNode(fileNamed: "Starfield")!
        starfield.position = CGPoint(x: 1024, y: 384)
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = 1
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        fireBulletBtn = SKShapeNode(circleOfRadius: 40)
        fireBulletBtn.position = CGPoint(x: 900, y: 100)
        fireBulletBtn.physicsBody?.isDynamic = false
        fireBulletBtn.physicsBody = SKPhysicsBody(circleOfRadius: 40)
        fireBulletBtn.physicsBody?.collisionBitMask = 0
        fireBulletBtn.physicsBody?.categoryBitMask = 0
        fireBulletBtn.fillColor = .red
        
        
        addChild(fireBulletBtn)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        
        
    }
    
    @objc func createEnemy() {
        possibleEnemies = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleEnemies) as! [String]
        let randomDistribution = GKRandomDistribution(lowestValue: 50, highestValue: 736)
        
        let sprite = SKSpriteNode(imageNamed: possibleEnemies[0])
        sprite.position = CGPoint(x: 1200, y: randomDistribution.nextInt())
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        isGameOver = true
        gameOver()
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isGameOver{
            
        } else{
            touch = false
        }
    }

    func gameOver(){
        let ac = UIAlertController(title: "Game Over", message: "Would you like to play again?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Yes", style: .default) {
            [unowned self] _ in
            self.score = 0
            self.isGameOver = false
            self.gotoGameScene()
        })
        ac.addAction(UIAlertAction(title: "No", style: .cancel) {
            [unowned self,ac] _ in
            ac.dismiss(animated: true, completion: nil)
        })
        self.view?.window?.rootViewController?.present(ac, animated: true, completion: nil)
        print(player.position)
    }

    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else{
            return
        }
        var location = touch.location(in: self)
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position.y = location.y
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            if fireBulletBtn.contains(location){
                makeBullet()
                print("tapped!")
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        // removes debris from the screen that has already passed the player and become invisible
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        if !isGameOver {
            //increments score if the game isn't over
            score += 1
        }
    }
    
    func gotoGameScene(){
        let gameScene: GameScene = GameScene(size: self.view!.bounds.size)
        let transition = SKTransition.fade(withDuration: 1.0)
        gameScene.scaleMode = SKSceneScaleMode.fill
        self.view?.presentScene(gameScene, transition: transition)
    }
    
    func makeBullet(){
        var bullet: SKNode
        
        bullet = SKSpriteNode(color: SKColor.cyan, size: bulletSize)
        bullet.zPosition = -5
        bullet.position = CGPoint(x: player.position.x, y: player.position.y)
        let action = SKAction.moveTo(x: self.size.width, duration: 0.6)
        bullet.run(SKAction.repeatForever(action))
        //bullet.name = shipBulletName
        self.addChild(bullet)
    }
    
    func fireBullet(bullet: SKNode, toDestination destination: CGPoint, withDuration duration:CFTimeInterval, andSoundFileName soundName: String){
        let bulletAction = SKAction.sequence([
            SKAction.move(to: destination, duration: duration),
            SKAction.wait(forDuration: 3.0/60.0),
            SKAction.removeFromParent()])
        
        let soundAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        bullet.run(SKAction.group([bulletAction, soundAction]))
        
        addChild(bullet)
    }
    
//    func fireShipBullets() {
//        let existingBullet = childNode(withName: shipBulletName)
//
//    }

}
