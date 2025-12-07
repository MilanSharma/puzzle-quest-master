
import SwiftUI

struct ProfileScreenView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.neutral400)
                            .padding(.top, 20)
                        
                        Text(gameManager.player.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Member since \(gameManager.player.joinDate)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Stats Grid
                    HStack(spacing: 16) {
                        StatBox(title: "Level", value: "\(gameManager.player.level)", icon: "chart.bar.fill", color: .blue)
                        StatBox(title: "Stars", value: "\(gameManager.player.totalStars)", icon: "star.fill", color: .yellow)
                        StatBox(title: "Best", value: "\(gameManager.player.bestScore)", icon: "trophy.fill", color: .orange)
                    }
                    .padding(.horizontal)
                    
                    // Achievements
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Achievements")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(gameManager.achievements) { achievement in
                            AchievementRow(achievement: achievement)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .background(Color.neutral50.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .cardShadow()
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(achievement.isCompleted ? Color.accentGold.opacity(0.2) : Color.neutral100)
                    .frame(width: 50, height: 50)
                
                Text(achievement.icon)
                    .font(.title2)
                    .opacity(achievement.isCompleted ? 1 : 0.5)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(achievement.isCompleted ? .primary : .secondary)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ProgressView(value: Double(achievement.progress), total: Double(achievement.target))
                    .scaleEffect(x: 1, y: 0.5, anchor: .center)
            }
            
            Spacer()
            
            if achievement.isCompleted {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.accentGold)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
