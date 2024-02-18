//
//  QuizView.swift
//  Language
//
//  Created by Timothy on 16/2/24.
//

import AVFoundation
import SwiftUI

struct BeginnerView: View {
    private let totalQuestions = 10
    
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var shuffledOptions: [String] = []
    @Binding var isGameActive: Bool
    @State private var showAlert = false
    @State private var player: AVAudioPlayer?
    
    var words: [Word]
    @State var wordsTested = [Word]()
    
    private var currentWord: Word {
        if currentQuestionIndex < wordsTested.count {
            return wordsTested[currentQuestionIndex]
        } else {
            return Word(original: "", translated: "")
        }
    }
    
    var body: some View {
        VStack {
            Text("Question \(currentQuestionIndex + 1)/\(totalQuestions)")
                .padding()
            
            Text("What is the English translation of:")
                .font(.headline)
                .padding()
            
            Text(currentWord.translated)
                .font(.title)
                .padding()
            
            ForEach(shuffledOptions, id: \.self) { option in
                Button(action: {
                    checkAnswer(selectedOption: option)
                }) {
                    Text(option)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                .padding(.horizontal)
            }
            Spacer()
            
            Text("Current Score: \(score)")
        }
        .onAppear {
            loadQuestions()
            loadQuestion()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Game Over"),
                message: Text("Your Score: \(score)/10"),
                dismissButton: .default(Text("OK")) {
                    isGameActive = false
                }
            )
        }
    }
    
    private func loadQuestions() {
        let shuffledWords = words.shuffled().prefix(10)
        wordsTested = Array(shuffledWords)
    }
    
    private func loadQuestion() {
        guard currentQuestionIndex < totalQuestions else {
            // Game finished
            showAlert = true
            return
        }
        shuffledOptions = generateShuffledOptions()
    }
    
    private func generateShuffledOptions() -> [String] {
        var options = Set<String>()
        
        // Add correct answer
        options.insert(currentWord.original)
        
        // Add three incorrect options (randomly selected)
        while options.count < 4 {
            let randomIndex = Int.random(in: 0..<words.count)
            options.insert(words[randomIndex].original)
        }
        
        return options.shuffled()
    }
    
    private func checkAnswer(selectedOption: String) {
        if selectedOption == currentWord.original {
            withAnimation(.easeInOut(duration: 0.5)) {
                playSoundEffect(isCorrect: true)
                score += 1
            }
        }
        else {
            playSoundEffect(isCorrect: false)
        }
        
        currentQuestionIndex += 1
        
        // Load next question or finish the game
        loadQuestion()
    }
    
    private func playSoundEffect(isCorrect: Bool) {
        let currentFilePath = #file
        let packageDirectory = URL(fileURLWithPath: currentFilePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Resources")
        
        var url = packageDirectory
        if isCorrect {
            url = packageDirectory.appendingPathComponent("correct.mp3")
        }
        else {
            url = packageDirectory.appendingPathComponent("incorrect.mp3")
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Error playing sound effect: \(error.localizedDescription)")
        }
    }
}


#Preview {
    @State var words = [Word]()
    @State var isGameActive = true
    return BeginnerView(isGameActive: $isGameActive, words: words)
}
