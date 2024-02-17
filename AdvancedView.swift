//
//  AdvancedView.swift
//  Language
//
//  Created by Timothy on 16/2/24.
//

import SwiftUI

struct AdvancedView: View {
    private let totalSentences = 10
    
    @State private var currentSentenceIndex = 0
    @State private var score = 0
    @State private var shuffledWords: [String] = []
    @Binding var isGameActive: Bool
    @State private var showAlert = false
    @State private var selectedWordsStack: [String] = []
    
    @State var sentences: [Sentence]
    
    private var currentSentence: Sentence {
        if currentSentenceIndex < totalSentences {
            return sentences[currentSentenceIndex]
        } else {
            isGameActive = false
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
                .foregroundColor(.gray)
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
            
            Spacer()
            
            Text("Current Score: \(score)")
        }
        .onAppear {
            loadSentences()
            loadSentence()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Game Over"),
                message: Text("Your Score: \(score)"),
                dismissButton: .default(Text("OK")) {
                    // Handle the OK button press if needed
                    isGameActive = false
                }
            )
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
        
        shuffledWords.removeAll { $0 == word }
        
        if (selectedWordsStack.count == currentSentence.translatedWords.count) {
            checkAnswer()
        }
    }
    
    private func checkAnswer() {
        print(selectedWordsStack)
        print(currentSentence.translatedWords)
        guard selectedWordsStack.count == currentSentence.translatedWords.count else {
            print("error: number of selected words does not match")
            return
        }
        
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
                score += 1
            }
        }
        
        // Clear the selected words for the next question
        selectedWordsStack.removeAll()
        
        // Move to the next sentence
        currentSentenceIndex += 1
        loadSentence()
    }
}

#Preview {
    @State var isGameActive = true
    var sentences = [Sentence]()
    return AdvancedView(isGameActive: $isGameActive, sentences: sentences)
}