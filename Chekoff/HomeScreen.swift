import SwiftUI

struct HomeScreen: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // App title
                Text("Adamap")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                // Navigation options
                VStack(spacing: 16) {
                    
                    NavigationLink {
                        ChecklistView()
                    } label: {
                        HomeButton(title: "Checkoff", systemImage: "checkmark.circle.fill", color: .teal)
                    }
                    
                    NavigationLink {
                        OcularcentroView()
                    } label: {
                        HomeButton(title: "Ocularcentro", systemImage: "eye.fill", color: .purple)
                    }
                    
                    NavigationLink {
                        Text("Statistics (coming soon)")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    } label: {
                        HomeButton(title: "Breath", systemImage: "chart.bar.fill", color: .red)
                    }
                    
                    NavigationLink {
                        ArsMemoriaView()
                    } label: {
                        HomeButton(title: "Ars Memoria", systemImage: "brain.head.profile", color: .orange)
                    }
                    
                    NavigationLink {
                        Text("Statistics (coming soon)")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    } label: {
                        HomeButton(title: "Statistics", systemImage: "chart.bar.fill", color: .blue)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("")
        }
    }
}

// MARK: - Reusable button style
struct HomeButton: View {
    let title: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color)
        .cornerRadius(14)
        .shadow(radius: 3)
    }
}

// MARK: - Preview
#Preview {
    HomeScreen()
}
