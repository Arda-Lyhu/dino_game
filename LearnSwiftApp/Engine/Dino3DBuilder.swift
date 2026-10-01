import SceneKit
import SwiftUI
import UIKit

/// High-detail procedural 3D Dinosaur model generator supporting completely distinct 3D body models:
/// - Tyrannosaurus Rex (Bipedal Apex Predator)
/// - Triceratops (Quadrupedal Tank with 3 horns & massive neck frill)
/// - Brachiosaurus (Long-Neck Sauropod Titan)
/// - Ankylosaurus (Armored Tank with Heavy Bone Club-Tail)
/// - Spinosaurus (Elongated Croc Snout & Glowing Sail Fin)
/// - Stegosaurus (4-Legged Plate Behemoth & Thagomizer Spikes)
/// - Pterodactyl (Aerodynamic Flyer with 1.5m Wings & Spear Beak)
/// - Cyber Mech-Bot (Futuristic Robotic Walker with Missile Cannons & Jet Turbines)
/// - Velociraptor (Sleek Agile Hunter with Giant Sickle Claws)
/// - Glacial Wyrm (Sub-Zero Crystal Ice Dragon)
/// - Golden Emperor (24K Gold Mythic with Royal Crown)
final class Dino3DBuilder {

    struct DinoNodes {
        let rootNode: SCNNode
        let bodyNode: SCNNode
        let headNode: SCNNode
        let neckNode: SCNNode
        let tailNode: SCNNode
        let leftArm: SCNNode
        let rightArm: SCNNode
        let leftLeg: SCNNode
        let rightLeg: SCNNode
    }

    static func buildDino(for skin: DinoSkin, isPreview: Bool = false) -> DinoNodes {
        switch skin.species {
        case .triceratops:
            return buildTriceratops(skin: skin)
        case .brachio:
            return buildBrachiosaurus(skin: skin)
        case .ankylosaurus:
            return buildAnkylosaurus(skin: skin)
        case .pterodactyl:
            return buildPterodactyl(skin: skin)
        case .mecha:
            return buildCyberMecha(skin: skin)
        case .spinosaurus:
            return buildSpinosaurus(skin: skin)
        case .stegosaurus:
            return buildStegosaurus(skin: skin)
        case .raptor:
            return buildRaptor(skin: skin)
        case .frost:
            return buildFrostWyrm(skin: skin)
        case .gold:
            return buildGoldenEmperor(skin: skin)
        case .trex:
            return buildTRex(skin: skin)
        }
    }

    // MARK: - 1. TRICERATOPS (Quadrupedal Heavy Tank Chassis)
    private static func buildTriceratops(skin: DinoSkin) -> DinoNodes {
        let root = SCNNode()
        let mat1 = makeMat(color: skin.primaryUIColor)
        let mat2 = makeMat(color: skin.secondaryUIColor)
        let boneMat = makeBoneMat()

        // Horizontal Barrel Body
        let bodyGeo = SCNCapsule(capRadius: 0.54, height: 1.4)
        bodyGeo.materials = [mat1]
        let body = SCNNode(geometry: bodyGeo)
        body.position = SCNVector3(0, 0.45, 0)
        body.eulerAngles = SCNVector3(Float.pi / 2 - 0.1, 0, 0)
        root.addChildNode(body)

        // Heavy Armor Ridge
        let ridge = SCNNode(geometry: SCNCapsule(capRadius: 0.38, height: 1.1))
        ridge.geometry?.materials = [mat2]
        ridge.position = SCNVector3(0, 0.22, 0)
        body.addChildNode(ridge)

        // Neck & Low Head
        let neck = SCNNode(geometry: SCNCylinder(radius: 0.38, height: 0.4))
        neck.geometry?.materials = [mat1]
        neck.position = SCNVector3(0, 0.45, -0.6)
        neck.eulerAngles = SCNVector3(0.2, 0, 0)
        root.addChildNode(neck)

        let head = SCNNode()
        head.position = SCNVector3(0, 0.2, -0.25)
        neck.addChildNode(head)

        // Stout Snout & Beak
        let snout = SCNNode(
            geometry: SCNBox(width: 0.58, height: 0.45, length: 0.75, chamferRadius: 0.1))
        snout.geometry?.materials = [mat1]
        snout.position = SCNVector3(0, 0, -0.25)
        head.addChildNode(snout)

        // Giant Flared Protective Frill (Shield)
        let frill = SCNNode(geometry: SCNCylinder(radius: 0.85, height: 0.09))
        frill.geometry?.materials = [mat2]
        frill.position = SCNVector3(0, 0.35, 0.15)
        frill.eulerAngles = SCNVector3(-0.45, 0, 0)
        frill.scale = SCNVector3(1.15, 0.4, 1.4)
        head.addChildNode(frill)

        // Frill Rim Bone Studs
        for a in 0..<9 {
            let angle = (Float(a) - 4.0) * 0.32
            let stud = SCNNode(geometry: SCNCone(topRadius: 0, bottomRadius: 0.05, height: 0.18))
            stud.geometry?.materials = [boneMat]
            stud.position = SCNVector3(sin(angle) * 0.88, cos(angle) * 0.88, 0)
            stud.eulerAngles = SCNVector3(0, 0, -angle)
            frill.addChildNode(stud)
        }

        // 2 Massive Brow Horns (0.65m long)
        for isLeft in [true, false] {
            let horn = SCNNode(geometry: SCNCone(topRadius: 0.01, bottomRadius: 0.08, height: 0.65))
            horn.geometry?.materials = [boneMat]
            horn.position = SCNVector3(isLeft ? -0.26 : 0.26, 0.45, -0.32)
            horn.eulerAngles = SCNVector3(-0.7, 0, isLeft ? -0.2 : 0.2)
            head.addChildNode(horn)

            // Eyes
            let eye = makeEye(isLeft: isLeft, mat2: mat2)
            eye.position = SCNVector3(isLeft ? -0.32 : 0.32, 0.1, -0.2)
            head.addChildNode(eye)
        }

        // Nose Horn
        let nHorn = SCNNode(geometry: SCNCone(topRadius: 0, bottomRadius: 0.07, height: 0.35))
        nHorn.geometry?.materials = [boneMat]
        nHorn.position = SCNVector3(0, 0.28, -0.6)
        nHorn.eulerAngles = SCNVector3(-0.35, 0, 0)
        head.addChildNode(nHorn)

        // 4 Full Columnar Walking Legs (Front + Rear)
        let fLeft = makeColumnLeg(xPos: -0.42, zPos: -0.4, mat: mat1, footMat: mat2)
        let fRight = makeColumnLeg(xPos: 0.42, zPos: -0.4, mat: mat1, footMat: mat2)
        let rLeft = makeColumnLeg(xPos: -0.42, zPos: 0.4, mat: mat1, footMat: mat2)
        let rRight = makeColumnLeg(xPos: 0.42, zPos: 0.4, mat: mat1, footMat: mat2)
        root.addChildNode(fLeft)
        root.addChildNode(fRight)
        root.addChildNode(rLeft)
        root.addChildNode(rRight)

        // Short Armored Tail
        let tail = SCNNode(geometry: SCNCone(topRadius: 0.05, bottomRadius: 0.28, height: 0.75))
        tail.geometry?.materials = [mat2]
        tail.position = SCNVector3(0, 0.35, 0.75)
        tail.eulerAngles = SCNVector3(Float.pi / 2 + 0.3, 0, 0)
        root.addChildNode(tail)

        return DinoNodes(
            rootNode: root, bodyNode: body, headNode: head, neckNode: neck, tailNode: tail,
            leftArm: fLeft, rightArm: fRight, leftLeg: rLeft, rightLeg: rRight)
    }

    // MARK: - 2. BRACHIOSAURUS (Long-Neck Sauropod Colossus)
    private static func buildBrachiosaurus(skin: DinoSkin) -> DinoNodes {
        let root = SCNNode()
        let mat1 = makeMat(color: skin.primaryUIColor)
        let mat2 = makeMat(color: skin.secondaryUIColor)

        // Mammoth Torso
        let bodyGeo = SCNCapsule(capRadius: 0.62, height: 1.5)
        bodyGeo.materials = [mat1]
        let body = SCNNode(geometry: bodyGeo)
        body.position = SCNVector3(0, 0.6, 0)
        body.eulerAngles = SCNVector3(Float.pi / 2 - 0.2, 0, 0)
        root.addChildNode(body)

        // Towering 3-Segment Arched Long Neck (>1.8m tall)
        let neckBase = SCNNode(geometry: SCNCylinder(radius: 0.32, height: 0.6))
        neckBase.geometry?.materials = [mat1]
        neckBase.position = SCNVector3(0, 0.85, -0.65)
        neckBase.eulerAngles = SCNVector3(0.5, 0, 0)
        root.addChildNode(neckBase)

        let neckMid = SCNNode(geometry: SCNCylinder(radius: 0.24, height: 0.7))
        neckMid.geometry?.materials = [mat2]
        neckMid.position = SCNVector3(0, 0.55, -0.15)
        neckMid.eulerAngles = SCNVector3(0.3, 0, 0)
        neckBase.addChildNode(neckMid)

        let neckTop = SCNNode(geometry: SCNCylinder(radius: 0.18, height: 0.6))
        neckTop.geometry?.materials = [mat1]
        neckTop.position = SCNVector3(0, 0.55, -0.05)
        neckMid.addChildNode(neckTop)

        // High Rounded Head
        let head = SCNNode(
            geometry: SCNBox(width: 0.44, height: 0.32, length: 0.55, chamferRadius: 0.1))
        head.geometry?.materials = [mat1]
        head.position = SCNVector3(0, 0.35, -0.15)
        neckTop.addChildNode(head)

        // Gentle Eyes
        for isLeft in [true, false] {
            let eye = makeEye(isLeft: isLeft, mat2: mat2)
            eye.position = SCNVector3(isLeft ? -0.23 : 0.23, 0.08, -0.1)
            head.addChildNode(eye)
        }

        // 4 Giant Pillar Legs
        let fL = makeColumnLeg(xPos: -0.45, zPos: -0.45, mat: mat1, footMat: mat2, height: 0.85)
        let fR = makeColumnLeg(xPos: 0.45, zPos: -0.45, mat: mat1, footMat: mat2, height: 0.85)
        let rL = makeColumnLeg(xPos: -0.45, zPos: 0.45, mat: mat1, footMat: mat2, height: 0.75)
        let rR = makeColumnLeg(xPos: 0.45, zPos: 0.45, mat: mat1, footMat: mat2, height: 0.75)
        root.addChildNode(fL)
        root.addChildNode(fR)
        root.addChildNode(rL)
        root.addChildNode(rR)

        // Long Slender Whip Tail
        let tail = SCNNode(geometry: SCNCone(topRadius: 0.02, bottomRadius: 0.22, height: 1.3))
        tail.geometry?.materials = [mat2]
        tail.position = SCNVector3(0, 0.5, 0.8)
        tail.eulerAngles = SCNVector3(Float.pi / 2 - 0.2, 0, 0)
        root.addChildNode(tail)

        return DinoNodes(
            rootNode: root, bodyNode: body, headNode: head, neckNode: neckBase, tailNode: tail,
            leftArm: fL, rightArm: fR, leftLeg: rL, rightLeg: rR)
    }

    // MARK: - 3. ANKYLOSAURUS (Armored Dome Shell & Bone Club Tail)
    private static func buildAnkylosaurus(skin: DinoSkin) -> DinoNodes {
        let root = SCNNode()
        let mat1 = makeMat(color: skin.primaryUIColor)
        let mat2 = makeMat(color: skin.secondaryUIColor)
        let boneMat = makeBoneMat()

        // Wide Flattened Dome Shell
        let shell = SCNNode(geometry: SCNCapsule(capRadius: 0.65, height: 1.35))
        shell.geometry?.materials = [mat1]
        shell.position = SCNVector3(0, 0.38, 0)
        shell.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        shell.scale = SCNVector3(1.35, 0.65, 1.0)
        root.addChildNode(shell)

        // 8 Armor Spikes across Shell
        for r in 0..<4 {
            let zPos = Float(r) * 0.28 - 0.42
            for isLeft in [true, false] {
                let spike = SCNNode(geometry: SCNPyramid(width: 0.18, height: 0.25, length: 0.18))
                spike.geometry?.materials = [boneMat]
                spike.position = SCNVector3(isLeft ? -0.55 : 0.55, 0.22, zPos)
                spike.eulerAngles = SCNVector3(0, 0, isLeft ? 0.45 : -0.45)
                shell.addChildNode(spike)
            }
        }

        // Low Armored Box Head
        let neck = SCNNode(geometry: SCNCylinder(radius: 0.32, height: 0.3))
        neck.geometry?.materials = [mat1]
        neck.position = SCNVector3(0, 0.32, -0.65)
        root.addChildNode(neck)

        let head = SCNNode(
            geometry: SCNBox(width: 0.58, height: 0.36, length: 0.55, chamferRadius: 0.08))
        head.geometry?.materials = [mat2]
        head.position = SCNVector3(0, 0.08, -0.2)
        neck.addChildNode(head)

        // Triangular Cheek Spikes
        for isLeft in [true, false] {
            let cheekSpike = SCNNode(geometry: SCNPyramid(width: 0.14, height: 0.22, length: 0.14))
            cheekSpike.geometry?.materials = [boneMat]
            cheekSpike.position = SCNVector3(isLeft ? -0.32 : 0.32, 0.05, 0)
            cheekSpike.eulerAngles = SCNVector3(0, 0, isLeft ? Float.pi / 2 : -Float.pi / 2)
            head.addChildNode(cheekSpike)

            let eye = makeEye(isLeft: isLeft, mat2: mat2)
            eye.position = SCNVector3(isLeft ? -0.28 : 0.28, 0.08, -0.12)
            head.addChildNode(eye)
        }

        // 4 Low Stout Legs
        let fL = makeColumnLeg(xPos: -0.48, zPos: -0.35, mat: mat1, footMat: mat2, height: 0.45)
        let fR = makeColumnLeg(xPos: 0.48, zPos: -0.35, mat: mat1, footMat: mat2, height: 0.45)
        let rL = makeColumnLeg(xPos: -0.48, zPos: 0.35, mat: mat1, footMat: mat2, height: 0.45)
        let rR = makeColumnLeg(xPos: 0.48, zPos: 0.35, mat: mat1, footMat: mat2, height: 0.45)
        root.addChildNode(fL)
        root.addChildNode(fR)
        root.addChildNode(rL)
        root.addChildNode(rR)

        // Armored Tail with HEAVY DOUBLE-SPHERE BONE HAMMER CLUB
        let tail = SCNNode()
        tail.position = SCNVector3(0, 0.28, 0.65)

        let tailShaft = SCNNode(geometry: SCNCylinder(radius: 0.12, height: 0.9))
        tailShaft.geometry?.materials = [mat1]
        tailShaft.position = SCNVector3(0, 0, 0.45)
        tailShaft.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        tail.addChildNode(tailShaft)

        // Heavy Bone Club Ball
        let club1 = SCNNode(geometry: SCNSphere(radius: 0.22))
        club1.geometry?.materials = [boneMat]
        club1.position = SCNVector3(-0.12, 0, 0.9)
        tail.addChildNode(club1)

        let club2 = SCNNode(geometry: SCNSphere(radius: 0.22))
        club2.geometry?.materials = [boneMat]
        club2.position = SCNVector3(0.12, 0, 0.9)
        tail.addChildNode(club2)

        root.addChildNode(tail)

        return DinoNodes(
            rootNode: root, bodyNode: shell, headNode: head, neckNode: neck, tailNode: tail,
            leftArm: fL, rightArm: fR, leftLeg: rL, rightLeg: rR)
    }

    // MARK: - 4. PTERODACTYL (Aerodynamic Flyer with 1.5m Wings & Spear Beak)
    private static func buildPterodactyl(skin: DinoSkin) -> DinoNodes {
        let root = SCNNode()
        let mat1 = makeMat(color: skin.primaryUIColor)
        let mat2 = makeMat(color: skin.secondaryUIColor)
        let boneMat = makeBoneMat()

        // Slender Avian Torso
        let bodyGeo = SCNCapsule(capRadius: 0.32, height: 1.1)
        bodyGeo.materials = [mat1]
        let body = SCNNode(geometry: bodyGeo)
        body.position = SCNVector3(0, 0.55, 0)
        body.eulerAngles = SCNVector3(0.45, 0, 0)
        root.addChildNode(body)

        // Aerodynamic Long Spear Head & Backward Crest
        let neck = SCNNode(geometry: SCNCylinder(radius: 0.18, height: 0.45))
        neck.geometry?.materials = [mat1]
        neck.position = SCNVector3(0, 0.45, -0.28)
        neck.eulerAngles = SCNVector3(0.5, 0, 0)
        body.addChildNode(neck)

        let head = SCNNode()
        head.position = SCNVector3(0, 0.25, -0.15)
        neck.addChildNode(head)

        // Spear Beak (Length 0.85m)
        let beak = SCNNode(geometry: SCNCone(topRadius: 0, bottomRadius: 0.16, height: 0.85))
        beak.geometry?.materials = [mat2]
        beak.position = SCNVector3(0, 0, -0.45)
        beak.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
        head.addChildNode(beak)

        // Backward Cranial Horn Crest
        let crest = SCNNode(geometry: SCNCone(topRadius: 0, bottomRadius: 0.14, height: 0.7))
        crest.geometry?.materials = [mat2]
        crest.position = SCNVector3(0, 0.12, 0.35)
        crest.eulerAngles = SCNVector3(Float.pi / 2 - 0.2, 0, 0)
        head.addChildNode(crest)

        // Eyes
        for isLeft in [true, false] {
            let eye = makeEye(isLeft: isLeft, mat2: mat2)
            eye.position = SCNVector3(isLeft ? -0.18 : 0.18, 0.08, -0.1)
            head.addChildNode(eye)
        }

        // TWO MASSIVE ARTICULATED WINGS (Span > 1.6m)
        let leftWing = makePteroWing(isLeft: true, mat1: mat1, mat2: mat2, boneMat: boneMat)
        let rightWing = makePteroWing(isLeft: false, mat1: mat1, mat2: mat2, boneMat: boneMat)
        body.addChildNode(leftWing)
        body.addChildNode(rightWing)

        // Slender Perching Leg Talons
        let legL = makeBipedLeg(
            isLeft: true, primaryMat: mat1, secondaryMat: mat2, clawMat: boneMat)
        let legR = makeBipedLeg(
            isLeft: false, primaryMat: mat1, secondaryMat: mat2, clawMat: boneMat)
        root.addChildNode(legL)
        root.addChildNode(legR)

        // Rudder Tail
        let tail = SCNNode(geometry: SCNCone(topRadius: 0.01, bottomRadius: 0.1, height: 0.6))
        tail.geometry?.materials = [mat2]
        tail.position = SCNVector3(0, -0.1, 0.5)
        tail.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        body.addChildNode(tail)

        return DinoNodes(
            rootNode: root, bodyNode: body, headNode: head, neckNode: neck, tailNode: tail,
            leftArm: leftWing, rightArm: rightWing, leftLeg: legL, rightLeg: legR)
    }

    private static func makePteroWing(
        isLeft: Bool, mat1: SCNMaterial, mat2: SCNMaterial, boneMat: SCNMaterial
    ) -> SCNNode {
        let wingRoot = SCNNode()
        wingRoot.position = SCNVector3(isLeft ? -0.32 : 0.32, 0.2, 0)

        // Arm Bone
        let armBone = SCNNode(geometry: SCNCylinder(radius: 0.06, height: 0.7))
        armBone.geometry?.materials = [boneMat]
        armBone.position = SCNVector3(isLeft ? -0.35 : 0.35, 0.1, 0)
        armBone.eulerAngles = SCNVector3(0, 0, isLeft ? -Float.pi / 3 : Float.pi / 3)
        wingRoot.addChildNode(armBone)

        // Wide Wing Membrane Blade
        let membrane = SCNNode(
            geometry: SCNBox(width: 0.95, height: 0.03, length: 0.55, chamferRadius: 0.01))
        membrane.geometry?.materials = [mat2]
        membrane.position = SCNVector3(isLeft ? -0.45 : 0.45, 0, 0.15)
        wingRoot.addChildNode(membrane)

        return wingRoot
    }

    // MARK: - 5. CYBER MECH-BOT (Robotic Walker with Shoulder Cannons & Jet Turbines)
    private static func buildCyberMecha(skin: DinoSkin) -> DinoNodes {
        let root = SCNNode()
        let metalMat = makeMat(color: skin.primaryUIColor, metal: 0.9, rough: 0.2)
        let darkArmor = makeMat(color: skin.secondaryUIColor, metal: 0.7, rough: 0.3)
        let glowMat = makeGlowMat(color: skin.secondaryUIColor)
        let laserMat = makeGlowMat(color: Color(hex: "#00F0FF"))

        // Boxy Robotic Torso Chassis
        let bodyGeo = SCNBox(width: 0.82, height: 0.95, length: 1.1, chamferRadius: 0.08)
        bodyGeo.materials = [metalMat]
        let body = SCNNode(geometry: bodyGeo)
        body.position = SCNVector3(0, 0.48, 0)
        body.eulerAngles = SCNVector3(0.2, 0, 0)
        root.addChildNode(body)

        // Dual Shoulder Missile Cannons
        for isLeft in [true, false] {
            let cannon = SCNNode(geometry: SCNCylinder(radius: 0.12, height: 0.65))
            cannon.geometry?.materials = [darkArmor]
            cannon.position = SCNVector3(isLeft ? -0.48 : 0.48, 0.48, -0.15)
            cannon.eulerAngles = SCNVector3(-Float.pi / 2 + 0.2, 0, 0)
            body.addChildNode(cannon)

            // Cannon Muzzle Laser Core
            let laser = SCNNode(geometry: SCNCylinder(radius: 0.08, height: 0.05))
            laser.geometry?.materials = [laserMat]
            laser.position = SCNVector3(0, 0.33, 0)
            cannon.addChildNode(laser)

            // Twin Hip Jet Rocket Turbines
            let thruster = SCNNode(geometry: SCNCylinder(radius: 0.14, height: 0.45))
            thruster.geometry?.materials = [darkArmor]
            thruster.position = SCNVector3(isLeft ? -0.42 : 0.42, -0.1, 0.48)
            thruster.eulerAngles = SCNVector3(Float.pi / 2 - 0.2, 0, 0)
            body.addChildNode(thruster)

            let flame = SCNNode(geometry: SCNCylinder(radius: 0.1, height: 0.1))
            flame.geometry?.materials = [laserMat]
            flame.position = SCNVector3(0, -0.23, 0)
            thruster.addChildNode(flame)
        }

        // Robotic Helm with Neon Laser HUD Visor
        let neck = SCNNode(
            geometry: SCNBox(width: 0.4, height: 0.3, length: 0.35, chamferRadius: 0.04))
        neck.geometry?.materials = [darkArmor]
        neck.position = SCNVector3(0, 0.45, -0.45)
        body.addChildNode(neck)

        let head = SCNNode(
            geometry: SCNBox(width: 0.62, height: 0.45, length: 0.72, chamferRadius: 0.08))
        head.geometry?.materials = [metalMat]
        head.position = SCNVector3(0, 0.22, -0.2)
        neck.addChildNode(head)

        // Glowing Visor Slit
        let visor = SCNNode(
            geometry: SCNBox(width: 0.66, height: 0.12, length: 0.35, chamferRadius: 0.02))
        visor.geometry?.materials = [glowMat]
        visor.position = SCNVector3(0, 0.08, -0.22)
        head.addChildNode(visor)

        // Heavy Hydraulic Steel Arms
        let leftArm = makeMechArm(isLeft: true, metalMat: metalMat, glowMat: glowMat)
        let rightArm = makeMechArm(isLeft: false, metalMat: metalMat, glowMat: glowMat)
        body.addChildNode(leftArm)
        body.addChildNode(rightArm)

        // Heavy Bipedal Piston Legs
        let leftLeg = makeMechLeg(isLeft: true, metalMat: metalMat, darkMat: darkArmor)
        let rightLeg = makeMechLeg(isLeft: false, metalMat: metalMat, darkMat: darkArmor)
        root.addChildNode(leftLeg)
        root.addChildNode(rightLeg)

        // Heavy Steel Tail
        let tail = SCNNode(
            geometry: SCNBox(width: 0.28, height: 0.22, length: 0.8, chamferRadius: 0.04))
        tail.geometry?.materials = [darkArmor]
        tail.position = SCNVector3(0, -0.15, 0.65)
        tail.eulerAngles = SCNVector3(-0.3, 0, 0)
        body.addChildNode(tail)

        return DinoNodes(
            rootNode: root, bodyNode: body, headNode: head, neckNode: neck, tailNode: tail,
            leftArm: leftArm, rightArm: rightArm, leftLeg: leftLeg, rightLeg: rightLeg)
    }

    private static func makeMechArm(isLeft: Bool, metalMat: SCNMaterial, glowMat: SCNMaterial)
        -> SCNNode
    {
        let arm = SCNNode()
        arm.position = SCNVector3(isLeft ? -0.48 : 0.48, 0.1, -0.2)
        let bicep = SCNNode(
            geometry: SCNBox(width: 0.14, height: 0.38, length: 0.14, chamferRadius: 0.02))
        bicep.geometry?.materials = [metalMat]
        bicep.position = SCNVector3(0, -0.1, 0)
        arm.addChildNode(bicep)
        return arm
    }

    private static func makeMechLeg(isLeft: Bool, metalMat: SCNMaterial, darkMat: SCNMaterial)
        -> SCNNode
    {
        let leg = SCNNode()
        leg.position = SCNVector3(isLeft ? -0.38 : 0.38, 0.25, 0)
        let thigh = SCNNode(
            geometry: SCNBox(width: 0.26, height: 0.58, length: 0.28, chamferRadius: 0.04))
        thigh.geometry?.materials = [metalMat]
        thigh.position = SCNVector3(0, -0.1, 0)
        leg.addChildNode(thigh)

        let foot = SCNNode(
            geometry: SCNBox(width: 0.35, height: 0.14, length: 0.52, chamferRadius: 0.04))
        foot.geometry?.materials = [darkMat]
        foot.position = SCNVector3(0, -0.55, -0.12)
        leg.addChildNode(foot)
        return leg
    }

    // MARK: - 6. SPINOSAURUS (Elongated Croc Snout & 1.2m Tall Glowing Sail Fin)
    private static func buildSpinosaurus(skin: DinoSkin) -> DinoNodes {
        let root = SCNNode()
        let mat1 = makeMat(color: skin.primaryUIColor)
        let mat2 = makeMat(color: skin.secondaryUIColor)
        let glowMat = makeGlowMat(color: skin.secondaryUIColor)
        let boneMat = makeBoneMat()

        let bodyGeo = SCNCapsule(capRadius: 0.48, height: 1.35)
        bodyGeo.materials = [mat1]
        let body = SCNNode(geometry: bodyGeo)
        body.position = SCNVector3(0, 0.42, 0)
        body.eulerAngles = SCNVector3(0.24, 0, 0)
        root.addChildNode(body)

        // MASSIVE 1.2M GLOWING SAIL FIN
        let sailHolder = SCNNode()
        sailHolder.position = SCNVector3(0, 0.48, 0)
        for i in 0..<8 {
            let normalized = Float(i) / 7.0
            let h = sin(normalized * Float.pi) * 0.95 + 0.25
            let rib = SCNNode(geometry: SCNCylinder(radius: 0.035, height: CGFloat(h)))
            rib.geometry?.materials = [glowMat]
            rib.position = SCNVector3(0, h / 2, (Float(i) - 3.5) * 0.18)
            sailHolder.addChildNode(rib)
        }
        let membrane = SCNNode(
            geometry: SCNBox(width: 0.04, height: 0.85, length: 1.35, chamferRadius: 0.02))
        membrane.geometry?.materials = [mat2]
        membrane.position = SCNVector3(0, 0.45, 0)
        sailHolder.addChildNode(membrane)
        body.addChildNode(sailHolder)

        // Long Crocodile Head & Needle Teeth
        let neck = SCNNode(geometry: SCNCylinder(radius: 0.26, height: 0.55))
        neck.geometry?.materials = [mat1]
        neck.position = SCNVector3(0, 0.55, -0.28)
        neck.eulerAngles = SCNVector3(0.42, 0, 0)
        body.addChildNode(neck)

        let head = SCNNode()
        head.position = SCNVector3(0, 0.32, -0.25)
        neck.addChildNode(head)

        let crocSnout = SCNNode(
            geometry: SCNBox(width: 0.48, height: 0.32, length: 1.15, chamferRadius: 0.08))
        crocSnout.geometry?.materials = [mat1]
        crocSnout.position = SCNVector3(0, 0.05, -0.45)
        head.addChildNode(crocSnout)

        for isLeft in [true, false] {
            let eye = makeEye(isLeft: isLeft, mat2: mat2)
            eye.position = SCNVector3(isLeft ? -0.25 : 0.25, 0.12, -0.15)
            head.addChildNode(eye)
        }

        let armL = makeBipedArm(isLeft: true, mat: mat2, clawMat: boneMat)
        let armR = makeBipedArm(isLeft: false, mat: mat2, clawMat: boneMat)
        body.addChildNode(armL)
        body.addChildNode(armR)

        let legL = makeBipedLeg(
            isLeft: true, primaryMat: mat1, secondaryMat: mat2, clawMat: boneMat)
        let legR = makeBipedLeg(
            isLeft: false, primaryMat: mat1, secondaryMat: mat2, clawMat: boneMat)
        root.addChildNode(legL)
        root.addChildNode(legR)

        let tail = makeBipedTail(mat1: mat1, mat2: mat2)
        body.addChildNode(tail)

        return DinoNodes(
            rootNode: root, bodyNode: body, headNode: head, neckNode: neck, tailNode: tail,
            leftArm: armL, rightArm: armR, leftLeg: legL, rightLeg: legR)
    }

    // MARK: - 7. STEGOSAURUS (Plate Quadruped & Thagomizer)
    private static func buildStegosaurus(skin: DinoSkin) -> DinoNodes {
        let root = SCNNode()
        let mat1 = makeMat(color: skin.primaryUIColor)
        let mat2 = makeMat(color: skin.secondaryUIColor)
        let boneMat = makeBoneMat()

        let bodyGeo = SCNCapsule(capRadius: 0.54, height: 1.45)
        bodyGeo.materials = [mat1]
        let body = SCNNode(geometry: bodyGeo)
        body.position = SCNVector3(0, 0.45, 0)
        body.eulerAngles = SCNVector3(Float.pi / 2 - 0.15, 0, 0)
        root.addChildNode(body)

        // DOUBLE ROW OF 8 DIAMOND PLATES
        for i in 0..<6 {
            let zPos = (Float(i) - 2.5) * 0.25
            let scale: Float = (i == 2 || i == 3) ? 1.15 : 0.8
            for isLeft in [true, false] {
                let plate = SCNNode(
                    geometry: SCNPyramid(
                        width: CGFloat(0.32 * scale), height: CGFloat(0.48 * scale), length: 0.05))
                plate.geometry?.materials = [mat2]
                plate.position = SCNVector3(
                    isLeft ? -0.15 : 0.15, 0.52, zPos + (isLeft ? 0.08 : -0.08))
                plate.eulerAngles = SCNVector3(0, 0, isLeft ? 0.25 : -0.25)
                body.addChildNode(plate)
            }
        }

        let neck = SCNNode(geometry: SCNCylinder(radius: 0.28, height: 0.42))
        neck.geometry?.materials = [mat1]
        neck.position = SCNVector3(0, 0.38, -0.65)
        root.addChildNode(neck)

        let head = SCNNode(
            geometry: SCNBox(width: 0.45, height: 0.35, length: 0.55, chamferRadius: 0.08))
        head.geometry?.materials = [mat2]
        head.position = SCNVector3(0, 0.08, -0.2)
        neck.addChildNode(head)

        for isLeft in [true, false] {
            let eye = makeEye(isLeft: isLeft, mat2: mat2)
            eye.position = SCNVector3(isLeft ? -0.23 : 0.23, 0.08, -0.1)
            head.addChildNode(eye)
        }

        let fL = makeColumnLeg(xPos: -0.42, zPos: -0.4, mat: mat1, footMat: mat2, height: 0.55)
        let fR = makeColumnLeg(xPos: 0.42, zPos: -0.4, mat: mat1, footMat: mat2, height: 0.55)
        let rL = makeColumnLeg(xPos: -0.42, zPos: 0.4, mat: mat1, footMat: mat2, height: 0.65)
        let rR = makeColumnLeg(xPos: 0.42, zPos: 0.4, mat: mat1, footMat: mat2, height: 0.65)
        root.addChildNode(fL)
        root.addChildNode(fR)
        root.addChildNode(rL)
        root.addChildNode(rR)

        // THAGOMIZER TAIL (4 HORIZONTAL SPIKES)
        let tail = SCNNode(geometry: SCNCone(topRadius: 0.03, bottomRadius: 0.25, height: 1.1))
        tail.geometry?.materials = [mat1]
        tail.position = SCNVector3(0, 0.4, 0.75)
        tail.eulerAngles = SCNVector3(Float.pi / 2 - 0.2, 0, 0)

        for isLeft in [true, false] {
            for s in 0..<2 {
                let spike = SCNNode(
                    geometry: SCNCone(topRadius: 0, bottomRadius: 0.04, height: 0.38))
                spike.geometry?.materials = [boneMat]
                spike.position = SCNVector3(isLeft ? -0.15 : 0.15, 0.1, 0.6 + Float(s) * 0.22)
                spike.eulerAngles = SCNVector3(0, 0, isLeft ? -Float.pi / 2.5 : Float.pi / 2.5)
                tail.addChildNode(spike)
            }
        }
        root.addChildNode(tail)

        return DinoNodes(
            rootNode: root, bodyNode: body, headNode: head, neckNode: neck, tailNode: tail,
            leftArm: fL, rightArm: fR, leftLeg: rL, rightLeg: rR)
    }

    // MARK: - 8. VELOCIRAPTOR (Sleek Hunter & Giant Sickle Toe Claws)
    private static func buildRaptor(skin: DinoSkin) -> DinoNodes {
        let root = SCNNode()
        let mat1 = makeMat(color: skin.primaryUIColor)
        let mat2 = makeMat(color: skin.secondaryUIColor)
        let boneMat = makeBoneMat()

        // Forward-leaning sleek torso
        let bodyGeo = SCNCapsule(capRadius: 0.38, height: 1.2)
        bodyGeo.materials = [mat1]
        let body = SCNNode(geometry: bodyGeo)
        body.position = SCNVector3(0, 0.45, 0)
        body.eulerAngles = SCNVector3(0.5, 0, 0)  // aggressive lean
        root.addChildNode(body)

        // Aerodynamic Agile Neck & Head
        let neck = SCNNode(geometry: SCNCylinder(radius: 0.22, height: 0.55))
        neck.geometry?.materials = [mat1]
        neck.position = SCNVector3(0, 0.55, -0.32)
        neck.eulerAngles = SCNVector3(0.55, 0, 0)
        body.addChildNode(neck)

        let head = SCNNode(
            geometry: SCNBox(width: 0.46, height: 0.36, length: 0.78, chamferRadius: 0.08))
        head.geometry?.materials = [mat1]
        head.position = SCNVector3(0, 0.28, -0.22)
        neck.addChildNode(head)

        for isLeft in [true, false] {
            let eye = makeEye(isLeft: isLeft, mat2: mat2)
            eye.position = SCNVector3(isLeft ? -0.24 : 0.24, 0.1, -0.15)
            head.addChildNode(eye)
        }

        // Extended Grasping Forearm Claws
        let armL = makeBipedArm(isLeft: true, mat: mat2, clawMat: boneMat)
        let armR = makeBipedArm(isLeft: false, mat: mat2, clawMat: boneMat)
        body.addChildNode(armL)
        body.addChildNode(armR)

        // Muscular Legs with GIANT CURVED SICKLE KILLER CLAW
        let legL = makeRaptorLeg(
            isLeft: true, primaryMat: mat1, secondaryMat: mat2, clawMat: boneMat)
        let legR = makeRaptorLeg(
            isLeft: false, primaryMat: mat1, secondaryMat: mat2, clawMat: boneMat)
        root.addChildNode(legL)
        root.addChildNode(legR)

        // Stiff Horizontal Balancing Tail with Feather Fan
        let tail = SCNNode()
        tail.position = SCNVector3(0, -0.1, 0.55)
        let tailShaft = SCNNode(geometry: SCNCone(topRadius: 0.02, bottomRadius: 0.18, height: 1.4))
        tailShaft.geometry?.materials = [mat2]
        tailShaft.position = SCNVector3(0, 0.1, 0.7)
        tailShaft.eulerAngles = SCNVector3(Float.pi / 2 - 0.15, 0, 0)
        tail.addChildNode(tailShaft)
        body.addChildNode(tail)

        return DinoNodes(
            rootNode: root, bodyNode: body, headNode: head, neckNode: neck, tailNode: tail,
            leftArm: armL, rightArm: armR, leftLeg: legL, rightLeg: legR)
    }

    private static func makeRaptorLeg(
        isLeft: Bool, primaryMat: SCNMaterial, secondaryMat: SCNMaterial, clawMat: SCNMaterial
    ) -> SCNNode {
        let leg = makeBipedLeg(
            isLeft: isLeft, primaryMat: primaryMat, secondaryMat: secondaryMat, clawMat: clawMat)
        // Giant Sickle Toe Claw (Raised killer digit)
        let sickle = SCNNode(geometry: SCNCone(topRadius: 0, bottomRadius: 0.04, height: 0.26))
        sickle.geometry?.materials = [clawMat]
        sickle.position = SCNVector3(isLeft ? 0.08 : -0.08, -0.48, -0.38)
        sickle.eulerAngles = SCNVector3(-0.5, 0, 0)
        leg.addChildNode(sickle)
        return leg
    }

    // MARK: - 9. T-REX / FROST / GOLD / MAGMA (Apex Predators)
    private static func buildTRex(skin: DinoSkin) -> DinoNodes {
        return buildApexBase(skin: skin)
    }

    private static func buildFrostWyrm(skin: DinoSkin) -> DinoNodes {
        let nodes = buildApexBase(skin: skin, isFrost: true)
        let glowMat = makeGlowMat(color: skin.secondaryUIColor)
        for isLeft in [true, false] {
            let horn = SCNNode(geometry: SCNPyramid(width: 0.14, height: 0.5, length: 0.14))
            horn.geometry?.materials = [glowMat]
            horn.position = SCNVector3(isLeft ? -0.22 : 0.22, 0.35, -0.2)
            horn.eulerAngles = SCNVector3(-0.4, 0, isLeft ? -0.3 : 0.3)
            nodes.headNode.addChildNode(horn)
        }
        return nodes
    }

    private static func buildGoldenEmperor(skin: DinoSkin) -> DinoNodes {
        let nodes = buildApexBase(skin: skin, isGold: true)
        let crown = SCNNode(
            geometry: SCNBox(width: 0.44, height: 0.22, length: 0.46, chamferRadius: 0.05))
        crown.geometry?.materials = [makeMat(color: skin.primaryUIColor, metal: 0.95)]
        crown.position = SCNVector3(0, 0.3, -0.15)
        for c in 0..<3 {
            let p = SCNNode(geometry: SCNPyramid(width: 0.11, height: 0.24, length: 0.11))
            p.geometry?.materials = [makeMat(color: skin.secondaryUIColor, metal: 0.9)]
            p.position = SCNVector3((Float(c) - 1.0) * 0.14, 0.12, 0)
            crown.addChildNode(p)
        }
        nodes.headNode.addChildNode(crown)
        return nodes
    }

    private static func buildApexBase(skin: DinoSkin, isFrost: Bool = false, isGold: Bool = false)
        -> DinoNodes
    {
        let root = SCNNode()
        let mat1 = makeMat(
            color: skin.primaryUIColor, metal: isGold ? 0.95 : 0.05, rough: isGold ? 0.15 : 0.4)
        let mat2 = makeMat(color: skin.secondaryUIColor, metal: isGold ? 0.85 : 0.1)
        let boneMat = makeBoneMat()

        let bodyGeo = SCNCapsule(capRadius: 0.48, height: 1.3)
        bodyGeo.materials = [mat1]
        let body = SCNNode(geometry: bodyGeo)
        body.position = SCNVector3(0, 0.42, 0)
        body.eulerAngles = SCNVector3(0.28, 0, 0)
        root.addChildNode(body)

        let neck = SCNNode(geometry: SCNCylinder(radius: 0.3, height: 0.52))
        neck.geometry?.materials = [mat1]
        neck.position = SCNVector3(0, 0.55, -0.24)
        neck.eulerAngles = SCNVector3(0.4, 0, 0)
        body.addChildNode(neck)

        let head = SCNNode()
        head.position = SCNVector3(0, 0.3, -0.22)
        neck.addChildNode(head)

        let cranium = SCNNode(
            geometry: SCNBox(width: 0.62, height: 0.46, length: 0.88, chamferRadius: 0.14))
        cranium.geometry?.materials = [mat1]
        cranium.position = SCNVector3(0, 0.08, -0.24)
        head.addChildNode(cranium)

        for isLeft in [true, false] {
            let eye = makeEye(isLeft: isLeft, mat2: mat2)
            eye.position = SCNVector3(isLeft ? -0.32 : 0.32, 0.14, -0.2)
            head.addChildNode(eye)
        }

        let jaw = SCNNode(
            geometry: SCNBox(width: 0.52, height: 0.18, length: 0.72, chamferRadius: 0.08))
        jaw.geometry?.materials = [mat2]
        jaw.position = SCNVector3(0, -0.18, -0.32)
        jaw.eulerAngles = SCNVector3(0.12, 0, 0)
        head.addChildNode(jaw)

        // Teeth
        for i in 0..<5 {
            let zPos = Float(i) * 0.11 - 0.55
            for isLeft in [true, false] {
                let xPos: Float = isLeft ? -0.22 : 0.22
                let uTooth = SCNNode(
                    geometry: SCNCone(topRadius: 0, bottomRadius: 0.04, height: 0.1))
                uTooth.geometry?.materials = [boneMat]
                uTooth.position = SCNVector3(xPos, -0.12, zPos + 0.1)
                uTooth.eulerAngles = SCNVector3(Float.pi, 0, 0)
                cranium.addChildNode(uTooth)
            }
        }

        let armL = makeBipedArm(isLeft: true, mat: mat2, clawMat: boneMat)
        let armR = makeBipedArm(isLeft: false, mat: mat2, clawMat: boneMat)
        body.addChildNode(armL)
        body.addChildNode(armR)

        let legL = makeBipedLeg(
            isLeft: true, primaryMat: mat1, secondaryMat: mat2, clawMat: boneMat)
        let legR = makeBipedLeg(
            isLeft: false, primaryMat: mat1, secondaryMat: mat2, clawMat: boneMat)
        root.addChildNode(legL)
        root.addChildNode(legR)

        let tail = makeBipedTail(mat1: mat1, mat2: mat2)
        body.addChildNode(tail)

        return DinoNodes(
            rootNode: root, bodyNode: body, headNode: head, neckNode: neck, tailNode: tail,
            leftArm: armL, rightArm: armR, leftLeg: legL, rightLeg: legR)
    }

    // MARK: - Reusable Anatomy Primitives
    private static func makeEye(isLeft: Bool, mat2: SCNMaterial) -> SCNNode {
        let eyeRoot = SCNNode()
        let white = SCNMaterial()
        white.diffuse.contents = UIColor(white: 0.95, alpha: 1.0)
        let pupilMat = SCNMaterial()
        pupilMat.diffuse.contents = UIColor.black

        let ball = SCNNode(geometry: SCNSphere(radius: 0.11))
        ball.geometry?.materials = [white]

        let pupil = SCNNode(geometry: SCNCylinder(radius: 0.045, height: 0.03))
        pupil.geometry?.materials = [pupilMat]
        pupil.position = SCNVector3(isLeft ? -0.06 : 0.06, 0, -0.04)
        pupil.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        ball.addChildNode(pupil)
        eyeRoot.addChildNode(ball)
        return eyeRoot
    }

    private static func makeColumnLeg(
        xPos: Float, zPos: Float, mat: SCNMaterial, footMat: SCNMaterial, height: Float = 0.6
    ) -> SCNNode {
        let leg = SCNNode()
        leg.position = SCNVector3(xPos, height / 2, zPos)
        let col = SCNNode(geometry: SCNCylinder(radius: 0.18, height: CGFloat(height)))
        col.geometry?.materials = [mat]
        leg.addChildNode(col)
        let foot = SCNNode(geometry: SCNCylinder(radius: 0.22, height: 0.12))
        foot.geometry?.materials = [footMat]
        foot.position = SCNVector3(0, -height / 2 + 0.06, 0)
        leg.addChildNode(foot)
        return leg
    }

    private static func makeBipedArm(isLeft: Bool, mat: SCNMaterial, clawMat: SCNMaterial)
        -> SCNNode
    {
        let arm = SCNNode()
        arm.position = SCNVector3(isLeft ? -0.42 : 0.42, 0.25, -0.28)
        let bicep = SCNNode(geometry: SCNCapsule(capRadius: 0.09, height: 0.32))
        bicep.geometry?.materials = [mat]
        bicep.position = SCNVector3(0, -0.08, -0.06)
        bicep.eulerAngles = SCNVector3(Float.pi / 3.5, 0, isLeft ? 0.3 : -0.3)
        arm.addChildNode(bicep)
        for c in 0..<2 {
            let claw = SCNNode(geometry: SCNCone(topRadius: 0, bottomRadius: 0.025, height: 0.1))
            claw.geometry?.materials = [clawMat]
            claw.position = SCNVector3(Float(c) * 0.05 - 0.025, -0.22, -0.16)
            claw.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
            arm.addChildNode(claw)
        }
        return arm
    }

    private static func makeBipedLeg(
        isLeft: Bool, primaryMat: SCNMaterial, secondaryMat: SCNMaterial, clawMat: SCNMaterial
    ) -> SCNNode {
        let leg = SCNNode()
        leg.position = SCNVector3(isLeft ? -0.35 : 0.35, 0.25, 0)
        let thigh = SCNNode(geometry: SCNCapsule(capRadius: 0.2, height: 0.6))
        thigh.geometry?.materials = [primaryMat]
        thigh.position = SCNVector3(0, -0.1, 0)
        thigh.eulerAngles = SCNVector3(0.2, 0, isLeft ? -0.1 : 0.1)
        leg.addChildNode(thigh)

        let shin = SCNNode(geometry: SCNCapsule(capRadius: 0.13, height: 0.5))
        shin.geometry?.materials = [secondaryMat]
        shin.position = SCNVector3(0, -0.38, 0.05)
        shin.eulerAngles = SCNVector3(-0.35, 0, 0)
        leg.addChildNode(shin)

        let foot = SCNNode(
            geometry: SCNBox(width: 0.28, height: 0.12, length: 0.42, chamferRadius: 0.05))
        foot.geometry?.materials = [secondaryMat]
        foot.position = SCNVector3(0, -0.56, -0.12)
        leg.addChildNode(foot)

        for t in 0..<3 {
            let toeClaw = SCNNode(
                geometry: SCNCone(topRadius: 0, bottomRadius: 0.035, height: 0.14))
            toeClaw.geometry?.materials = [clawMat]
            let xPos = (Float(t) - 1.0) * 0.09
            toeClaw.position = SCNVector3(xPos, -0.57, -0.36)
            toeClaw.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
            leg.addChildNode(toeClaw)
        }
        return leg
    }

    private static func makeBipedTail(mat1: SCNMaterial, mat2: SCNMaterial) -> SCNNode {
        let tail = SCNNode()
        tail.position = SCNVector3(0, -0.1, 0.55)
        let t1 = SCNNode(geometry: SCNCone(topRadius: 0.18, bottomRadius: 0.36, height: 0.6))
        t1.geometry?.materials = [mat1]
        t1.position = SCNVector3(0, 0, 0.25)
        t1.eulerAngles = SCNVector3(Float.pi / 2 - 0.2, 0, 0)
        tail.addChildNode(t1)

        let t2 = SCNNode(geometry: SCNCone(topRadius: 0.08, bottomRadius: 0.18, height: 0.6))
        t2.geometry?.materials = [mat2]
        t2.position = SCNVector3(0, 0.1, 0.75)
        t2.eulerAngles = SCNVector3(Float.pi / 2 - 0.1, 0, 0)
        tail.addChildNode(t2)
        return tail
    }

    private static func makeMat(color: UIColor, metal: Float = 0.05, rough: Float = 0.4)
        -> SCNMaterial
    {
        let mat = SCNMaterial()
        mat.diffuse.contents = color
        mat.metalness.contents = metal
        mat.roughness.contents = rough
        return mat
    }

    private static func makeBoneMat() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor(red: 0.95, green: 0.93, blue: 0.85, alpha: 1.0)
        mat.roughness.contents = 0.25
        return mat
    }

    private static func makeGlowMat(color: UIColor) -> SCNMaterial {
        let mat = SCNMaterial()
        mat.diffuse.contents = color
        mat.emission.contents = color
        return mat
    }

    private static func makeGlowMat(color: Color) -> SCNMaterial {
        makeGlowMat(color: UIColor(color))
    }
}
