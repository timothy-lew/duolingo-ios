//
//  AdvancedView.swift
//  Language
//
//  Created by Timothy on 16/2/24.
//

import AVFoundation
import SwiftUI

struct AdvancedView: View {
    private let totalSentences = 5
    
    @State private var currentSentenceIndex = 0
    @State private var score = 0
    @State private var shuffledWords: [String] = []
    @Binding var isGameActive: Bool
    @State private var showAlert = false
    @State private var selectedWordsStack: [String] = []
    @State private var player: AVAudioPlayer?
    @State private var showCorrectAnswerAlert = false
    
    @State var sentences: [Sentence]
    @State private var selectedWordsDisplay: String = ""
    @State private var originalSentenceToShow = [String]()
    
    private var currentSentence: Sentence {
        if currentSentenceIndex < totalSentences {
            return sentences[currentSentenceIndex]
        } else {
            return Sentence(originalWords: [], translatedWords: [])
        }
    }
    
    var body: some View {
        VStack {
            Text("Sentence \(currentSentenceIndex + 1)/\(totalSentences)")
                .padding()
            
            Text("Arrange the words to form a correct sentence:")
                .font(.headline)
                .padding()
            
            Text("Translate: \(currentSentence.originalWords.joined(separator: " "))")
                .font(.subheadline)
                .padding()
            
            ForEach(shuffledWords, id: \.self) { word in
                Button(action: {
                    selectWord(word)
                }) {
                    Text(word)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            
            Button(action: {
                checkAnswer()
            }) {
                Text("Check Answer")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            HStack {
                Text("Selected Words:")
                    .padding()
                Text(selectedWordsDisplay)
                    .foregroundColor(.green)  // Adjust color as needed
                    .padding()
            }
            
            Spacer()
            
            Text("Current Score: \(score)")
        }
        .onAppear {
            loadSentences()
            loadSentence()
        }
        .alert(isPresented: Binding<Bool>.constant(showAlert || showCorrectAnswerAlert)) {
            if showAlert {
                return Alert(
                    title: Text("Game Over"),
                    message: Text("Your Score: \(score)/\(totalSentences)"),
                    dismissButton: .default(Text("OK")) {
                        isGameActive = false
                    }
                )
            } else if showCorrectAnswerAlert {
                return Alert(
                    title: Text("Incorrect choice"),
                    message: Text("Correct sentence: \(originalSentenceToShow.joined(separator: " "))"),
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
    }
    
    private func loadSentences() {
        let shuffledSentences = sentences.shuffled().prefix(totalSentences)
        sentences = Array(shuffledSentences)
    }
    
    private func loadSentence() {
        guard currentSentenceIndex < totalSentences else {
            // Game finished
            showAlert = true
            return
        }
        
        let sentence = currentSentence
        shuffledWords = sentence.translatedWords.shuffled()
    }
    
    private func selectWord(_ word: String) {
        selectedWordsStack.append(word)
        // Update the display of selected words
        selectedWordsDisplay = selectedWordsStack.joined(separator: " ")

        withAnimation(.easeOut(duration: 0.3)) {
            // Fade out the selected word
            shuffledWords.removeAll { $0 == word }
        }
        
        if (selectedWordsStack.count == currentSentence.translatedWords.count) {
            checkAnswer()
        }
    }
    
    private func checkAnswer() {
//        print(selectedWordsStack)
//        print(currentSentence.translatedWords)
        guard selectedWordsStack.count == currentSentence.translatedWords.count else {
            print("error: number of selected words does not match")
            return
        }
        originalSentenceToShow = currentSentence.translatedWords
        
        var isAllCorrect = true
        // Compare selected words with shuffled words
        for (selected, shuffled) in zip(selectedWordsStack, currentSentence.translatedWords) {
            guard selected == shuffled else {
                // Words don't match, it's incorrect
                isAllCorrect = false
                break
            }
        }
        
        if isAllCorrect {
            withAnimation(.easeInOut(duration: 0.25)) {
                playSoundEffect(isCorrect: true)
                score += 1
            }
        }
        else {
            playSoundEffect(isCorrect: false)
            if (currentSentenceIndex < totalSentences) {
                showCorrectAnswerAlert = true
//                print(currentQuestionIndex)
            }
        }
        
        // Clear the selected words for the next question
        selectedWordsStack.removeAll()
        selectedWordsDisplay = ""
        
        // Move to the next sentence
        currentSentenceIndex += 1
        loadSentence()
    }
    
    private func playSoundEffect(isCorrect: Bool) {
//        https://pixabay.com/sound-effects/search/error/
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
    @State var isGameActive = true
    var sentences = [Sentence]()
    return AdvancedView(isGameActive: $isGameActive, sentences: sentences)
}
