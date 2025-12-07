
import SwiftUI

struct GameScreenView: View {
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var adManager: AdManager
    
    // Grid configuration
    let rows = 8
    let columns = 8
    let spacing: CGFloat = 4
    
    var body: some View {
        ZStack {
            backgroundView
            
            VStack(spacing: 0) {
                hudView
                Spacer()
                boardView
                Spacer()
                boostersView
            }
            
            overlayView
        }
    }
    
    // MARK: - Subviews
    
    private var backgroundView: some View {
        LinearGradient(gradient: Gradient(colors: [Color.primaryBlueDark, Color.primaryBlue]), startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }
    
    private var hudView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Level \(gameManager.currentLevel)")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Target: \(gameManager.targetScore)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            VStack {
                Text("\(gameManager.currentScore)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                        .font(.caption)
                    Text("\(gameManager.movesLeft)")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                .foregroundColor(gameManager.movesLeft < 5 ? .error500 : .white)
                .padding(8)
                .background(Color.black.opacity(0.3))
                .cornerRadius(12)
            }
        }
        .padding()
    }
    
    private var boardView: some View {
        GeometryReader { geometry in
            let width = geometry.size.width - 32 // Padding
            let itemSize = (width - (CGFloat(columns - 1) * spacing)) / CGFloat(columns)
            
            VStack(spacing: spacing) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<columns, id: \.self) { col in
                            TileView(
                                piece: gameManager.getPiece(at: row, col: col),
                                isSelected: gameManager.selectedPosition == (row, col),
                                size: itemSize
                            )
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    gameManager.handleTileTap(row: row, col: col)
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: width, height: width) // Square board
            .padding(.horizontal, 16)
            .background(Color.black.opacity(0.2))
            .cornerRadius(16)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .frame(height: UIScreen.main.bounds.width) // Constrain height to width
    }
    
    private var boostersView: some View {
        HStack(spacing: 20) {
            BoosterButton(icon: "💣", count: gameManager.player.boosters.bomb, action: { gameManager.useBooster(.bomb) })
            BoosterButton(icon: "🔀", count: gameManager.player.boosters.shuffle, action: { gameManager.useBooster(.shuffle) })
            BoosterButton(icon: "⚡️", count: gameManager.player.boosters.lightning, action: { gameManager.useBooster(.lightning) })
            BoosterButton(icon: "🎯", count: gameManager.player.boosters.target, action: { gameManager.useBooster(.target) })
        }
        .padding(.bottom, 30)
    }
    
    @ViewBuilder
    private var overlayView: some View {
        if gameManager.gameState == .levelComplete {
            LevelCompleteOverlay(score: gameManager.currentScore, stars: 3) {
                adManager.showInterstitial()
                gameManager.nextLevel()
            }
        } else if gameManager.gameState == .gameOver {
            GameOverOverlay {
                adManager.showInterstitial()
                gameManager.restartLevel()
            }
        }
    }
}

// Subcomponents

struct TileView: View {
    let piece: GamePiece?
    let isSelected: Bool
    let size: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(piece != nil ? colorForPiece(piece!.type) : Color.clear)
                .opacity(piece == nil ? 0 : 1)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
            
            if let piece = piece {
                Text(piece.emoji)
                    .font(.system(size: size * 0.6))
            }
        }
        .frame(width: size, height: size)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
        )
        .scaleEffect(isSelected ? 1.1 : 1.0)
    }
    
    func colorForPiece(_ type: PieceType) -> Color {
        switch type {
        case .gem: return .blue.opacity(0.8)
        case .crown: return .yellow.opacity(0.8)
        case .potion: return .purple.opacity(0.8)
        case .key: return .gray.opacity(0.8)
        case .treasure: return .orange.opacity(0.8)
        case .shield: return .red.opacity(0.8)
        }
    }
}

struct BoosterButton: View {
    let icon: String
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Text(icon)
                        .font(.title)
                    
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 5, y: 5)
                }
            }
        }
        .buttonStyle(BounceButtonStyle())
    }
}

struct LevelCompleteOverlay: View {
    let score: Int
    let stars: Int
    let onNext: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Level Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                HStack {
                    ForEach(0..<3) { i in
                        Image(systemName: i < stars ? "star.fill" : "star")
                            .font(.system(size: 40))
                            .foregroundColor(.yellow)
                    }
                }
                
                Text("Score: \(score)")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Button(action: onNext) {
                    Text("Next Level")
                        .font(.headline)
                        .foregroundColor(.primaryBlue)
                        .padding()
                        .frame(width: 200)
                        .background(Color.white)
                        .cornerRadius(25)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding()
            .background(Color.primaryBlueDark)
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(40)
        }
    }
}

struct GameOverOverlay: View {
    let onRestart: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Out of Moves!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("😢")
                    .font(.system(size: 60))
                
                Button(action: onRestart) {
                    Text("Try Again")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200)
                        .background(Color.error500)
                        .cornerRadius(25)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding()
            .background(Color.neutral900)
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(40)
        }
    }
}
