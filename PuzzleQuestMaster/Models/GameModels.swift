
import SwiftUI
import Combine

struct GamePiece: Identifiable, Codable, Equatable {
    var id = UUID()
    let type: PieceType
    var value: Int
    static func == (lhs: GamePiece, rhs: GamePiece) -> Bool { return lhs.id == rhs.id && lhs.type == rhs.type }
    var emoji: String { type.emoji }
    var color: String { type.color }
}

enum PieceType: String, CaseIterable, Codable {
    case gem, crown, potion, key, treasure, shield
    var emoji: String {
        switch self {
        case .gem: return "💎"; case .crown: return "👑"; case .potion: return "🧪"
        case .key: return "🔑"; case .treasure: return "💰"; case .shield: return "🛡️"
        }
    }
    var color: String {
        switch self {
        case .gem: return "blue"; case .crown: return "yellow"; case .potion: return "purple"
        case .key: return "gray"; case .treasure: return "gold"; case .shield: return "red"
        }
    }
}

enum GameState { case playing, paused, gameOver, levelComplete }

struct Player: Codable {
    var name: String = "Player"
    var level: Int = 1
    var gems: Int = 100
    var coins: Int = 500
    var lives: Int = 5
    var completedLevels: Int = 0
    var totalStars: Int = 0
    var totalGemsEarned: Int = 100
    var bestScore: Int = 0
    var joinDate: String
    var boosters: BoosterInventory = BoosterInventory()
    init() {
        let formatter = DateFormatter(); formatter.dateStyle = .medium
        self.joinDate = formatter.string(from: Date())
    }
}

struct BoosterInventory: Codable { var bomb = 3; var shuffle = 3; var lightning = 2; var target = 2 }
enum BoosterType { case bomb, shuffle, lightning, target }

struct Reward: Identifiable, Codable {
    var id = UUID(); let type: RewardType; let amount: Int; let icon: String; let title: String; let description: String
}
enum RewardType: String, CaseIterable, Codable { case gems, coins, booster, character }

struct DailyChallenge: Identifiable, Codable {
    var id = UUID(); let title: String; let description: String; let icon: String; let target: Int; var progress: Int; var isCompleted: Bool; let reward: Reward
}
struct Achievement: Identifiable, Codable {
    var id = UUID(); let title: String; let description: String; let icon: String; let target: Int; var progress: Int; var isCompleted: Bool; let reward: Reward?
}

struct Purchase: Identifiable, Codable {
    var id = UUID()
    let title: String
    let amount: Double
    let date: String
    let isSubscription: Bool
    let productId: String
}

struct Settings: Codable {
    var notificationsEnabled = true; var soundEnabled = true; var vibrationEnabled = true; var difficulty: Difficulty = .medium; var controlType: ControlType = .touch
}
enum Difficulty: String, CaseIterable, Codable { case easy, medium, hard }
enum ControlType: String, CaseIterable, Codable { case touch, swipe }

class GameManager: ObservableObject {
    @Published var currentLevel = 1
    @Published var currentScore = 0
    @Published var targetScore = 1000
    @Published var movesLeft = 30
    @Published var gameState: GameState = .playing
    @Published var levelProgress = 0
    @Published var starsEarned = 0
    @Published var player = Player()
    @Published var settings = Settings()
    @Published var gameBoard: [[GamePiece?]] = Array(repeating: Array(repeating: nil, count: 8), count: 8)
    @Published var selectedPosition: (Int, Int)? = nil
    @Published var dailyChallenges: [DailyChallenge] = []
    @Published var achievements: [Achievement] = []
    
    // Track processing state to prevent interactions during cascades
    @Published var isProcessing = false
    
    init() {
        self.dailyChallenges = [DailyChallenge(title: "Play 5 Levels", description: "Complete 5 levels", icon: "🎮", target: 5, progress: 2, isCompleted: false, reward: Reward(type: .gems, amount: 50, icon: "💎", title: "50 Gems", description: "Reward"))]
        self.achievements = [Achievement(title: "First Steps", description: "Complete level 1", icon: "🎯", target: 1, progress: 0, isCompleted: false, reward: Reward(type: .gems, amount: 25, icon: "💎", title: "Welcome", description: "Welcome"))]
        setupGameBoard()
    }
    
    func setupGameBoard() {
        repeat { fillBoardRandomly() } while hasMatches()
        gameState = .playing
        movesLeft = 30
        currentScore = 0
    }
    
    private func fillBoardRandomly() {
        for r in 0..<8 {
            for c in 0..<8 {
                gameBoard[r][c] = GamePiece(type: PieceType.allCases.randomElement()!, value: 10)
            }
        }
    }
    
    func handleTileTap(row: Int, col: Int) {
        guard gameState == .playing, !isProcessing else { return }
        
        if let selected = selectedPosition {
            if selected == (row, col) {
                selectedPosition = nil // Deselect
            } else if isAdjacent(from: selected, to: (row, col)) {
                attemptSwap(from: selected, to: (row, col))
            } else {
                selectedPosition = (row, col) // Change selection
            }
        } else {
            selectedPosition = (row, col) // Select
        }
    }
    
    private func isAdjacent(from: (Int, Int), to: (Int, Int)) -> Bool {
        let rDiff = abs(from.0 - to.0)
        let cDiff = abs(from.1 - to.1)
        return (rDiff == 1 && cDiff == 0) || (rDiff == 0 && cDiff == 1)
    }
    
    private func attemptSwap(from: (Int, Int), to: (Int, Int)) {
        selectedPosition = nil
        isProcessing = true
        
        // 1. Swap
        swapPieces(from, to)
        
        // 2. Check for matches
        if hasMatches() {
            movesLeft -= 1
            // Process the match with a slight delay to let the swap animation play
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.processMatches()
            }
        } else {
            // Invalid move - swap back after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.swapPieces(from, to)
                self.isProcessing = false
            }
        }
    }
    
    private func swapPieces(_ p1: (Int, Int), _ p2: (Int, Int)) {
        let temp = gameBoard[p1.0][p1.1]
        gameBoard[p1.0][p1.1] = gameBoard[p2.0][p2.1]
        gameBoard[p2.0][p2.1] = temp
    }
    
    private func hasMatches() -> Bool {
        return !findMatches().isEmpty
    }
    
    private func findMatches() -> Set<String> {
        var matchedIndices = Set<String>()
        
        // Horizontal
        for r in 0..<8 {
            for c in 0..<6 {
                if let p1 = gameBoard[r][c], let p2 = gameBoard[r][c+1], let p3 = gameBoard[r][c+2],
                   p1.type == p2.type && p2.type == p3.type {
                    matchedIndices.insert("\(r),\(c)")
                    matchedIndices.insert("\(r),\(c+1)")
                    matchedIndices.insert("\(r),\(c+2)")
                }
            }
        }
        
        // Vertical
        for c in 0..<8 {
            for r in 0..<6 {
                if let p1 = gameBoard[r][c], let p2 = gameBoard[r+1][c], let p3 = gameBoard[r+2][c],
                   p1.type == p2.type && p2.type == p3.type {
                    matchedIndices.insert("\(r),\(c)")
                    matchedIndices.insert("\(r+1),\(c)")
                    matchedIndices.insert("\(r+2),\(c)")
                }
            }
        }
        
        return matchedIndices
    }
    
    private func processMatches() {
        let matches = findMatches()
        
        if matches.isEmpty {
            isProcessing = false
            if movesLeft <= 0 { gameState = .gameOver }
            else if currentScore >= targetScore { completeLevel() }
            return
        }
        
        // Remove pieces
        for index in matches {
            let components = index.split(separator: ",").map { Int($0)! }
            gameBoard[components[0]][components[1]] = nil
        }
        
        currentScore += matches.count * 10
        
        // Drop and refill after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.dropPieces()
            
            // Recursively check for new matches
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.processMatches()
            }
        }
    }
    
    private func dropPieces() {
        for c in 0..<8 {
            var newCol: [GamePiece] = []
            // Collect existing
            for r in 0..<8 {
                if let p = gameBoard[r][c] { newCol.append(p) }
            }
            // Fill top with new random
            while newCol.count < 8 {
                newCol.insert(GamePiece(type: PieceType.allCases.randomElement()!, value: 10), at: 0)
            }
            // Update board
            for r in 0..<8 {
                gameBoard[r][c] = newCol[r]
            }
        }
    }
    
    // MARK: - Boosters
    
    func useBooster(_ type: BoosterType) {
        guard gameState == .playing, !isProcessing else { return }
        
        var used = false
        switch type {
        case .bomb:
            if player.boosters.bomb > 0 {
                player.boosters.bomb -= 1
                activateBomb()
                used = true
            }
        case .shuffle:
            if player.boosters.shuffle > 0 {
                player.boosters.shuffle -= 1
                activateShuffle()
                used = true
            }
        case .lightning:
            if player.boosters.lightning > 0 {
                player.boosters.lightning -= 1
                activateLightning()
                used = true
            }
        case .target:
            if player.boosters.target > 0 {
                player.boosters.target -= 1
                activateTarget()
                used = true
            }
        }
        
        if used {
            // Check if booster caused matches
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.processMatches()
            }
        }
    }
    
    private func activateBomb() {
        // Destroy random 3x3 area or random 5 pieces
        for _ in 0..<5 {
            let r = Int.random(in: 0..<8)
            let c = Int.random(in: 0..<8)
            gameBoard[r][c] = nil
        }
        dropPieces()
    }
    
    private func activateShuffle() {
        var flatList: [GamePiece] = []
        for r in 0..<8 {
            for c in 0..<8 {
                if let p = gameBoard[r][c] { flatList.append(p) }
            }
        }
        flatList.shuffle()
        var idx = 0
        for r in 0..<8 {
            for c in 0..<8 {
                if idx < flatList.count {
                    gameBoard[r][c] = flatList[idx]
                    idx += 1
                }
            }
        }
    }
    
    private func activateLightning() {
        // Remove all pieces of a random type
        let typeToRemove = PieceType.allCases.randomElement()!
        for r in 0..<8 {
            for c in 0..<8 {
                if gameBoard[r][c]?.type == typeToRemove {
                    gameBoard[r][c] = nil
                }
            }
        }
        dropPieces()
    }
    
    private func activateTarget() {
        // If something selected, remove it. Else remove center.
        if let s = selectedPosition {
            gameBoard[s.0][s.1] = nil
            selectedPosition = nil
        } else {
            gameBoard[4][4] = nil
        }
        dropPieces()
    }
    
    func restartLevel() { currentScore = 0; movesLeft = 30; setupGameBoard() }
    func nextLevel() { currentLevel += 1; targetScore += 500; restartLevel() }
    func getPiece(at r: Int, col c: Int) -> GamePiece? { return gameBoard[r][c] }
    func completeLevel() { gameState = .levelComplete; player.completedLevels += 1 }
    func getLevelRewards() -> [Reward] { return [Reward(type: .gems, amount: 50, icon: "💎", title: "Win", description: "Win")] }
    var completedAchievements: Int { 0 }; var totalAchievements: Int { 5 }; var levelsToNextLevel: Int { 5 }
    func updateNotificationSetting(_ val: Bool) {}; func updateSoundSetting(_ val: Bool) {}; func updateVibrationSetting(_ val: Bool) {}
}
