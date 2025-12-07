import SwiftUI

struct GameScreenView: View {
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var monetizationManager: MonetizationManager
    @EnvironmentObject var adManager: AdManager
    
    @State private var showPauseMenu = false
    @State private var showGameOver = false
    @State private var showLevelComplete = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                GameHeaderView(
                    level: gameManager.currentLevel,
                    moves: gameManager.movesLeft,
                    score: gameManager.currentScore,
                    target: gameManager.targetScore,
                    showPause: { showPauseMenu = true }
                )
                
                GameBoardView()
                    .frame(
                        width: min(geometry.size.width - 32, geometry.size.height * 0.6),
                        height: min(geometry.size.width - 32, geometry.size.height * 0.6)
                    )
                    .padding(.horizontal, 16)
                
                GameControlsView()
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
            }
            .background(Color.neutral50)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showPauseMenu) {
            PauseMenuView(
                onResume: { showPauseMenu = false },
                onRestart: { gameManager.restartLevel(); showPauseMenu = false },
                onHome: { showPauseMenu = false }
            )
        }
        .sheet(isPresented: $showLevelComplete) {
            LevelCompleteView(
                score: gameManager.currentScore,
                target: gameManager.targetScore,
                starsEarned: gameManager.starsEarned,
                rewards: gameManager.getLevelRewards(),
                onNext: { 
                    adManager.showInterstitial()
                    
                    gameManager.nextLevel()
                    showLevelComplete = false 
                },
                onReplay: { gameManager.restartLevel(); showLevelComplete = false }
            )
        }
        .onReceive(gameManager.$gameState) { state in
            if state == .levelComplete { showLevelComplete = true }
            if state == .gameOver { showGameOver = true }
        }
    }
}

struct GameHeaderView: View {
    let level: Int
    let moves: Int
    let score: Int
    let target: Int
    let showPause: () -> Void
    
    var body: some View {
        HStack {
            Button(action: showPause) {
                Image(systemName: "pause.circle.fill").font(.title2)
            }
            Spacer()
            VStack {
                Text("Level \(level)").font(.headline)
                ProgressView(value: Double(score), total: Double(target))
                    .frame(width: 100)
            }
            Spacer()
            VStack {
                Image(systemName: "heart.fill").foregroundColor(.red)
                Text("\(moves)")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding()
    }
}

struct GameBoardView: View {
    @EnvironmentObject var gameManager: GameManager
    let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 8)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(0..<64, id: \.self) { index in
                let row = index / 8
                let col = index % 8
                GameTileView(
                    piece: gameManager.getPiece(at: row, col: col),
                    isSelected: gameManager.selectedPosition == (row, col),
                    onTap: { gameManager.handleTileTap(row: row, col: col) }
                )
            }
        }
        .background(Color.neutral900.opacity(0.1))
        .cornerRadius(8)
    }
}

struct GameTileView: View {
    let piece: GamePiece?
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(isSelected ? Color.blue.opacity(0.3) : Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(isSelected ? Color.blue : Color.gray.opacity(0.2)))
                
                if let piece = piece {
                    Text(piece.emoji).font(.system(size: 30))
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct GameControlsView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        HStack {
            ForEach([BoosterType.bomb, .shuffle, .lightning, .target], id: \.self) { type in
                Button(action: { gameManager.useBooster(type) }) {
                    VStack {
                        Text(iconFor(type)).font(.title)
                        Text(countFor(type)).font(.caption).foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(8)
                }
            }
        }
    }
    
    func iconFor(_ type: BoosterType) -> String {
        switch type {
        case .bomb: return "💣"
        case .shuffle: return "🔄"
        case .lightning: return "⚡"
        case .target: return "🎯"
        }
    }
    
    func countFor(_ type: BoosterType) -> String {
        switch type {
        case .bomb: return "\(gameManager.player.boosters.bomb)"
        case .shuffle: return "\(gameManager.player.boosters.shuffle)"
        case .lightning: return "\(gameManager.player.boosters.lightning)"
        case .target: return "\(gameManager.player.boosters.target)"
        }
    }
}

struct PauseMenuView: View {
    let onResume: () -> Void
    let onRestart: () -> Void
    let onHome: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Paused").font(.largeTitle)
            Button("Resume", action: onResume)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            
            Button("Restart Level", action: onRestart)
            Button("Return to Home", action: onHome)
        }
    }
}

struct LevelCompleteView: View {
    let score: Int
    let target: Int
    let starsEarned: Int
    let rewards: [Reward]
    let onNext: () -> Void
    let onReplay: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🎉 Level Complete!").font(.largeTitle)
            HStack {
                ForEach(0..<starsEarned, id: \.self) { _ in Text("⭐").font(.largeTitle) }
            }
            Text("Score: \(score) / \(target)")
            
            Button("Next Level", action: onNext)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .font(.headline)
            
            Button("Replay", action: onReplay)
                .foregroundColor(.blue)
        }
        .padding()
    }
}
