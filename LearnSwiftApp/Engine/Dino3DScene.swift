import SceneKit
import SwiftUI
import Combine

// MARK: - Game State Delegate
protocol Dino3DGameDelegate: AnyObject {
    func dinoDidUpdateScore(_ score: Int, distance: Int, coins: Int)
    func dinoDidCollectCoin()
    func dinoDidTriggerShieldBreak()
    func dinoDidGameOver(score: Int, distance: Int, coins: Int, obstaclesCleared: Int)
}

// MARK: - 3D Dinosaur Endless Runner Scene
class Dino3DScene: SCNScene, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {
    
    weak var gameDelegate: Dino3DGameDelegate?
    
    // Nodes
    private var dinoNode: SCNNode!
    private var dinoBody: SCNNode!
    private var leftLeg: SCNNode!
    private var rightLeg: SCNNode!
    private var leftArm: SCNNode!
    private var rightArm: SCNNode!
    private var tailNode: SCNNode!
    private var headNode: SCNNode!
    private var shieldVisualNode: SCNNode?
    
    private var cameraNode: SCNNode!
    private var sunLightNode: SCNNode!
    
    // Physics Categories
    private struct Category {
        static let none: Int = 0
        static let dino: Int = 1 << 0
        static let ground: Int = 1 << 1
        static let obstacle: Int = 1 << 2
        static let coin: Int = 1 << 3
    }
    
    // Game Loop & State
    private(set) var isRunning: Bool = false
    private(set) var isGameOver: Bool = false
    private(set) var isGamePaused: Bool = false
    
    // Player Motion
    private var isGrounded: Bool = true
    private var isDucking: Bool = false
    private var verticalVelocity: Float = 0
    private let gravity: Float = -28.0
    private let jumpForce: Float = 11.5
    private let groundY: Float = 0.0
    
    // Stats
    private var score: Int = 0
    private var distance: Float = 0
    private var coinsCollected: Int = 0
    private var obstaclesCleared: Int = 0
    
    // Speed & Spawning
    private var baseSpeed: Float = 14.0
    private var currentSpeed: Float = 14.0
    private var lastObstacleSpawnTime: TimeInterval = 0
    private var spawnInterval: TimeInterval = 2.0
    
    // Active Spawns
    private var activeGroundSegments: [SCNNode] = []
    private var activeObstacles: [SCNNode] = []
    private var activeCoins: [SCNNode] = []
    private var activeClouds: [SCNNode] = []
    
    // Active Powerups
    var hasShield: Bool = false {
        didSet {
            updateShieldVisual()
        }
    }
    var hasMagnet: Bool = false
    
    // Skin colors
    var primaryColor: UIColor = UIColor(Color(hex: "#2ECC71"))
    var secondaryColor: UIColor = UIColor(Color(hex: "#27AE60"))
    
    override init() {
        super.init()
        setupScene()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Scene
    private func setupScene() {
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = SCNVector3(0, 0, 0) // We use custom deterministic kinematic physics
        
        setupLightingAndAtmosphere()
        setupCamera()
        setupGroundInfinite()
        setupDinoModel()
        setupClouds()
    }
    
    private func setupLightingAndAtmosphere() {
        // Sky background
        background.contents = UIColor(red: 0.94, green: 0.96, blue: 0.99, alpha: 1.0)
        
        // Sun Directional Light
        sunLightNode = SCNNode()
        let sun = SCNLight()
        sun.type = .directional
        sun.color = UIColor(white: 1.0, alpha: 1.0)
        sun.castsShadow = true
        sun.shadowMode = .deferred
        sun.shadowSampleCount = 4
        sun.shadowRadius = 3.0
        sun.shadowColor = UIColor.black.withAlphaComponent(0.3)
        sunLightNode.light = sun
        sunLightNode.position = SCNVector3(10, 20, 15)
        sunLightNode.eulerAngles = SCNVector3(-Float.pi / 3, Float.pi / 4, 0)
        rootNode.addChildNode(sunLightNode)
        
        // Ambient Warm Light
        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.color = UIColor(red: 0.7, green: 0.75, blue: 0.85, alpha: 1.0)
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        rootNode.addChildNode(ambientNode)
    }
    
    private func setupCamera() {
        cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.fieldOfView = 50
        camera.zNear = 0.5
        camera.zFar = 150
        cameraNode.camera = camera
        // Side-isometric view of the runner
        cameraNode.position = SCNVector3(8, 4.5, 12)
        cameraNode.eulerAngles = SCNVector3(-0.15, 0.55, 0)
        rootNode.addChildNode(cameraNode)
    }
    
    // MARK: - Infinite Ground Setup
    private func setupGroundInfinite() {
        let segmentLength: Float = 30.0
        for i in 0..<4 {
            let seg = createGroundSegment(length: segmentLength)
            seg.position = SCNVector3(0, groundY - 0.25, Float(i) * -segmentLength + 10)
            rootNode.addChildNode(seg)
            activeGroundSegments.append(seg)
        }
    }
    
    private func createGroundSegment(length: Float) -> SCNNode {
        let node = SCNNode()
        
        // Ground Box
        let box = SCNBox(width: 14.0, height: 0.5, length: CGFloat(length), chamferRadius: 0.1)
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor(red: 0.90, green: 0.82, blue: 0.68, alpha: 1.0) // Sand tone
        mat.roughness.contents = 0.9
        box.materials = [mat]
        let groundBox = SCNNode(geometry: box)
        groundBox.position = SCNVector3(0, 0, 0)
        node.addChildNode(groundBox)
        
        // Road / track lines
        let trackBox = SCNBox(width: 3.5, height: 0.52, length: CGFloat(length), chamferRadius: 0.05)
        let trackMat = SCNMaterial()
        trackMat.diffuse.contents = UIColor(red: 0.84, green: 0.74, blue: 0.58, alpha: 1.0)
        trackBox.materials = [trackMat]
        let trackNode = SCNNode(geometry: trackBox)
        node.addChildNode(trackNode)
        
        // Decorative low poly rocks on borders
        for _ in 0..<4 {
            let rock = SCNNode(geometry: SCNPyramid(width: CGFloat.random(in: 0.4...0.8), height: CGFloat.random(in: 0.3...0.7), length: CGFloat.random(in: 0.4...0.8)))
            let rockMat = SCNMaterial()
            rockMat.diffuse.contents = UIColor(red: 0.72, green: 0.65, blue: 0.55, alpha: 1.0)
            rock.geometry?.materials = [rockMat]
            let side: Float = Bool.random() ? -3.5 : 3.5
            let zPos = Float.random(in: -length/2...length/2)
            rock.position = SCNVector3(side + Float.random(in: -1.0...1.0), 0.25, zPos)
            rock.eulerAngles = SCNVector3(0, Float.random(in: 0...Float.pi), 0)
            node.addChildNode(rock)
        }
        
        return node
    }
    
    // MARK: - 3D Procedural Dinosaur Character Model (High Definition with Species Morphology)
    var currentSkin: DinoSkin = DinoSkin.catalog[0]
    
    func applySkin(primary: UIColor, secondary: UIColor) {
        self.primaryColor = primary
        self.secondaryColor = secondary
        dinoNode?.removeFromParentNode()
        setupDinoModel()
    }
    
    func applySkin(_ skin: DinoSkin) {
        self.currentSkin = skin
        self.primaryColor = skin.primaryUIColor
        self.secondaryColor = skin.secondaryUIColor
        dinoNode?.removeFromParentNode()
        setupDinoModel()
    }
    
    private func setupDinoModel() {
        let built = Dino3DBuilder.buildDino(for: currentSkin)
        dinoNode = built.rootNode
        dinoBody = built.bodyNode
        headNode = built.headNode
        tailNode = built.tailNode
        leftArm = built.leftArm
        rightArm = built.rightArm
        leftLeg = built.leftLeg
        rightLeg = built.rightLeg
        
        dinoNode.position = SCNVector3(0, groundY + 0.8, 0)
        rootNode.addChildNode(dinoNode)
    }
    
    // MARK: - Clouds
    private func setupClouds() {
        for _ in 0..<6 {
            let cloud = createCloud()
            cloud.position = SCNVector3(Float.random(in: -15...15), Float.random(in: 6...12), Float.random(in: -60...10))
            rootNode.addChildNode(cloud)
            activeClouds.append(cloud)
        }
    }
    
    private func createCloud() -> SCNNode {
        let cloud = SCNNode()
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor.white.withAlphaComponent(0.85)
        mat.roughness.contents = 1.0
        
        for _ in 0..<3 {
            let puff = SCNNode(geometry: SCNSphere(radius: CGFloat.random(in: 0.8...1.5)))
            puff.geometry?.materials = [mat]
            puff.position = SCNVector3(Float.random(in: -1...1), Float.random(in: -0.3...0.3), Float.random(in: -1...1))
            cloud.addChildNode(puff)
        }
        return cloud
    }
    
    // MARK: - Shield Visual
    private func updateShieldVisual() {
        shieldVisualNode?.removeFromParentNode()
        shieldVisualNode = nil
        
        if hasShield, let dino = dinoNode {
            let shieldGeo = SCNSphere(radius: 1.1)
            let mat = SCNMaterial()
            mat.diffuse.contents = UIColor.cyan.withAlphaComponent(0.35)
            mat.emission.contents = UIColor.cyan.withAlphaComponent(0.3)
            mat.isDoubleSided = true
            shieldGeo.materials = [mat]
            
            let sNode = SCNNode(geometry: shieldGeo)
            sNode.position = SCNVector3(0, 0.4, 0)
            dino.addChildNode(sNode)
            shieldVisualNode = sNode
            
            // Pulse animation
            let pulse = CABasicAnimation(keyPath: "scale")
            pulse.fromValue = SCNVector3(0.95, 0.95, 0.95)
            pulse.toValue = SCNVector3(1.05, 1.05, 1.05)
            pulse.duration = 0.8
            pulse.autoreverses = true
            pulse.repeatCount = .infinity
            sNode.addAnimation(pulse, forKey: "pulse")
        }
    }
    
    // MARK: - Game Lifecycle Controls
    func startGame() {
        resetGame()
        isRunning = true
        isGameOver = false
        isGamePaused = false
    }
    
    func pauseGame() {
        isGamePaused = true
    }
    
    func resumeGame() {
        isGamePaused = false
    }
    
    func resetGame() {
        isRunning = false
        isGameOver = false
        isGamePaused = false
        
        score = 0
        distance = 0
        coinsCollected = 0
        obstaclesCleared = 0
        currentSpeed = baseSpeed
        verticalVelocity = 0
        isGrounded = true
        isDucking = false
        lastObstacleSpawnTime = 0
        
        // Clean up spawned entities
        for o in activeObstacles { o.removeFromParentNode() }
        activeObstacles.removeAll()
        
        for c in activeCoins { c.removeFromParentNode() }
        activeCoins.removeAll()
        
        // Clear all animations & actions from previous run
        dinoNode?.removeAllAnimations()
        dinoNode?.removeAllActions()
        dinoBody?.removeAllAnimations()
        dinoBody?.removeAllActions()
        cameraNode?.removeAllActions()
        
        // Explicitly Reset Dino Pose and Position (Guarantees upright posture)
        dinoNode?.position = SCNVector3(0, groundY + 0.8, 0)
        dinoNode?.eulerAngles = SCNVector3(0, 0, 0)
        dinoNode?.rotation = SCNVector4(0, 0, 0, 0)
        dinoNode?.orientation = SCNQuaternion(0, 0, 0, 1)
        dinoNode?.scale = SCNVector3(1, 1, 1)
        
        dinoBody?.position = SCNVector3(0, 0.4, 0)
        dinoBody?.eulerAngles = SCNVector3(0.3, 0, 0)
        dinoBody?.scale = SCNVector3(1, 1, 1)
        
        leftLeg?.eulerAngles = SCNVector3(0, 0, 0)
        rightLeg?.eulerAngles = SCNVector3(0, 0, 0)
        leftArm?.eulerAngles = SCNVector3(0, 0, 0)
        rightArm?.eulerAngles = SCNVector3(0, 0, 0)
        tailNode?.eulerAngles = SCNVector3(0, 0, 0)
        
        cameraNode?.position = SCNVector3(8, 4.5, 12)
        cameraNode?.eulerAngles = SCNVector3(-0.15, 0.55, 0)
        
        updateShieldVisual()
        gameDelegate?.dinoDidUpdateScore(score, distance: Int(distance), coins: coinsCollected)
    }
    
    // MARK: - Input Actions
    func jump() {
        guard isRunning, !isGameOver, !isGamePaused else { return }
        if isGrounded {
            verticalVelocity = jumpForce
            isGrounded = false
            if isDucking { endDuck() }
            
            // Hop squash & stretch
            let stretch = CABasicAnimation(keyPath: "scale")
            stretch.fromValue = SCNVector3(0.8, 1.25, 0.8)
            stretch.toValue = SCNVector3(1.0, 1.0, 1.0)
            stretch.duration = 0.25
            dinoNode?.addAnimation(stretch, forKey: "stretch")
        }
    }
    
    func startDuck() {
        guard isRunning, !isGameOver, !isGamePaused else { return }
        isDucking = true
        // If in mid-air, fast dive to ground
        if !isGrounded {
            verticalVelocity = -jumpForce * 1.5
        }
        // Squash Dino model for crouching under flying obstacles
        dinoBody?.scale = SCNVector3(1.2, 0.5, 1.2)
        dinoBody?.position = SCNVector3(0, 0.15, 0)
        
        // SceneKit-managed timer: automatically returns to upright after 0.6s
        dinoBody?.removeAction(forKey: "duckTimer")
        let wait = SCNAction.wait(duration: 0.6)
        let unDuck = SCNAction.run { [weak self] _ in
            self?.endDuck()
        }
        dinoBody?.runAction(SCNAction.sequence([wait, unDuck]), forKey: "duckTimer")
    }
    
    func endDuck() {
        isDucking = false
        dinoBody?.removeAction(forKey: "duckTimer")
        dinoBody?.scale = SCNVector3(1.0, 1.0, 1.0)
        dinoBody?.position = SCNVector3(0, 0.4, 0)
    }
    
    // MARK: - Frame Update (Renderer Loop)
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard isRunning, !isGameOver, !isGamePaused else { return }
        
        let dt: Float = 1.0 / 60.0
        
        // 1. Distance & Score
        distance += currentSpeed * dt
        let newScore = Int(distance * 0.8)
        if newScore != score {
            score = newScore
            gameDelegate?.dinoDidUpdateScore(score, distance: Int(distance), coins: coinsCollected)
        }
        
        // Gradual speed acceleration
        currentSpeed = min(32.0, baseSpeed + (distance * 0.012))
        
        // 2. Physics & Dino Jump Movement
        if !isGrounded {
            verticalVelocity += gravity * dt
            var pos = dinoNode.position
            pos.y += verticalVelocity * dt
            
            if pos.y <= groundY + 0.8 {
                pos.y = groundY + 0.8
                verticalVelocity = 0
                isGrounded = true
            }
            dinoNode.position = pos
        }
        
        // 3. Multi-Joint Organic Running Locomotion Animation
        if isGrounded && !isDucking {
            let runCycle = sin(Float(time) * currentSpeed * 1.6)
            let cosCycle = cos(Float(time) * currentSpeed * 1.6)
            
            // Leg Swing & Knee Flex
            leftLeg?.eulerAngles.x = runCycle * 0.65
            rightLeg?.eulerAngles.x = -runCycle * 0.65
            
            // Arm Claws Counter-Swing
            leftArm?.eulerAngles.x = -runCycle * 0.45
            rightArm?.eulerAngles.x = runCycle * 0.45
            
            // Natural Running Torso Bob & Subtle Stride Tilt
            dinoBody?.position.y = 0.45 + abs(cosCycle) * 0.06
            dinoBody?.eulerAngles.z = runCycle * 0.04
            
            // Multi-Joint Serpentine Tail Wave
            tailNode?.eulerAngles.y = sin(Float(time) * 12.0) * 0.28
            headNode?.eulerAngles.x = abs(runCycle) * 0.05
        } else if !isGrounded {
            // Tuck legs gracefully in air
            leftLeg?.eulerAngles.x = 0.5
            rightLeg?.eulerAngles.x = 0.5
            tailNode?.eulerAngles.y = 0
            dinoBody?.eulerAngles.z = 0
        }
        
        // 4. Move Ground Segments
        let groundMove = currentSpeed * dt
        for seg in activeGroundSegments {
            seg.position.z += groundMove
            if seg.position.z > 20 {
                seg.position.z -= Float(activeGroundSegments.count) * 30.0
            }
        }
        
        // 5. Move Clouds
        for cloud in activeClouds {
            cloud.position.z += (currentSpeed * 0.3) * dt
            if cloud.position.z > 15 {
                cloud.position.z = -70
                cloud.position.x = Float.random(in: -15...15)
            }
        }
        
        // 6. Move Obstacles & Check Collisions
        var obstaclesToRemove: [SCNNode] = []
        let dinoPos = dinoNode.position
        let dinoHitBoxHeight: Float = isDucking ? 0.7 : 1.4
        
        for obstacle in activeObstacles {
            obstacle.position.z += currentSpeed * dt
            
            // Check if cleared
            if obstacle.position.z > 1.5 && obstacle.value(forKey: "cleared") as? Bool != true {
                obstacle.setValue(true, forKey: "cleared")
                obstaclesCleared += 1
            }
            
            // Collision Check with Dino
            let obsZ = obstacle.position.z
            let obsX = obstacle.position.x
            let obsY = obstacle.position.y
            let obsHeight = obstacle.value(forKey: "hitHeight") as? Float ?? 1.2
            
            let zDist = abs(dinoPos.z - obsZ)
            let xDist = abs(dinoPos.x - obsX)
            
            if zDist < 0.7 && xDist < 0.6 {
                // Check vertical bounds
                let obsBottom = obsY - (obsHeight / 2)
                let obsTop = obsY + (obsHeight / 2)
                let dinoBottom = dinoPos.y - 0.7
                let dinoTop = dinoBottom + dinoHitBoxHeight
                
                let isOverlapY = (dinoBottom < obsTop) && (dinoTop > obsBottom)
                
                if isOverlapY {
                    handleCollision(with: obstacle)
                }
            }
            
            if obstacle.position.z > 15 {
                obstaclesToRemove.append(obstacle)
            }
        }
        
        for obs in obstaclesToRemove {
            obs.removeFromParentNode()
            if let idx = activeObstacles.firstIndex(of: obs) {
                activeObstacles.remove(at: idx)
            }
        }
        
        // 7. Move Coins & Check Collection / Magnet
        var coinsToRemove: [SCNNode] = []
        for coin in activeCoins {
            coin.position.z += currentSpeed * dt
            coin.eulerAngles.y += Float.pi * dt * 2 // spin coin
            
            // Magnet pull
            if hasMagnet {
                let toDino = SCNVector3(dinoPos.x - coin.position.x, (dinoPos.y + 0.2) - coin.position.y, dinoPos.z - coin.position.z)
                let dist = sqrt(toDino.x * toDino.x + toDino.y * toDino.y + toDino.z * toDino.z)
                if dist < 6.0 {
                    coin.position.x += (toDino.x / dist) * 12.0 * dt
                    coin.position.y += (toDino.y / dist) * 12.0 * dt
                    coin.position.z += (toDino.z / dist) * 12.0 * dt
                }
            }
            
            // Pickup Distance
            let distToDino = SCNVector3(dinoPos.x - coin.position.x, dinoPos.y - coin.position.y, dinoPos.z - coin.position.z)
            let dist = sqrt(distToDino.x * distToDino.x + distToDino.y * distToDino.y + distToDino.z * distToDino.z)
            
            if dist < 1.2 {
                // Collect Coin
                coinsCollected += 1
                spawnCoinCollectParticles(at: coin.position)
                gameDelegate?.dinoDidCollectCoin()
                gameDelegate?.dinoDidUpdateScore(score, distance: Int(distance), coins: coinsCollected)
                coinsToRemove.append(coin)
            } else if coin.position.z > 15 {
                coinsToRemove.append(coin)
            }
        }
        
        for c in coinsToRemove {
            c.removeFromParentNode()
            if let idx = activeCoins.firstIndex(of: c) {
                activeCoins.remove(at: idx)
            }
        }
        
        // 8. Procedural Obstacle & Coin Spawner
        let spawnThreshold = max(0.9, spawnInterval - Double(distance * 0.0015))
        if time - lastObstacleSpawnTime > spawnThreshold {
            spawnRandomObstacleAndCoins()
            lastObstacleSpawnTime = time
        }
    }
    
    // MARK: - Collision Handler
    private func handleCollision(with obstacle: SCNNode) {
        shakeCamera()
        if hasShield {
            // Consume Shield safely
            hasShield = false
            spawnShieldBreakParticles(at: obstacle.position)
            obstacle.removeFromParentNode()
            if let idx = activeObstacles.firstIndex(of: obstacle) {
                activeObstacles.remove(at: idx)
            }
            gameDelegate?.dinoDidTriggerShieldBreak()
        } else {
            triggerGameOver()
        }
    }
    
    private func shakeCamera() {
        guard let camera = cameraNode else { return }
        let originalPos = SCNVector3(8, 4.5, 12)
        let shake1 = SCNAction.move(to: SCNVector3(originalPos.x + 0.35, originalPos.y - 0.25, originalPos.z), duration: 0.03)
        let shake2 = SCNAction.move(to: SCNVector3(originalPos.x - 0.35, originalPos.y + 0.25, originalPos.z), duration: 0.03)
        let shake3 = SCNAction.move(to: SCNVector3(originalPos.x + 0.2, originalPos.y - 0.1, originalPos.z), duration: 0.03)
        let reset = SCNAction.move(to: originalPos, duration: 0.03)
        camera.runAction(SCNAction.sequence([shake1, shake2, shake3, reset]))
    }
    
    private func triggerGameOver() {
        guard !isGameOver else { return }
        isGameOver = true
        isRunning = false
        shakeCamera()
        
        // Death tumble animation
        let tumble = CABasicAnimation(keyPath: "rotation")
        tumble.fromValue = SCNVector4(0, 0, 0, 0)
        tumble.toValue = SCNVector4(0, 0, 1, Float.pi / 2)
        tumble.duration = 0.4
        tumble.fillMode = .forwards
        tumble.isRemovedOnCompletion = false
        dinoNode?.addAnimation(tumble, forKey: "tumble")
        
        spawnCrashParticles(at: dinoNode.position)
        
        gameDelegate?.dinoDidGameOver(
            score: score,
            distance: Int(distance),
            coins: coinsCollected,
            obstaclesCleared: obstaclesCleared
        )
    }
    
    // MARK: - Spawning System
    private func spawnRandomObstacleAndCoins() {
        let spawnZ: Float = -50.0
        let obstacleType = Int.random(in: 0...3)
        
        switch obstacleType {
        case 0:
            // Single Cactus
            let cactus = createCactus(tall: false)
            cactus.position = SCNVector3(0, groundY + 0.6, spawnZ)
            cactus.setValue(Float(1.2), forKey: "hitHeight")
            rootNode.addChildNode(cactus)
            activeObstacles.append(cactus)
            
            // Spawn Coin Arc over the cactus
            spawnCoinArc(startZ: spawnZ - 4.0)
            
        case 1:
            // Triple / Cluster Cactus
            let cluster = createCactusCluster()
            cluster.position = SCNVector3(0, groundY + 0.75, spawnZ)
            cluster.setValue(Float(1.5), forKey: "hitHeight")
            rootNode.addChildNode(cluster)
            activeObstacles.append(cluster)
            
            spawnCoinArc(startZ: spawnZ - 5.0)
            
        case 2:
            // Flying Pterodactyl (High or Low)
            let isHigh = Bool.random()
            let ptero = createPterodactyl()
            let yPos: Float = isHigh ? groundY + 2.2 : groundY + 1.2
            ptero.position = SCNVector3(0, yPos, spawnZ)
            ptero.setValue(Float(0.8), forKey: "hitHeight")
            rootNode.addChildNode(ptero)
            activeObstacles.append(ptero)
            
            // If flying high, spawn coins on the ground beneath for ducking reward!
            if isHigh {
                spawnCoinsRow(zPos: spawnZ, yPos: groundY + 0.5)
            }
            
        default:
            // Tall Rock / Obelisk
            let rock = createObelisk()
            rock.position = SCNVector3(0, groundY + 0.8, spawnZ)
            rock.setValue(Float(1.6), forKey: "hitHeight")
            rootNode.addChildNode(rock)
            activeObstacles.append(rock)
            
            spawnCoinArc(startZ: spawnZ - 4.0)
        }
    }
    
    // MARK: - 3D Obstacle Geometries
    private func createCactus(tall: Bool) -> SCNNode {
        let node = SCNNode()
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor(red: 0.18, green: 0.55, blue: 0.34, alpha: 1.0)
        
        let height: Float = tall ? 1.5 : 1.1
        let trunk = SCNNode(geometry: SCNCylinder(radius: 0.18, height: CGFloat(height)))
        trunk.geometry?.materials = [mat]
        node.addChildNode(trunk)
        
        // Arms
        let armGeo = SCNCapsule(capRadius: 0.1, height: 0.4)
        armGeo.materials = [mat]
        
        let leftArm = SCNNode(geometry: armGeo)
        leftArm.position = SCNVector3(-0.25, 0.15, 0)
        leftArm.eulerAngles = SCNVector3(0, 0, 0.4)
        node.addChildNode(leftArm)
        
        let rightArm = SCNNode(geometry: armGeo)
        rightArm.position = SCNVector3(0.25, -0.05, 0)
        rightArm.eulerAngles = SCNVector3(0, 0, -0.4)
        node.addChildNode(rightArm)
        
        return node
    }
    
    private func createCactusCluster() -> SCNNode {
        let cluster = SCNNode()
        let c1 = createCactus(tall: false)
        c1.position = SCNVector3(-0.35, 0, 0)
        
        let c2 = createCactus(tall: true)
        c2.position = SCNVector3(0, 0.15, -0.2)
        
        let c3 = createCactus(tall: false)
        c3.position = SCNVector3(0.35, -0.05, 0.1)
        
        cluster.addChildNode(c1)
        cluster.addChildNode(c2)
        cluster.addChildNode(c3)
        return cluster
    }
    
    private func createPterodactyl() -> SCNNode {
        let ptero = SCNNode()
        let bodyMat = SCNMaterial()
        bodyMat.diffuse.contents = UIColor(red: 0.75, green: 0.25, blue: 0.25, alpha: 1.0)
        
        // Body & Beak
        let body = SCNNode(geometry: SCNCone(topRadius: 0.02, bottomRadius: 0.2, height: 0.9))
        body.geometry?.materials = [bodyMat]
        body.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        ptero.addChildNode(body)
        
        // Flapping Wings
        let wingMat = SCNMaterial()
        wingMat.diffuse.contents = UIColor(red: 0.85, green: 0.35, blue: 0.35, alpha: 1.0)
        
        for isLeft in [true, false] {
            let wing = SCNNode(geometry: SCNBox(width: 0.8, height: 0.04, length: 0.4, chamferRadius: 0.02))
            wing.geometry?.materials = [wingMat]
            wing.position = SCNVector3(isLeft ? -0.45 : 0.45, 0, 0)
            
            // Flap animation
            let flap = CABasicAnimation(keyPath: "eulerAngles.z")
            flap.fromValue = isLeft ? -0.4 : 0.4
            flap.toValue = isLeft ? 0.4 : -0.4
            flap.duration = 0.2
            flap.autoreverses = true
            flap.repeatCount = .infinity
            wing.addAnimation(flap, forKey: "flap")
            
            ptero.addChildNode(wing)
        }
        
        return ptero
    }
    
    private func createObelisk() -> SCNNode {
        let node = SCNNode()
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor(red: 0.45, green: 0.40, blue: 0.38, alpha: 1.0)
        let pyramid = SCNNode(geometry: SCNPyramid(width: 0.9, height: 1.6, length: 0.9))
        pyramid.geometry?.materials = [mat]
        node.addChildNode(pyramid)
        return node
    }
    
    // MARK: - Coin Creation & Spawners
    private func createCoinNode() -> SCNNode {
        let node = SCNNode()
        let coinGeo = SCNCylinder(radius: 0.24, height: 0.08)
        let goldMat = SCNMaterial()
        goldMat.diffuse.contents = UIColor(red: 1.0, green: 0.82, blue: 0.1, alpha: 1.0)
        goldMat.metalness.contents = 0.8
        goldMat.roughness.contents = 0.2
        coinGeo.materials = [goldMat]
        
        let mesh = SCNNode(geometry: coinGeo)
        mesh.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        node.addChildNode(mesh)
        return node
    }
    
    private func spawnCoinArc(startZ: Float) {
        for i in 0..<4 {
            let coin = createCoinNode()
            let normalized = Float(i) / 3.0
            let arcHeight = sin(normalized * Float.pi) * 1.8 + 1.2
            coin.position = SCNVector3(0, groundY + arcHeight, startZ - Float(i) * 2.2)
            rootNode.addChildNode(coin)
            activeCoins.append(coin)
        }
    }
    
    private func spawnCoinsRow(zPos: Float, yPos: Float) {
        for i in 0..<3 {
            let coin = createCoinNode()
            coin.position = SCNVector3(0, yPos, zPos - Float(i) * 2.0)
            rootNode.addChildNode(coin)
            activeCoins.append(coin)
        }
    }
    
    // MARK: - Visual Particles
    private func spawnCoinCollectParticles(at position: SCNVector3) {
        let particleNode = SCNNode()
        particleNode.position = position
        
        let particleSystem = SCNParticleSystem()
        particleSystem.birthRate = 60
        particleSystem.particleLifeSpan = 0.4
        particleSystem.emissionDuration = 0.1
        particleSystem.particleColor = UIColor.yellow
        particleSystem.particleSize = 0.08
        particleSystem.spreadingAngle = 180
        particleSystem.particleVelocity = 4.0
        
        particleNode.addParticleSystem(particleSystem)
        rootNode.addChildNode(particleNode)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            particleNode.removeFromParentNode()
        }
    }
    
    private func spawnCrashParticles(at position: SCNVector3) {
        let particleNode = SCNNode()
        particleNode.position = position
        
        let particleSystem = SCNParticleSystem()
        particleSystem.birthRate = 120
        particleSystem.particleLifeSpan = 0.6
        particleSystem.emissionDuration = 0.15
        particleSystem.particleColor = UIColor.orange
        particleSystem.particleSize = 0.12
        particleSystem.spreadingAngle = 180
        particleSystem.particleVelocity = 6.0
        
        particleNode.addParticleSystem(particleSystem)
        rootNode.addChildNode(particleNode)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            particleNode.removeFromParentNode()
        }
    }
    
    private func spawnShieldBreakParticles(at position: SCNVector3) {
        let particleNode = SCNNode()
        particleNode.position = position
        
        let particleSystem = SCNParticleSystem()
        particleSystem.birthRate = 100
        particleSystem.particleLifeSpan = 0.5
        particleSystem.emissionDuration = 0.1
        particleSystem.particleColor = UIColor.cyan
        particleSystem.particleSize = 0.1
        particleSystem.spreadingAngle = 180
        particleSystem.particleVelocity = 5.0
        
        particleNode.addParticleSystem(particleSystem)
        rootNode.addChildNode(particleNode)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            particleNode.removeFromParentNode()
        }
    }
}
