//
//  GameView.swift
//  Language
//
//  Created by Timothy on 10/2/24.
//

import SwiftUI

struct GameView: View {
    @State private var words = [Word]()
    @State private var sentences = [Sentence]()
    @State private var isBeginnerQuizActive = false
    @State private var isAdvancedQuizActive = false
    
    var body: some View {
        VStack {
            Text("Are you ready?")
                .font(.title)
            
            if isBeginnerQuizActive {
                BeginnerView(isQuizActive: $isBeginnerQuizActive, words: words)
            }
            else if isAdvancedQuizActive {
                AdvancedView(isGameActive: $isAdvancedQuizActive, sentences: sentences)
            }
            else {
                Button("Start Quiz") {
                    isAdvancedQuizActive = true
                }
            }
            
        }
        .onAppear {
            loadBeginnerCsv()
            loadAdvancedCsv()
        }
    }
    
    private func loadAdvancedCsv() {
        let currentFilePath = #file
        let packageDirectory = URL(fileURLWithPath: currentFilePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Resources")
        let csvURL = packageDirectory.appendingPathComponent("advanced.csv")
//        print(csvURL.path)
        
        do {
            let data = try String(contentsOfFile: csvURL.path)
            var rows = data.components(separatedBy: "\n")
            rows.removeFirst()
            
            for row in rows {
                let columns = row.components(separatedBy: ",")
                if columns.count == 2 {
                    let original = columns[0]
                    let translated = columns[1]
                    
                    // Split original and translated sentences into arrays of words
                    let originalWords = original.components(separatedBy: " ")
                    let translatedWords = translated.components(separatedBy: " ")
                    
                    let sentence = Sentence(originalWords: originalWords, translatedWords: translatedWords)
                    sentences.append(sentence)
                }
            }
        } catch {
            print("Error reading CSV file:", error)
        }
    }
    
    private func loadBeginnerCsv() {
        let currentFilePath = #file
        let packageDirectory = URL(fileURLWithPath: currentFilePath)
            .deletingLastPathComponent()
            .appendingPathComponent("Resources")
        let beginnerCsvURL = packageDirectory.appendingPathComponent("beginner.csv")
//        print(csvURL.path)
        
        do {
            let data = try String(contentsOfFile: beginnerCsvURL.path)
            var rows = data.components(separatedBy: "\n")
            rows.removeFirst()
            
            for row in rows {
                let columns = row.components(separatedBy: ",")
                if columns.count == 2 {
                    let original = columns[0]
                    let translated = columns[1]
                    let word = Word(original: original, translated: translated)
                    words.append(word)
                }
            }
        } catch {
            print("Error reading CSV file:", error)
        }
    }
}

#Preview {
    GameView()
}
