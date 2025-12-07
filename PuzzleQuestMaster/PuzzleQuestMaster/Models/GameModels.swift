import SwiftUI
import Combine


struct GamePiece: Identifiable, Codable, Equatable {
    let id = UUID()
    let type: PieceType
    var value: Int
    
    static func == (lhs: GamePiece, rhs: GamePiece) -> Bool {
        return lhs.id == rhs.id && lhs.type == rhs.type
    }
    
    var emoji: String { type.emoji }
    var color: String { type.color }
}

enum PieceType: String, CaseIterable, Codable {
    case gem, crown, potion, key, treasure, shield
    
    var emoji: String {
        switch self {
        case .gem: return "💎"
        case .crown: return "👑"
        case .potion: return "🧪"
        case .key: return "🔑"
        case .treasure: return "💰"
        case .shield: return "🛡️"
        }
    }
    
    var color: String {
        switch self {
        case .gem: return "blue"
        case .crown: return "yellow"
        case .potion: return "purple"
        case .key: return "gray"
        case .treasure: return "gold"
        case .shield: return "red"
        }
    }
}

enum GameState {
    case playing, paused, gameOver, levelComplete
}

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
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        self.joinDate = formatter.string(from: Date())
    }
}

struct BoosterInventory: Codable {
    var bomb: Int = 3
    var shuffle: Int = 3
    var lightning: Int = 2
    var target: Int = 2
}

enum BoosterType { case bomb, shuffle, lightning, target }

struct Reward: Identifiable, Codable {
    let id = UUID()
    let type: RewardType
    let amount: Int
    let icon: String
    let title: String
    let description: String
}

enum RewardType: String, CaseIterable, Codable {
    case gems = "gems"
    case coins = "coins"
    case booster = "booster"
    case character = "character"
}

struct DailyChallenge: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let target: Int
    let progress: Int
    let isCompleted: Bool
    let reward: Reward
}

struct Achievement: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let target: Int
    let progress: Int
    let isCompleted: Bool
    let reward: Reward?
}

struct Settings: Codable {
    var notificationsEnabled: Bool = true
    var soundEnabled: Bool = true
    var vibrationEnabled: Bool = true
    var difficulty: Difficulty = .medium
    var controlType: ControlType = .touch
}

enum Difficulty: String, CaseIterable, Codable { case easy, medium, hard }
enum ControlType: String, CaseIterable, Codable { case touch, swipe }


class GameManager: ObservableObject {
    @Published var currentLevel: Int = 1
    @Published var currentScore: Int = 0
    @Published var targetScore: Int = 1000
    @Published var movesLeft: Int = 30
    @Published var gameState: GameState = .playing
    @Published var levelProgress: Int = 0
    @Published var starsEarned: Int = 0
    
    @Published var player: Player
    @Published var settings: Settings
    
    @Published var gameBoard: [[GamePiece?]] = Array(repeating: Array(repeating: nil, count: 8), count: 8)
    @Published var selectedPosition: (Int, Int)? = nil
    
    @Published var dailyChallenges: [DailyChallenge] = []
    @Published var achievements: [Achievement] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.player = Player()
        self.settings = Settings()
        
        self.dailyChallenges = [
            DailyChallenge(title: "Play 5 Levels", description: "Complete 5 levels", icon: "🎮", target: 5, progress: 2, isCompleted: false, reward: Reward(type: .gems, amount: 50, icon: "💎", title: "50 Gems", description: "Reward"))
        ]
        self.achievements = [
            Achievement(title: "First Steps", description: "Complete level 1", icon: "🎯", target: 1, progress: 0, isCompleted: false, reward: Reward(type: .gems, amount: 25, icon: "💎", title: "Welcome", description: "Welcome"))
        ]
        
        setupGameBoard()
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(forName: .didPurchaseGems, object: nil, queue: .main) { [weak self] notification in
            if let amount = notification.userInfo?["amount"] as? Int {
                self?.player.gems += amount
                self?.player.totalGemsEarned += amount
            }
        }
    }
    
    
    func setupGameBoard() {
        repeat {
            fillBoardRandomly()
        } while hasMatches()
        gameState = .playing
    }
    
    private func fillBoardRandomly() {
        for row in 0..<8 {
            for col in 0..<8 {
                gameBoard[row][col] = GamePiece(
                    type: PieceType.allCases.randomElement()!,
                    value: 10
                )
            }
        }
    }
    
    func handleTileTap(row: Int, col: Int) {
        guard gameState == .playing else { return }
        let position = (row, col)
        
        if let selected = selectedPosition {
            if selected == position {
                selectedPosition = nil
            } else {
                if isAdjacent(from: selected, to: position) {
                    attemptSwap(from: selected, to: position)
                } else {
                    selectedPosition = position
                }
            }
        } else {
            selectedPosition = position
        }
    }
    
    private func isAdjacent(from: (Int, Int), to: (Int, Int)) -> Bool {
        let rDiff = abs(from.0 - to.0)
        let cDiff = abs(from.1 - to.1)
        return (rDiff == 1 && cDiff == 0) || (rDiff == 0 && cDiff == 1)
    }
    
    private func attemptSwap(from: (Int, Int), to: (Int, Int)) {
        swapPiecesInArray(from, to)
        
        if hasMatches() {
            movesLeft -= 1
            selectedPosition = nil
            processMatches()
        } else {
            swapPiecesInArray(from, to)
            selectedPosition = nil
        }
    }
    
    private func swapPiecesInArray(_ p1: (Int, Int), _ p2: (Int, Int)) {
        let temp = gameBoard[p1.0][p1.1]
        gameBoard[p1.0][p1.1] = gameBoard[p2.0][p2.1]
        gameBoard[p2.0][p2.1] = temp
    }
    
    private func hasMatches() -> Bool {
        for row in 0..<8 {
            for col in 0..<6 {
                if let p1 = gameBoard[row][col], let p2 = gameBoard[row][col+1], let p3 = gameBoard[row][col+2],
                   p1.type == p2.type && p2.type == p3.type {
                    return true
                }
            }
        }
        for col in 0..<8 {
            for row in 0..<6 {
                if let p1 = gameBoard[row][col], let p2 = gameBoard[row+1][col], let p3 = gameBoard[row+2][col],
                   p1.type == p2.type && p2.type == p3.type {
                    return true
                }
            }
        }
        return false
    }
    
    private func processMatches() {
        var matchedPositions: Set<String> = [] // Using string keys "r,c" for simplicity
        
        for row in 0..<8 {
            for col in 0..<6 {
                if let p1 = gameBoard[row][col], let p2 = gameBoard[row][col+1], let p3 = gameBoard[row][col+2],
                   p1.type == p2.type && p2.type == p3.type {
                    matchedPositions.insert("\(row),\(col)")
                    matchedPositions.insert("\(row),\(col+1)")
                    matchedPositions.insert("\(row),\(col+2)")
                }
            }
        }
        
        for col in 0..<8 {
            for row in 0..<6 {
                if let p1 = gameBoard[row][col], let p2 = gameBoard[row+1][col], let p3 = gameBoard[row+2][col],
                   p1.type == p2.type && p2.type == p3.type {
                    matchedPositions.insert("\(row),\(col)")
                    matchedPositions.insert("\(row+1),\(col)")
                    matchedPositions.insert("\(row+2),\(col)")
                }
            }
        }
        
        if matchedPositions.isEmpty {
            if movesLeft <= 0 && currentScore < targetScore {
                gameState = .gameOver
            } else if currentScore >= targetScore {
                starsEarned = calculateStars()
                gameState = .levelComplete
                completeLevel()
            }
            return
        }
        
        currentScore += matchedPositions.count * 10
        for pos in matchedPositions {
            let components = pos.split(separator: ",").map { Int($0)! }
            gameBoard[components[0]][components[1]] = nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.dropPieces()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.processMatches()
            }
        }
    }
    
    private func dropPieces() {
        for col in 0..<8 {
            var newColumn: [GamePiece] = []
            for row in 0..<8 {
                if let piece = gameBoard[row][col] {
                    newColumn.append(piece)
                }
            }
            let missing = 8 - newColumn.count
            for _ in 0..<missing {
                newColumn.insert(GamePiece(type: PieceType.allCases.randomElement()!, value: 10), at: 0)
            }
            for row in 0..<8 {
                gameBoard[row][col] = newColumn[row]
            }
        }
    }
    
    
    func useBooster(_ type: BoosterType) {
        guard gameState == .playing else { return }
        
        switch type {
        case .bomb:
            if player.boosters.bomb > 0 {
                player.boosters.bomb -= 1
                activateBomb()
            }
        case .shuffle:
            if player.boosters.shuffle > 0 {
                player.boosters.shuffle -= 1
                setupGameBoard()
            }
        case .lightning:
            if player.boosters.lightning > 0 {
                player.boosters.lightning -= 1
                activateLightning()
            }
        case .target:
            break
        }
    }
    
    private func activateBomb() {
        for r in 3...5 {
            for c in 3...5 {
                gameBoard[r][c] = nil
            }
        }
        currentScore += 90
        dropPieces()
    }
    
    private func activateLightning() {
        let targetType = PieceType.allCases.randomElement()!
        for r in 0..<8 {
            for c in 0..<8 {
                if gameBoard[r][c]?.type == targetType {
                    gameBoard[r][c] = nil
                    currentScore += 10
                }
            }
        }
        dropPieces()
    }

    func restartLevel() {
        currentScore = 0
        movesLeft = 30
        starsEarned = 0
        setupGameBoard()
    }
    
    func nextLevel() {
        currentLevel += 1
        targetScore += 500
        restartLevel()
    }
    
    func getPiece(at row: Int, col: Int) -> GamePiece? {
        if row < 0 || row >= 8 || col < 0 || col >= 8 { return nil }
        return gameBoard[row][col]
    }
    
    private func calculateStars() -> Int {
        let ratio = Double(currentScore) / Double(targetScore)
        if ratio > 1.5 { return 3 }
        if ratio > 1.2 { return 2 }
        return 1
    }
    
    func completeLevel() {
        player.completedLevels += 1
        player.totalStars += starsEarned
        levelProgress += 10
        if levelProgress >= 100 { levelProgress = 0 }
    }
    
    func updateNotificationSetting(_ val: Bool) { settings.notificationsEnabled = val }
    func updateSoundSetting(_ val: Bool) { settings.soundEnabled = val }
    func updateVibrationSetting(_ val: Bool) { settings.vibrationEnabled = val }
    
    var completedAchievements: Int { achievements.filter { $0.isCompleted }.count }
    var totalAchievements: Int { achievements.count }
    var levelsToNextLevel: Int { 5 }
    
    func getLevelRewards() -> [Reward] {
        return [Reward(type: .gems, amount: 25 * starsEarned, icon: "💎", title: "Level Clear", description: "Reward")]
    }
}
