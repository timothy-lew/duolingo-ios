import SwiftUI

struct ContentView: View {
    
    let difficulties = ["Beginner", "Intermediate", "Advanced"]
    @State private var selectedDifficulty: String = "Beginner"
    @State private var isPlaying: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Select Difficulty")
                    .font(.title)
                    .padding()
                
                Picker("Please choose a color", selection: $selectedDifficulty) {
                    ForEach(difficulties, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.menu)
                
                NavigationLink {
                    GameView()
                } label: {
                    Text("Let's play!")
                }
            }
        }
    }
}
