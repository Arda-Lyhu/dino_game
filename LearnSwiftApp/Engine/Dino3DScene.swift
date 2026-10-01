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
    
    // Player Motion & 3-Lane System (Temple Run Style)
    private var isGrounded: Bool = true
    private var isDucking: Bool = false
    private var verticalVelocity: Float = 0
    private let gravity: Float = -28.0
    private let jumpForce: Float = 11.5
    private let groundY: Float = 0.0
    
    private let lanePositions: [Float] = [-1.5, 0.0, 1.5]
    private var currentLaneIndex: Int = 1 // 0: Left, 1: Center, 2: Right
    private var currentDinoX: Float = 0.0
    private var targetDinoX: Float = 0.0
    // Dedicated bank angle accumulator – smoothly drives toward target, never derived from position residual
    private var currentBankAngle: Float = 0.0
    private var targetBankAngle: Float = 0.0
    // Stable camera X (exponential decay, frame-rate independent)
    private var cameraCurrentX: Float = 0.0
    
    // Stats
    private var score: Int = 0
    private var distance: Float = 0
    private var coinsCollected: Int = 0
    private var obstaclesCleared: Int = 0
    
    // Speed & Spawning
    private var baseSpeed: Float = 14.0
    private var currentSpeed: Float = 14.0
    private var lastObstacleSpawnTime: TimeInterval = 0
    private var lastFrameTime: TimeInterval = 0
    private var spawnInterval: TimeInterval = 2.0
    private var runPhase: Float = 0.0
    private var tailPhase: Float = 0.0
    private var lastReportedDistance: Int = -1
    
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
        self.physicsWorld.gravity = SCNVector3(0, 0, 0)
        
        setupLightingAndAtmosphere()
        setupCamera()
        setupGroundInfinite()
        setupDinoModel()
        setupClouds()
    }
    
    private func setupLightingAndAtmosphere() {
        // Sky background gradient tone
        background.contents = UIColor(red: 0.88, green: 0.93, blue: 0.98, alpha: 1.0)
        
        // Sun Directional Light
        sunLightNode = SCNNode()
        let sun = SCNLight()
        sun.type = .directional
        sun.color = UIColor(white: 1.0, alpha: 1.0)
        sun.castsShadow = true
        sun.shadowMode = .deferred
        sun.shadowSampleCount = 4
        sun.shadowRadius = 3.0
        sun.shadowColor = UIColor.black.withAlphaComponent(0.28)
        sunLightNode.light = sun
        sunLightNode.position = SCNVector3(6, 18, 12)
        sunLightNode.eulerAngles = SCNVector3(-Float.pi / 3, Float.pi / 6, 0)
        rootNode.addChildNode(sunLightNode)
        
        // Ambient Light
        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.color = UIColor(red: 0.75, green: 0.80, blue: 0.90, alpha: 1.0)
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        rootNode.addChildNode(ambientNode)
    }
    
    private func setupCamera() {
        cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.fieldOfView = 58
        camera.zNear = 0.5
        camera.zFar = 160
        cameraNode.camera = camera
        
        // Dynamic Temple Run 3rd Person Over-the-Shoulder Chase Camera
        cameraNode.position = SCNVector3(0, groundY + 4.2, 7.2)
        cameraNode.eulerAngles = SCNVector3(-0.28, 0, 0)
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
        
        // Ground Sand Bed
        let box = SCNBox(width: 16.0, height: 0.5, length: CGFloat(length), chamferRadius: 0.1)
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor(red: 0.90, green: 0.82, blue: 0.68, alpha: 1.0)
        mat.roughness.contents = 0.9
        box.materials = [mat]
        let groundBox = SCNNode(geometry: box)
        groundBox.position = SCNVector3(0, 0, 0)
        node.addChildNode(groundBox)
        
        // 3-Lane Running Highway Track
        let trackBox = SCNBox(width: 5.6, height: 0.52, length: CGFloat(length), chamferRadius: 0.05)
        let trackMat = SCNMaterial()
        trackMat.diffuse.contents = UIColor(red: 0.82, green: 0.73, blue: 0.58, alpha: 1.0) // Ancient stone path
        trackBox.materials = [trackMat]
        let trackNode = SCNNode(geometry: trackBox)
        node.addChildNode(trackNode)
        
        // 3-Lane Dividers (Left/Center divider and Center/Right divider)
        for dividerX in [-0.75 as Float, 0.75 as Float] {
            let lineGeo = SCNBox(width: 0.06, height: 0.53, length: CGFloat(length), chamferRadius: 0.02)
            let lineMat = SCNMaterial()
            lineMat.diffuse.contents = UIColor(red: 0.70, green: 0.60, blue: 0.48, alpha: 0.6)
            lineGeo.materials = [lineMat]
            let lineNode = SCNNode(geometry: lineGeo)
            lineNode.position = SCNVector3(dividerX, 0, 0)
            node.addChildNode(lineNode)
        }
        
        // Decorative low poly rocks on borders
        for _ in 0..<4 {
            let rock = SCNNode(geometry: SCNPyramid(width: CGFloat.random(in: 0.4...0.8), height: CGFloat.random(in: 0.3...0.7), length: CGFloat.random(in: 0.4...0.8)))
            let rockMat = SCNMaterial()
            rockMat.diffuse.contents = UIColor(red: 0.68, green: 0.60, blue: 0.50, alpha: 1.0)
            rock.geometry?.materials = [rockMat]
            let side: Float = Bool.random() ? -3.8 : 3.8
            let zPos = Float.random(in: -length/2...length/2)
            rock.position = SCNVector3(side + Float.random(in: -0.8...0.8), 0.25, zPos)
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
            cloud.position = SCNVector3(Float.random(in: -18...18), Float.random(in: 7...13), Float.random(in: -60...10))
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
        lastFrameTime = 0
        
        // Reset 3-Lane state
        currentLaneIndex = 1
        currentDinoX = 0.0
        targetDinoX = 0.0
        runPhase = 0.0
        tailPhase = 0.0
        lastReportedDistance = -1
        
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
        
        // Explicitly Reset Dino Pose and Position
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
        
        currentBankAngle = 0.0
        targetBankAngle = 0.0
        cameraCurrentX = 0.0
        
        cameraNode?.position = SCNVector3(0, groundY + 4.2, 7.2)
        cameraNode?.eulerAngles = SCNVector3(-0.28, 0, 0)
        
        updateShieldVisual()
        gameDelegate?.dinoDidUpdateScore(score, distance: Int(distance), coins: coinsCollected)
    }
    
    // MARK: - Temple Run 3-Lane & Acrobatics Input Actions
    func moveLeft() {
        guard isRunning, !isGameOver, !isGamePaused else { return }
        if currentLaneIndex > 0 {
            currentLaneIndex -= 1
            targetDinoX = lanePositions[currentLaneIndex]
            targetBankAngle = 0.28   // Lean into the left turn, then returns to 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { [weak self] in
                self?.targetBankAngle = 0.0
            }
        }
    }
    
    func moveRight() {
        guard isRunning, !isGameOver, !isGamePaused else { return }
        if currentLaneIndex < lanePositions.count - 1 {
            currentLaneIndex += 1
            targetDinoX = lanePositions[currentLaneIndex]
            targetBankAngle = -0.28  // Lean into the right turn, then returns to 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { [weak self] in
                self?.targetBankAngle = 0.0
            }
        }
    }
    
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
        
        let dt: Float = Float(lastFrameTime == 0 ? 1.0 / 60.0 : min(1.0 / 30.0, time - lastFrameTime))
        lastFrameTime = time
        
        // 1. Distance & Score
        distance += currentSpeed * dt
        let newScore = Int(distance * 0.8)
        let curDist = Int(distance)
        if newScore != score || curDist != lastReportedDistance {
            score = newScore
            lastReportedDistance = curDist
            gameDelegate?.dinoDidUpdateScore(score, distance: curDist, coins: coinsCollected)
        }
        
        // Gradual speed acceleration
        currentSpeed = min(30.0, baseSpeed + (distance * 0.010))
        
        // 2. 3-Lane Lateral Position Interpolation (snap when close enough to avoid overshooting)
        let diffX = targetDinoX - currentDinoX
        if abs(diffX) < 0.004 {
            currentDinoX = targetDinoX
        } else {
            currentDinoX += diffX * min(1.0, 14.0 * dt)
        }
        
        // Bank angle lives on its own smooth track – never computed from position residual
        // This prevents tilt from oscillating as position settles
        let bankDiff = targetBankAngle - currentBankAngle
        if abs(bankDiff) < 0.001 {
            currentBankAngle = targetBankAngle
        } else {
            currentBankAngle += bankDiff * min(1.0, 10.0 * dt)
        }
        
        // 3. Vertical Physics (Jump / Fall)
        if !isGrounded {
            verticalVelocity += gravity * dt
            var pos = dinoNode.position
            pos.y += verticalVelocity * dt
            
            if pos.y <= groundY + 0.8 {
                pos.y = groundY + 0.8
                verticalVelocity = 0
                isGrounded = true
            }
            pos.x = currentDinoX
            dinoNode.position = pos
        } else {
            dinoNode.position.x = currentDinoX
        }
        
        // Apply bank tilt to root node only – child nodes must NOT also write eulerAngles.z
        dinoNode.eulerAngles = SCNVector3(0, 0, currentBankAngle)
        
        // Frame-rate independent camera X (exponential smoothing constant = 10 rad/s)
        let camAlpha: Float = 1.0 - exp(-10.0 * dt)
        let cameraTargetX = currentDinoX * 0.45
        cameraCurrentX += (cameraTargetX - cameraCurrentX) * camAlpha
        let jumpOffsetY = max(0, (dinoNode.position.y - (groundY + 0.8))) * 0.25
        cameraNode.position.x = cameraCurrentX
        cameraNode.position.y = (groundY + 4.2) + jumpOffsetY
        cameraNode.eulerAngles.z = currentBankAngle * 0.12
        
        // 4. Smooth Phase-Accumulated Locomotion Animation (Silky smooth at all speeds)
        if isGrounded && !isDucking {
            runPhase += currentSpeed * dt * 1.3
            tailPhase += dt * 7.5
            
            let runCycle = sin(runPhase)
            let cosCycle = cos(runPhase)
            
            // Leg Swing & Knee Flex
            leftLeg?.eulerAngles.x = runCycle * 0.58
            rightLeg?.eulerAngles.x = -runCycle * 0.58
            
            // Arm Claws Counter-Swing
            leftArm?.eulerAngles.x = -runCycle * 0.38
            rightArm?.eulerAngles.x = runCycle * 0.38
            
            // Torso Bob – only Y position, NOT Z rotation (parent node owns all Z banking)
            dinoBody?.position.y = 0.42 + abs(cosCycle) * 0.035
            dinoBody?.eulerAngles = SCNVector3(0.3, 0, 0) // reset each frame, no Z sway here
            
            // Natural Tail Sway & Head Rhythm
            tailNode?.eulerAngles.y = sin(tailPhase) * 0.20
            headNode?.eulerAngles.x = abs(runCycle) * 0.035
        } else if !isGrounded {
            leftLeg?.eulerAngles.x = 0.4
            rightLeg?.eulerAngles.x = 0.4
            tailNode?.eulerAngles.y = 0
            dinoBody?.eulerAngles = SCNVector3(0.3, 0, 0)
        }
        
        // 5. Move Ground Segments
        let groundMove = currentSpeed * dt
        for seg in activeGroundSegments {
            seg.position.z += groundMove
            if seg.position.z > 20 {
                seg.position.z -= Float(activeGroundSegments.count) * 30.0
            }
        }
        
        // 6. Move Clouds
        for cloud in activeClouds {
            cloud.position.z += (currentSpeed * 0.3) * dt
            if cloud.position.z > 15 {
                cloud.position.z = -70
                cloud.position.x = Float.random(in: -18...18)
            }
        }
        
        // 7. Move Obstacles & Check Collisions
        var obstaclesToRemove: [SCNNode] = []
        let dinoPos = dinoNode.position
        let dinoHitBoxHeight: Float = isDucking ? 0.7 : 1.4
        
        for obstacle in activeObstacles {
            obstacle.position.z += currentSpeed * dt
            
            if obstacle.position.z > 1.5 && obstacle.value(forKey: "cleared") as? Bool != true {
                obstacle.setValue(true, forKey: "cleared")
                obstaclesCleared += 1
            }
            
            // Collision Check with Dino (3-lane xDist and zDist precision)
            let obsZ = obstacle.position.z
            let obsX = obstacle.position.x
            let obsY = obstacle.position.y
            let obsHeight = obstacle.value(forKey: "hitHeight") as? Float ?? 1.2
            
            let zDist = abs(dinoPos.z - obsZ)
            let xDist = abs(dinoPos.x - obsX)
            
            if zDist < 0.65 && xDist < 0.65 {
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
        
        // 8. Move Coins & Check Collection / Magnet
        var coinsToRemove: [SCNNode] = []
        for coin in activeCoins {
            coin.position.z += currentSpeed * dt
            coin.eulerAngles.y += Float.pi * dt * 2
            
            // Magnet pull
            if hasMagnet {
                let toDino = SCNVector3(dinoPos.x - coin.position.x, (dinoPos.y + 0.2) - coin.position.y, dinoPos.z - coin.position.z)
                let dist = sqrt(toDino.x * toDino.x + toDino.y * toDino.y + toDino.z * toDino.z)
                if dist < 6.5 {
                    coin.position.x += (toDino.x / dist) * 14.0 * dt
                    coin.position.y += (toDino.y / dist) * 14.0 * dt
                    coin.position.z += (toDino.z / dist) * 14.0 * dt
                }
            }
            
            let distToDino = SCNVector3(dinoPos.x - coin.position.x, dinoPos.y - coin.position.y, dinoPos.z - coin.position.z)
            let dist = sqrt(distToDino.x * distToDino.x + distToDino.y * distToDino.y + distToDino.z * distToDino.z)
            
            if dist < 1.15 {
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
        
        // 9. Multi-Lane Procedural Obstacle & Coin Spawner
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
        let originalPos = SCNVector3(currentDinoX * 0.45, groundY + 3.5, 6.2)
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
    
    // MARK: - Multi-Lane Spawning System
    private func spawnRandomObstacleAndCoins() {
        let spawnZ: Float = -50.0
        let patternType = Int.random(in: 0...4)
        
        switch patternType {
        case 0:
            // Single Lane Cactus + Coin Arc on that lane
            let laneX = lanePositions.randomElement()!
            let cactus = createCactus(tall: false)
            cactus.position = SCNVector3(laneX, groundY + 0.6, spawnZ)
            cactus.setValue(Float(1.2), forKey: "hitHeight")
            rootNode.addChildNode(cactus)
            activeObstacles.append(cactus)
            
            spawnCoinArc(laneX: laneX, startZ: spawnZ - 4.0)
            
        case 1:
            // 2-Lane Trap: Block 2 lanes, leaving 1 open escape lane!
            let openLaneIndex = Int.random(in: 0..<lanePositions.count)
            for (idx, laneX) in lanePositions.enumerated() {
                if idx != openLaneIndex {
                    let cluster = createCactusCluster()
                    cluster.position = SCNVector3(laneX, groundY + 0.75, spawnZ)
                    cluster.setValue(Float(1.5), forKey: "hitHeight")
                    rootNode.addChildNode(cluster)
                    activeObstacles.append(cluster)
                }
            }
            // Reward the player with a coin trail through the open lane!
            spawnCoinsRow(laneX: lanePositions[openLaneIndex], zPos: spawnZ, yPos: groundY + 0.6)
            
        case 2:
            // Flying Pterodactyl in a random lane
            let laneX = lanePositions.randomElement()!
            let isHigh = Bool.random()
            let ptero = createPterodactyl()
            let yPos: Float = isHigh ? groundY + 2.1 : groundY + 1.2
            ptero.position = SCNVector3(laneX, yPos, spawnZ)
            ptero.setValue(Float(0.8), forKey: "hitHeight")
            rootNode.addChildNode(ptero)
            activeObstacles.append(ptero)
            
            if isHigh {
                spawnCoinsRow(laneX: laneX, zPos: spawnZ, yPos: groundY + 0.5)
            } else {
                spawnCoinArc(laneX: laneX, startZ: spawnZ - 4.0)
            }
            
        case 3:
            // Center Obelisk + Side Coins
            let rock = createObelisk()
            rock.position = SCNVector3(0, groundY + 0.8, spawnZ)
            rock.setValue(Float(1.6), forKey: "hitHeight")
            rootNode.addChildNode(rock)
            activeObstacles.append(rock)
            
            let rewardLane = Bool.random() ? lanePositions[0] : lanePositions[2]
            spawnCoinsRow(laneX: rewardLane, zPos: spawnZ, yPos: groundY + 0.6)
            
        default:
            // Sweeping Coin Path across all 3 lanes
            spawnDiagonalCoinPath(startZ: spawnZ)
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
        
        let body = SCNNode(geometry: SCNCone(topRadius: 0.02, bottomRadius: 0.2, height: 0.9))
        body.geometry?.materials = [bodyMat]
        body.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        ptero.addChildNode(body)
        
        let wingMat = SCNMaterial()
        wingMat.diffuse.contents = UIColor(red: 0.85, green: 0.35, blue: 0.35, alpha: 1.0)
        
        for isLeft in [true, false] {
            let wing = SCNNode(geometry: SCNBox(width: 0.8, height: 0.04, length: 0.4, chamferRadius: 0.02))
            wing.geometry?.materials = [wingMat]
            wing.position = SCNVector3(isLeft ? -0.45 : 0.45, 0, 0)
            
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
    
    // MARK: - Coin Creation & Multi-Lane Spawners
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
    
    private func spawnCoinArc(laneX: Float, startZ: Float) {
        for i in 0..<4 {
            let coin = createCoinNode()
            let normalized = Float(i) / 3.0
            let arcHeight = sin(normalized * Float.pi) * 1.8 + 1.2
            coin.position = SCNVector3(laneX, groundY + arcHeight, startZ - Float(i) * 2.2)
            rootNode.addChildNode(coin)
            activeCoins.append(coin)
        }
    }
    
    private func spawnCoinsRow(laneX: Float, zPos: Float, yPos: Float) {
        for i in 0..<3 {
            let coin = createCoinNode()
            coin.position = SCNVector3(laneX, yPos, zPos - Float(i) * 2.0)
            rootNode.addChildNode(coin)
            activeCoins.append(coin)
        }
    }
    
    private func spawnDiagonalCoinPath(startZ: Float) {
        for (i, laneX) in lanePositions.enumerated() {
            let coin = createCoinNode()
            coin.position = SCNVector3(laneX, groundY + 0.6, startZ - Float(i) * 2.5)
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
