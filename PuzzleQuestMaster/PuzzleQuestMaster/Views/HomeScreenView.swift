import SwiftUI

struct HomeScreenView: View {
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var monetizationManager: MonetizationManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    WelcomeHeader()
                    
                    PlayerStatsCard()
                    
                    DailyChallengesSection()
                    
                    CurrentLevelProgress()
                    
                    QuickActionsGrid()
                    
                    SpecialOffersBanner()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Puzzle Quest Master")
                        .font(.title2.bold())
                        .foregroundColor(.primaryBlue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.primaryBlue)
                    }
                }
            }
        }
    }
}

struct WelcomeHeader: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back!")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.neutral900)
                
                Text("Ready for your next puzzle adventure?")
                    .font(.body)
                    .foregroundColor(.neutral700)
            }
            
            Spacer()
            
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.primaryBlue, .accentGold],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
                .overlay {
                    Text("🎭")
                        .font(.title2)
                }
        }
        .padding(20)
        .background(Color.neutral100)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .primaryBlue.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct PlayerStatsCard: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Stats")
                .font(.title3.weight(.semibold))
                .foregroundColor(.neutral900)
            
            HStack(spacing: 20) {
                StatItem(icon: "💎", title: "Gems", value: "\(gameManager.player.gems)")
                
                StatItem(icon: "💰", title: "Coins", value: "\(gameManager.player.coins)")
                
                StatItem(icon: "❤️", title: "Lives", value: "\(gameManager.player.lives)/5")
            }
        }
        .padding(20)
        .background(Color.neutral100)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .primaryBlue.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.title2)
            
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundColor(.neutral700)
            
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundColor(.neutral900)
        }
        .frame(maxWidth: .infinity)
    }
}

struct DailyChallengesSection: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Daily Challenges")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.neutral900)
                
                Spacer()
                
                Text("View All")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.primaryBlue)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(gameManager.dailyChallenges.prefix(3), id: \.id) { challenge in
                    ChallengeRowView(challenge: challenge)
                }
            }
        }
        .padding(20)
        .background(Color.neutral100)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .primaryBlue.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct ChallengeRowView: View {
    let challenge: DailyChallenge
    
    var body: some View {
        HStack {
            Text(challenge.icon)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(challenge.title)
                    .font(.body.weight(.medium))
                    .foregroundColor(.neutral900)
                
                Text(challenge.description)
                    .font(.caption)
                    .foregroundColor(.neutral700)
            }
            
            Spacer()
            
            if challenge.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.success500)
                    .font(.title2)
            } else {
                ProgressView(value: challenge.progress, total: Double(challenge.target))
                    .scaleEffect(CGSize(width: 1.0, height: 1.5))
            }
        }
    }
}

struct CurrentLevelProgress: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Progress")
                .font(.title3.weight(.semibold))
                .foregroundColor(.neutral900)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Level \(gameManager.currentLevel)")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.neutral900)
                    
                    Spacer()
                    
                    Text("\(gameManager.levelProgress)%")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.neutral700)
                }
                
                ProgressView(value: Double(gameManager.levelProgress), total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: .primaryBlue))
                
                Text("Complete \(gameManager.levelsToNextLevel) more levels to unlock new characters!")
                    .font(.caption)
                    .foregroundColor(.neutral700)
            }
        }
        .padding(20)
        .background(Color.neutral100)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .primaryBlue.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct QuickActionsGrid: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.title3.weight(.semibold))
                .foregroundColor(.neutral900)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                QuickActionButton(
                    icon: "🎮",
                    title: "Play",
                    subtitle: "Continue Level",
                    color: .primaryBlue
                ) {
                }
                
                QuickActionButton(
                    icon: "🎁",
                    title: "Rewards",
                    subtitle: "Daily Gift",
                    color: .accentGold
                ) {
                }
                
                QuickActionButton(
                    icon: "👥",
                    title: "Guild",
                    subtitle: "Join Friends",
                    color: .success500
                ) {
                }
                
                QuickActionButton(
                    icon: "🏆",
                    title: "Events",
                    subtitle: "Special Events",
                    color: .error500
                ) {
                }
            }
        }
        .padding(20)
        .background(Color.neutral100)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .primaryBlue.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(icon)
                    .font(.title2)
                
                Text(title)
                    .font(.body.weight(.bold))
                    .foregroundColor(color)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.neutral700)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct SpecialOffersBanner: View {
    @EnvironmentObject var monetizationManager: MonetizationManager
    
    var body: some View {
        Button {
            monetizationManager.showRoyalPassOffer = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🎯 LIMITED TIME")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)
                    
                    Text("Get the Royal Pass!")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.white)
                    
                    Text("Exclusive rewards & bonuses")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("$9.99")
                        .font(.title3.weight(.bold))
                        .foregroundColor(.white)
                    
                    Text("SAVE 50%")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.3))
                        .clipShape(Capsule())
                }
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [.primaryBlue, .accentGold],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    HomeScreenView()
        .environmentObject(GameManager())
        .environmentObject(MonetizationManager())
        .environmentObject(AdManager())
}