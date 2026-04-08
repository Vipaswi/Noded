/**
    Author: Vipaswi Jung Thapa
    Date: 2024-06-01
    Description: The complete output of one recognition pass over a GeometryDocument.
    Contains an ordered list of RecognitionCandidate values. Considered ephemeral —
    it can be regenerated at any time from the original strokes.
*/

import Foundation

struct RecognitionResult: Codable {
    var id: UUID = UUID()
    var generated: Date = Date()
    var recognitionCandidates: [RecognitionCandidate] = []

    init(id: UUID = UUID(), generated: Date = Date(), recognitionCandidates: [RecognitionCandidate] = []) {
        self.id = id
        self.generated = generated
        self.recognitionCandidates = recognitionCandidates
    }

    init(recognitionCandidates: [RecognitionCandidate]) {
        self.id = UUID()
        self.generated = Date()
        self.recognitionCandidates = recognitionCandidates
    }

    mutating func addCandidate(candidate: RecognitionCandidate) {
        recognitionCandidates.append(candidate)
    }
}
