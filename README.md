# 🦖 Dino Runner 3D

> A **Temple Run–style 3D endless runner** built natively in Swift using **SceneKit + SwiftUI**.  
> Run, dodge, jump and collect coins as your dinosaur charges through an infinite desert track.

<br>

## 📱 Screenshots

<p align="center">
  <img src="assets/Simulator Screenshot - iPhone 17 Pro - 2026-10-01 at 15.48.28.png" width="18%" alt="Home Screen" />
  <img src="assets/Simulator Screenshot - iPhone 17 Pro - 2026-10-01 at 15.48.32.png" width="18%" alt="3D Gameplay" />
  <img src="assets/Simulator Screenshot - iPhone 17 Pro - 2026-10-01 at 15.49.21.png" width="18%" alt="Dino Shop" />
  <img src="assets/Simulator Screenshot - iPhone 17 Pro - 2026-10-01 at 15.48.56.png" width="18%" alt="High Scores" />
  <img src="assets/Simulator Screenshot - iPhone 17 Pro - 2026-10-01 at 15.49.01.png" width="18%" alt="Settings" />
</p>

<br>

## 🎮 How to Play

### Controls

| Action | How |
|--------|-----|
| **Move Left** | Tap `←` button  _or_ swipe left |
| **Move Right** | Tap `→` button  _or_ swipe right |
| **Jump** | Tap `JUMP` button  _or_ swipe up |
| **Slide / Duck** | Tap `SLIDE` button  _or_ swipe down |
| **Pause** | Tap `⏸` in the top-right corner |

### Objective

- Your dinosaur runs **automatically** — you just dodge and survive
- **Avoid** the rock/spike obstacles in your lane
- **Collect** yellow coins 🟡 scattered on the track
- The longer you survive, the **faster** the game gets
- Beat your **high score** each run!

### Scoring

| Action | Points |
|--------|--------|
| Running distance | `distance × 0.8` pts |
| Collecting a coin | +bonus coins added to wallet |
| Surviving longer | Speed increases → more pts/sec |

### 3-Lane System

The track has **3 lanes** (Left · Center · Right). Swipe or tap the arrow buttons to shift your dino between lanes smoothly. Your character **leans naturally** into each turn — just like Temple Run!

```
  LEFT     CENTER    RIGHT
  [ ← ]    [  ●  ]   [ → ]
```

### Power-Ups & Shield

- 🛡️ **Shield** — absorbs one obstacle hit
- Buy upgrades in the **Dino Shop** before your run

<br>

## 🛒 Dino Shop

Tap **Dino Shop** on the home screen to access:

- **12 Dinosaur Skins** — each with unique body shape, color & style  
  (T-Rex, Triceratops, Raptor, Stegosaurus, and more!)
- **Power-Ups** — shield, magnet, score multiplier
- **Treasury Airdrop** — claim free coins to unlock skins faster

<br>

## 📊 Features

- ✅ Full **3D SceneKit** render engine with chase camera
- ✅ **12 unique dinosaur species** with different body models
- ✅ Smooth **phase-accumulator locomotion** animation (no jitter)
- ✅ **Haptic feedback** on jump, collision and coin collect
- ✅ **8-bit retro sound effects**
- ✅ **Missions system** with claimable rewards
- ✅ Career stats — total runs, obstacles cleared, gold collected
- ✅ **Rank progression** system (Desert Sprinter → Apex Predator)
- ✅ 4× MSAA antialiasing for smooth 3D edges

<br>

## 🏗️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Language | Swift 5.x |
| 3D Engine | Apple SceneKit |
| UI | SwiftUI |
| Minimum iOS | iOS 26.0 |
| Target Device | iPhone |

<br>

## 🚀 Getting Started

\`\`\`bash
# Clone the repo
git clone https://github.com/Arda-Lyhu/dino_game.git
cd dino_game

# Open in Xcode
open LearnSwiftApp.xcodeproj
\`\`\`

1. Select the **LearnSwiftApp** scheme
2. Choose **iPhone 17** (or any iOS 26.0+ simulator)
3. Press `⌘ + R` to build and run

<br>

## 📁 Project Structure

\`\`\`
LearnSwiftApp/
├── Engine/
│   ├── Dino3DScene.swift      # Core game loop, lane system, physics
│   └── Dino3DBuilder.swift    # 3D dinosaur mesh builder (12 species)
├── Views/
│   ├── DinosaurFlowView.swift # Home screen & navigation
│   ├── Dino3DRunnerView.swift # In-game HUD & gesture controls
│   ├── DinoShopView.swift     # Shop & skin selector
│   └── DinoMissionsView.swift # Missions & rewards
├── Models/
│   └── DinoSkin.swift         # Skin data model (12 species)
├── Managers/
│   └── DinoGameManager.swift  # Score, progress, persistence
└── Services/
    └── AudioService.swift     # Sound effects & haptics
\`\`\`

<br>

---

<p align="center">Made with 🦖 and Swift</p>
