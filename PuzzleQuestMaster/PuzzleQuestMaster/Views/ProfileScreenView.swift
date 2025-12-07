import SwiftUI

struct ProfileScreenView: View {
    @EnvironmentObject var gameManager: GameManager
    @EnvironmentObject var monetizationManager: MonetizationManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    ProfileHeaderView()
                    
                    PlayerStatisticsView()
                    
                    AchievementsSection()
                    
                    SettingsSection()
                    
                    MonetizationSection()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ProfileHeaderView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.primaryBlue, .accentGold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Text("🎭")
                        .font(.title)
                }
                .shadow(color: .primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(gameManager.player.name)
                        .font(.title2.weight(.bold))
                        .foregroundColor(.neutral900)
                    
                    HStack {
                        Text("Level \(gameManager.player.level)")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.primaryBlue)
                        
                        Text("•")
                            .foregroundColor(.neutral400)
                        
                        Text("\(gameManager.player.totalStars) Stars")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.accentGold)
                    }
                    
                    Text("Joined \(gameManager.player.joinDate)")
                        .font(.caption)
                        .foregroundColor(.neutral700)
                }
                
                Spacer()
            }
            
            HStack(spacing: 20) {
                QuickStatItem(
                    icon: "🎮",
                    title: "Levels",
                    value: "\(gameManager.player.completedLevels)"
                )
                
                QuickStatItem(
                    icon: "💎",
                    title: "Total Gems",
                    value: "\(gameManager.player.totalGemsEarned)"
                )
                
                QuickStatItem(
                    icon: "🏆",
                    title: "Best Score",
                    value: "\(gameManager.player.bestScore)"
                )
            }
            .padding(16)
            .background(Color.neutral100)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(20)
        .background(Color.neutral100)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .primaryBlue.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct QuickStatItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(icon)
                .font(.title3)
            
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundColor(.neutral900)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.neutral700)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PlayerStatisticsView: View {
    @EnvironmentObject var gameManager: GameManager
    
    private let stats = [
        ("🎯", "Accuracy", "85%", Color.success500),
        ("⏱️", "Avg. Time", "3:24", Color.primaryBlue),
        ("🔥", "Streak", "12 days", Color.accentGold),
        ("💎", "Gems Spent", "2,450", Color.error500),
        ("🏆", "High Score", "15,680", Color.success500),
        ("📱", "Play Time", "24h 15m", Color.primaryBlue)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📊 Player Statistics")
                .font(.title2.weight(.bold))
                .foregroundColor(.neutral900)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(0..<stats.count, id: \.self) { index in
                    let stat = stats[index]
                    StatisticCard(
                        icon: stat.0,
                        title: stat.1,
                        value: stat.2,
                        color: stat.3
                    )
                }
            }
        }
        .padding(20)
        .background(Color.neutral100)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .primaryBlue.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct StatisticCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Text(icon)
                .font(.title2)
            
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundColor(.neutral700)
                .multilineTextAlignment(.center)
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
}

struct AchievementsSection: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("🏆 Achievements")
                    .font(.title2.weight(.bold))
                    .foregroundColor(.neutral900)
                
                Spacer()
                
                Text("View All")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.primaryBlue)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(gameManager.achievements.prefix(4), id: \.id) { achievement in
                    AchievementRowView(achievement: achievement)
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Overall Progress")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.neutral900)
                    
                    Spacer()
                    
                    Text("\(gameManager.completedAchievements)/\(gameManager.totalAchievements)")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.primaryBlue)
                }
                
                ProgressView(value: Double(gameManager.completedAchievements), total: Double(gameManager.totalAchievements))
                    .progressViewStyle(LinearProgressViewStyle(tint: .primaryBlue))
                
                Text("Complete more achievements to unlock exclusive rewards!")
                    .font(.caption)
                    .foregroundColor(.neutral700)
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .background(Color.neutral100)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .primaryBlue.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct AchievementRowView: View {
    let achievement: Achievement
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(achievement.isCompleted ? Color.success500 : Color.neutral300)
                    .frame(width: 40, height: 40)
                
                Text(achievement.icon)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.body.weight(.medium))
                    .foregroundColor(.neutral900)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.neutral700)
                
                ProgressView(value: Double(achievement.progress), total: Double(achievement.target))
                    .progressViewStyle(LinearProgressViewStyle(tint: achievement.isCompleted ? .success500 : .primaryBlue))
                    .scaleEffect(CGSize(width: 1.0, height: 1.5))
            }
            
            Spacer()
            
            if achievement.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.success500)
                    .font(.title2)
            }
        }
    }
}

struct SettingsSection: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("⚙️ Settings")
                .font(.title2.weight(.bold))
                .foregroundColor(.neutral900)
            
            LazyVStack(spacing: 12) {
                SettingsRow(
                    icon: "🔔",
                    title: "Notifications",
                    subtitle: "Daily challenges & events",
                    hasToggle: true,
                    isOn: gameManager.settings.notificationsEnabled
                ) { enabled in
                    gameManager.updateNotificationSetting(enabled)
                }
                
                SettingsRow(
                    icon: "🔊",
                    title: "Sound Effects",
                    subtitle: "Game sounds & music",
                    hasToggle: true,
                    isOn: gameManager.settings.soundEnabled
                ) { enabled in
                    gameManager.updateSoundSetting(enabled)
                }
                
                SettingsRow(
                    icon: "📱",
                    title: "Vibration",
                    subtitle: "Haptic feedback",
                    hasToggle: true,
                    isOn: gameManager.settings.vibrationEnabled
                ) { enabled in
                    gameManager.updateVibrationSetting(enabled)
                }
                
                NavigationLink(destination: GameSettingsView()) {
                    SettingsRow(
                        icon: "🎮",
                        title: "Gameplay Settings",
                        subtitle: "Difficulty & controls",
                        hasToggle: false,
                        isOn: false,
                        action: nil
                    )
                }
                
                NavigationLink(destination: PrivacySettingsView()) {
                    SettingsRow(
                        icon: "🔒",
                        title: "Privacy & Data",
                        subtitle: "Account & data management",
                        hasToggle: false,
                        isOn: false,
                        action: nil
                    )
                }
            }
        }
        .padding(20)
        .background(Color.neutral100)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .primaryBlue.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let hasToggle: Bool
    let isOn: Bool
    let action: ((Bool) -> Void)?
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color.primaryBlue.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Text(icon)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundColor(.neutral900)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.neutral700)
            }
            
            Spacer()
            
            if hasToggle {
                Toggle("", isOn: Binding(
                    get: { isOn },
                    set: { action?($0) }
                ))
                .labelsHidden()
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(.neutral400)
                    .font(.caption)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct MonetizationSection: View {
    @EnvironmentObject var monetizationManager: MonetizationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("💰 Monetization")
                .font(.title2.weight(.bold))
                .foregroundColor(.neutral900)
            
            if monetizationManager.isRoyalPassActive {
                RoyalPassStatusDetailView()
            } else {
                RoyalPassOfferCompactView()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("📋 Purchase History")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.neutral900)
                    
                    Spacer()
                    
                    Text("View All")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.primaryBlue)
                }
                
                if monetizationManager.recentPurchases.isEmpty {
                    Text("No purchases yet")
                        .font(.caption)
                        .foregroundColor(.neutral700)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(monetizationManager.recentPurchases.prefix(3), id: \.id) { purchase in
                            PurchaseHistoryRow(purchase: purchase)
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            if monetizationManager.hasActiveSubscription {
                Button {
                } label: {
                    HStack {
                        Text("🔄 Manage Subscription")
                            .font(.headline.weight(.medium))
                            .foregroundColor(.primaryBlue)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.neutral400)
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primaryBlue, lineWidth: 2)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(20)
        .background(Color.neutral100)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .primaryBlue.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct RoyalPassStatusDetailView: View {
    @EnvironmentObject var monetizationManager: MonetizationManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🏰")
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Royal Pass Active")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.success500)
                    
                    Text("Expires: \(monetizationManager.royalPassExpiryDate)")
                        .font(.caption)
                        .foregroundColor(.neutral700)
                }
                
                Spacer()
                
                Text("ACTIVE")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.success500)
                    .clipShape(Capsule())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Monthly Rewards Progress")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.neutral700)
                    
                    Spacer()
                    
                    Text("1,247/1500 gems")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.primaryBlue)
                }
                
                ProgressView(value: 1247, total: 1500)
                    .progressViewStyle(LinearProgressViewStyle(tint: .primaryBlue))
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [.success500.opacity(0.1), .primaryBlue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct RoyalPassOfferCompactView: View {
    @EnvironmentObject var monetizationManager: MonetizationManager
    
    var body: some View {
        Button {
            monetizationManager.showRoyalPassOffer = true
        } label: {
            HStack {
                Text("🏰")
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unlock Royal Pass")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.neutral900)
                    
                    Text("Get premium benefits & exclusive rewards")
                        .font(.caption)
                        .foregroundColor(.neutral700)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("$9.99")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.primaryBlue)
                    
                    Text("/month")
                        .font(.caption)
                        .foregroundColor(.neutral700)
                }
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [.primaryBlue.opacity(0.1), .accentGold.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.accentGold, lineWidth: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct PurchaseHistoryRow: View {
    let purchase: Purchase
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(purchase.title)
                    .font(.body.weight(.medium))
                    .foregroundColor(.neutral900)
                
                Text(purchase.date)
                    .font(.caption)
                    .foregroundColor(.neutral700)
            }
            
            Spacer()
            
            Text("$\(String(format: "%.2f", purchase.amount))")
                .font(.headline.weight(.bold))
                .foregroundColor(.primaryBlue)
            
            if purchase.isSubscription {
                Text("SUBSCRIPTION")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.success500)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.success500.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding(12)
        .background(Color.neutral50)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct GameSettingsView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        List {
            Section("Gameplay") {
                Picker("Difficulty", selection: $gameManager.settings.difficulty) {
                    Text("Easy").tag(Difficulty.easy)
                    Text("Medium").tag(Difficulty.medium)
                    Text("Hard").tag(Difficulty.hard)
                }
                
                Toggle("Auto-save progress", isOn: $gameManager.settings.autoSave)
                Toggle("Show tutorial hints", isOn: $gameManager.settings.showHints)
            }
            
            Section("Controls") {
                Picker("Controls", selection: $gameManager.settings.controlType) {
                    Text("Touch").tag(ControlType.touch)
                    Text("Swipe").tag(ControlType.swipe)
                }
            }
        }
        .navigationTitle("Game Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacySettingsView: View {
    var body: some View {
        List {
            Section("Data & Privacy") {
                Button("Export Player Data") {
                }
                
                Button("Reset All Data") {
                }
                .foregroundColor(.error500)
            }
            
            Section("Account") {
                Button("Sign Out") {
                }
                
                Button("Delete Account") {
                }
                .foregroundColor(.error500)
            }
            
            Section("Legal") {
                Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                Link("Contact Support", destination: URL(string: "mailto:support@puzzlequest.com")!)
            }
        }
        .navigationTitle("Privacy & Data")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfileScreenView()
        .environmentObject(GameManager())
        .environmentObject(MonetizationManager())
        .environmentObject(AdManager())
}