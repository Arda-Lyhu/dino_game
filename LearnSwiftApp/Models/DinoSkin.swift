import SwiftUI

/// Available morphological dinosaur species categories with completely distinct 3D body architecture.
enum DinoSpecies: String, Codable, CaseIterable {
    case trex = "Tyrannosaurus"
    case triceratops = "Triceratops"
    case brachio = "Brachiosaurus"
    case ankylosaurus = "Ankylosaurus"
    case spinosaurus = "Spinosaurus"
    case stegosaurus = "Stegosaurus"
    case pterodactyl = "Pterodactyl"
    case mecha = "Cyber Mech-Bot"
    case raptor = "Velociraptor"
    case frost = "Glacial Wyrm"
    case gold = "Golden Emperor"
}

/// Represents an unlockable 3D dinosaur skin aesthetic with species morphology.
struct DinoSkin: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let name: String
    let species: DinoSpecies
    let bodyType: String // e.g. "Bipedal Apex", "Quadrupedal Tank", "Long-Neck Titan", "Winged Flyer", "Armored Club-Tail", "Cyber Walker"
    let description: String
    let primaryColorHex: String
    let secondaryColorHex: String
    let price: Int
    let iconName: String
    
    // UI Helpers
    var primaryColor: Color { Color(hex: primaryColorHex) }
    var secondaryColor: Color { Color(hex: secondaryColorHex) }
    var primaryUIColor: UIColor { UIColor(primaryColor) }
    var secondaryUIColor: UIColor { UIColor(secondaryColor) }
    
    // MARK: - Expanded 3D Body Models & Species Catalog
    static let catalog: [DinoSkin] = [
        DinoSkin(
            id: "classic",
            name: "Rex (Classic)",
            species: .trex,
            bodyType: "Bipedal Apex",
            description: "The massive Jurassic apex sprinter with bone-crushing jaws and muscular legs.",
            primaryColorHex: "#2ECC71",
            secondaryColorHex: "#27AE60",
            price: 0,
            iconName: "leaf.fill"
        ),
        DinoSkin(
            id: "triceratops_titan",
            name: "Tri-Horn Juggernaut",
            species: .triceratops,
            bodyType: "Quadrupedal Tank",
            description: "Full 4-legged heavy tank chassis with 3 giant piercing horns & massive neck shield.",
            primaryColorHex: "#E67E22",
            secondaryColorHex: "#D35400",
            price: 150,
            iconName: "shield.fill"
        ),
        DinoSkin(
            id: "brachio_titan",
            name: "Brachio Colossus",
            species: .brachio,
            bodyType: "Long-Neck Titan",
            description: "Giant 4-legged sauropod with a towering vertical neck and mammoth body mass.",
            primaryColorHex: "#3498DB",
            secondaryColorHex: "#2980B9",
            price: 200,
            iconName: "arrow.up.and.line.horizontal.and.arrow.down"
        ),
        DinoSkin(
            id: "ankylos_fortress",
            name: "Ankylo Fortress",
            species: .ankylosaurus,
            bodyType: "Armored Club-Tail",
            description: "Heavy low-profile tank body with hexagonal armor plates and a bone wrecking-ball tail.",
            primaryColorHex: "#795548",
            secondaryColorHex: "#D7CCC8",
            price: 250,
            iconName: "hammer.fill"
        ),
        DinoSkin(
            id: "spino_leviathan",
            name: "Spino Leviathan",
            species: .spinosaurus,
            bodyType: "Semi-Aquatic Croc",
            description: "Giant predator equipped with a massive glowing dorsal sail fin & long crocodile jaws.",
            primaryColorHex: "#9B59B6",
            secondaryColorHex: "#8E44AD",
            price: 300,
            iconName: "waveform.path"
        ),
        DinoSkin(
            id: "stego_plates",
            name: "Stego Behemoth",
            species: .stegosaurus,
            bodyType: "Plate Quadruped",
            description: "4-legged armored herbivore with double-row diamond back plates and spiked thagomizer tail.",
            primaryColorHex: "#16A085",
            secondaryColorHex: "#1ABC9C",
            price: 350,
            iconName: "square.grid.3x3.fill"
        ),
        DinoSkin(
            id: "ptero_sky",
            name: "Ptero Wing-Glider",
            species: .pterodactyl,
            bodyType: "Winged Sky Hunter",
            description: "Aerodynamic glider body with giant broad wings, spear beak, and aerial talons.",
            primaryColorHex: "#E91E63",
            secondaryColorHex: "#FF80AB",
            price: 400,
            iconName: "airplane"
        ),
        DinoSkin(
            id: "cyber_mecha",
            name: "Mecha Cyber-Titan",
            species: .mecha,
            bodyType: "Robotic Mech-Walker",
            description: "Sci-fi cyborg walker with dual shoulder cannons, laser visor & twin rocket thrusters.",
            primaryColorHex: "#00F0FF",
            secondaryColorHex: "#FF007F",
            price: 450,
            iconName: "bolt.fill"
        ),
        DinoSkin(
            id: "raptor_lightning",
            name: "Lightning Raptor",
            species: .raptor,
            bodyType: "Agile Hunter",
            description: "Sleek low-slung predator with curved sickle toe claws and electric neon body stripes.",
            primaryColorHex: "#00E676",
            secondaryColorHex: "#FFEB3B",
            price: 500,
            iconName: "bolt.badge.clock.fill"
        ),
        DinoSkin(
            id: "frost_blizzard",
            name: "Glacial Frost Wyrm",
            species: .frost,
            bodyType: "Crystal Wyrm",
            description: "Frozen predator carved from sub-zero glacial ice with sharp crystal horns & spikes.",
            primaryColorHex: "#E0F7FA",
            secondaryColorHex: "#00E5FF",
            price: 550,
            iconName: "snowflake"
        ),
        DinoSkin(
            id: "magma_volcano",
            name: "Volcanic Pyre",
            species: .trex,
            bodyType: "Molten Predator",
            description: "Born from primordial volcanic magma with fiery glowing molten spines and lava eyes.",
            primaryColorHex: "#FF4500",
            secondaryColorHex: "#8B0000",
            price: 600,
            iconName: "flame.fill"
        ),
        DinoSkin(
            id: "gold_emperor",
            name: "Golden Emperor",
            species: .gold,
            bodyType: "Mythic Royal",
            description: "Solid 24K pure gold majesty with a high-luster royal crown crest.",
            primaryColorHex: "#FFD700",
            secondaryColorHex: "#FFA500",
            price: 700,
            iconName: "crown.fill"
        )
    ]
}
