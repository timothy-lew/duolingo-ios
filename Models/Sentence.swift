//
//  Sentence.swift
//  Language
//
//  Created by Timothy on 16/2/24.
//

import Foundation

struct Sentence {
    let originalWords: [String]
    let translatedWords: [String]

    init(originalWords: [String], translatedWords: [String]) {
        self.originalWords = originalWords
        self.translatedWords = translatedWords
    }

    func isCorrectOrder(_ selectedWords: [String]) -> Bool {
        return selectedWords == translatedWords
    }
}
