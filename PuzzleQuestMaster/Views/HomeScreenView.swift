
import SwiftUI

struct HomeScreenView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.neutral50.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Currency Header
                        HStack {
                            CurrencyBadge(icon: "💎", amount: gameManager.player.gems, color: .blue)
                            Spacer()
                            CurrencyBadge(icon: "💰", amount: gameManager.player.coins, color: .yellow)
                            Spacer()
                            CurrencyBadge(icon: "❤️", amount: gameManager.player.lives, color: .red)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // Main Play Button
                        VStack(spacing: 8) {
                            Text("Current Level")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            
                            Text("\(gameManager.currentLevel)")
                                .font(.system(size: 80, weight: .heavy, design: .rounded))
                                .foregroundColor(.primaryBlue)
                                .shadow(color: .primaryBlue.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            NavigationLink(destination: GameScreenView().navigationBarBackButtonHidden(true)) {
                                Text("PLAY")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 200, height: 60)
                                    .background(Color.primaryBlue)
                                    .cornerRadius(30)
                                    .shadow(color: .primaryBlue.opacity(0.4), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                        .padding(.vertical, 40)
                        
                        // Daily Challenges
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Daily Challenges")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Spacer()
                                Text("Reset in 4h 12m")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(gameManager.dailyChallenges) { challenge in
                                        ChallengeCard(challenge: challenge)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Events / News Banner
                        VStack(alignment: .leading) {
                            Text("Special Event")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Image(systemName: "sparkles")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 50)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 120)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(16)
                                .overlay(
                                    Text("Double Gem Weekend!")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.bottom, -60)
                                )
                                .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// Subcomponents

struct CurrencyBadge: View {
    let icon: String
    let amount: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text(icon)
            Text("\(amount)")
                .fontWeight(.bold)
                .font(.system(.subheadline, design: .rounded))
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(color.opacity(0.1))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ChallengeCard: View {
    let challenge: DailyChallenge
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(challenge.icon)
                    .font(.title2)
                    .padding(8)
                    .background(Color.neutral100)
                    .clipShape(Circle())
                
                Spacer()
                
                if challenge.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.success500)
                } else {
                    Text("\(challenge.progress)/\(challenge.target)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(challenge.title)
                .font(.headline)
                .lineLimit(1)
            
            ProgressView(value: Double(challenge.progress), total: Double(challenge.target))
                .accentColor(.accentGold)
            
            HStack {
                Text("Reward:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                HStack(spacing: 2) {
                    Text(challenge.reward.icon)
                        .font(.caption)
                    Text("\(challenge.reward.amount)")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .padding(4)
                .background(Color.neutral100)
                .cornerRadius(4)
            }
        }
        .padding()
        .frame(width: 200)
        .background(Color.white)
        .cornerRadius(16)
        .cardShadow()
    }
}
