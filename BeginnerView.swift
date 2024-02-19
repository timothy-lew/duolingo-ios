//
//  QuizView.swift
//  Language
//
//  Created by Timothy on 16/2/24.
//

import AVFoundation
import SwiftUI

struct BeginnerView: View {
    private let totalQuestions = 5
    
    @Binding var isGameActive: Bool
    
    var words: [Word]
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var shuffledOptions: [String] = []
    @State private var showAlert = false
    @State private var showCorrectAnswerAlert = false
    @State private var player: AVAudioPlayer?
    @State var wordsTested = [Word]()
    @State private var selectedAnswer: String? = nil
    @State private var isCorrectAnswer: Bool? = nil
    @State private var originalWordToShow = ""
    
    private var currentWord: Word {
        if currentQuestionIndex < wordsTested.count {
            return wordsTested[currentQuestionIndex]
        } else {
            return Word(original: "", translated: "")
        }
    }
    
    var body: some View {
        VStack {
            if currentQuestionIndex + 1 <= totalQuestions {
                Text("Question \(currentQuestionIndex + 1)/\(totalQuestions)")
                    .padding()
            }
            else {
                Text("Question \(currentQuestionIndex)/\(totalQuestions)")
                    .padding()
            }
            
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
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedAnswer == option ?
                                      (isCorrectAnswer == true ? Color.green : Color.red) :
                                        Color.blue
                                     )
                        )                        
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
        .alert(isPresented: Binding<Bool>.constant(showAlert || showCorrectAnswerAlert)) {
            if showAlert {
                return Alert(
                    title: Text("Game Over"),
                    message: Text("Your Score: \(score)/\(totalQuestions)"),
                    dismissButton: .default(Text("OK")) {
                        isGameActive = false
                    }
                )
            } else if showCorrectAnswerAlert {
                return Alert(
                    title: Text("Incorrect choice"),
                    message: Text("Correct word: \(originalWordToShow)"),
                    dismissButton: .default(Text("OK")) {
                        showCorrectAnswerAlert = false
                    }
                )
            }
            else {
                return Alert(
                    title: Text("Default Alert"),
                    message: Text("This should not be shown"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .padding(.vertical)
    }
    
    private func loadQuestions() {
        let shuffledWords = words.shuffled().prefix(totalQuestions)
        wordsTested = Array(shuffledWords)
    }
    
    private func loadQuestion() {
        guard currentQuestionIndex < totalQuestions else {
            // Game finished
            print(showAlert)
            showAlert = true
            print(showAlert)
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
        let isCorrect = selectedOption == currentWord.original
        originalWordToShow = currentWord.original
        isCorrectAnswer = isCorrect
        selectedAnswer = selectedOption
        
        if isCorrect {
            playSoundEffect(isCorrect: true)
            score += 1
        }
        else {
            playSoundEffect(isCorrect: false)
            if (currentQuestionIndex < totalQuestions) {
                showCorrectAnswerAlert = true
            }
        }
        
        // Load next question or finish the game
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            currentQuestionIndex += 1
            loadQuestion()
        }
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
