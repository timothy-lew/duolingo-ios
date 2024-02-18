import SwiftUI

enum Difficulty: String, CaseIterable {
    case beginner = "Beginner"
    case advanced = "Advanced"
}

struct ContentView: View {
    @State private var selectedDifficulty: Difficulty = .beginner
    @State private var showGameView: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Select Difficulty")
                    .font(.title)
                    .padding()
                
                Picker("Please choose a color", selection: $selectedDifficulty) {
                    ForEach(Difficulty.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(.menu)
                
                NavigationLink {
                    GameView(selectedDifficulty: $selectedDifficulty, showGameView: $showGameView)
                } label: {
                    Text("Let's play!")
                }
            }
        }
    }
}
