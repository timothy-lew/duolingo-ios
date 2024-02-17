//
//  QuizView.swift
//  Language
//
//  Created by Timothy on 16/2/24.
//

import SwiftUI

struct BeginnerView: View {
    private let totalQuestions = 10
    
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var shuffledOptions: [String] = []
    @Binding var isQuizActive: Bool
    @State private var showAlert = false
    
    var words: [Word]
    @State var wordsTested = [Word]()
    
    private var currentWord: Word {
        if currentQuestionIndex < wordsTested.count {
            print(wordsTested)
            return wordsTested[currentQuestionIndex]
        } else {
            // Handle the case where currentQuestionIndex is out of bounds
            // You can return a default Word or take appropriate action
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
                    isQuizActive = false
                }
            )
        }
    }
    
    private func loadQuestions() {
        let shuffledWords = words.shuffled().prefix(10)
//        print(shuffledWords)
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
            withAnimation(.easeInOut(duration: 0.25)) {
                score += 1
            }
        }
        
        currentQuestionIndex += 1
        
        // Load next question or finish the game
        loadQuestion()
    }
}


#Preview {
    @State var words = [Word]()
    @State var isQuizActive = true
    return BeginnerView(isQuizActive: $isQuizActive, words: words)
}
