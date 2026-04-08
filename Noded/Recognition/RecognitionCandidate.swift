/**
    Author: Vipaswi Thapa
    Date: April 3, 2026
    Description: A single recognition hypothesis produced by SymbolClassifier for a group
    of strokes. RecognitionCandidate is a passive data container — it does not run
    classification itself. That responsibility belongs to the recognition pipeline that
    consumes FeatureExtractor, ShapeNormalizer, and SymbolClassifier in sequence.

    Per the Noded architecture:
      - This is NOT a Component. It is a suggestion.
      - Multiple candidates may exist for the same stroke group.
      - It must not alter geometry, build topology, or trigger simulation.
      - It is ephemeral and can be regenerated at any time from the original strokes.
*/

import Foundation

/// A single recognition hypothesis for one or more strokes.
///
/// Produced by `SymbolClassifier` and collected into a `RecognitionResult`.
/// Never mutated after creation. Never references topology, nodes, or simulation state.
struct RecognitionCandidate: Identifiable, Codable {

    /// Stable identity for this hypothesis (not the same as the eventual Component UUID).
    let id: UUID

    /// The classifier's best guess at what electrical component this stroke group represents.
    let componentType: ComponentType

    /// Classifier confidence in [0.0, 1.0]. Higher is more certain.
    let confidence: Double

    /// The UUIDs of the Stroke objects that contributed to this hypothesis.
    /// References geometry by ID — does not own or embed geometry.
    let geometryIDs: [UUID]

    // MARK: - Initialisation

    /// Designated initialiser. All fields are set at creation; the struct is immutable.
    ///
    /// - Parameters:
    ///   - id:            A stable UUID for this candidate. Defaults to a new UUID.
    ///   - componentType: The hypothesised electrical component type.
    ///   - confidence:    Classifier confidence score in [0.0, 1.0].
    ///   - geometryIDs:   The stroke UUIDs that were classified.
    init(
        id: UUID = UUID(),
        componentType: ComponentType,
        confidence: Double,
        geometryIDs: [UUID]
    ) {
        precondition((0.0...1.0).contains(confidence),
                     "Confidence must be in [0.0, 1.0], got \(confidence)")
        precondition(!geometryIDs.isEmpty,
                     "A RecognitionCandidate must reference at least one stroke.")

        self.id            = id
        self.componentType = componentType
        self.confidence    = confidence
        self.geometryIDs   = geometryIDs
    }
}

// MARK: - Comparable

/// Candidates are ordered by descending confidence so that the best hypothesis
/// sorts first in a ranked list.
extension RecognitionCandidate: Comparable {
    static func < (lhs: RecognitionCandidate, rhs: RecognitionCandidate) -> Bool {
        lhs.confidence > rhs.confidence   // descending: higher confidence = "less than" for sort
    }
}

// MARK: - CustomStringConvertible

extension RecognitionCandidate: CustomStringConvertible {
    var description: String {
        String(format: "RecognitionCandidate(%@, type: %@, confidence: %.2f, strokes: %d)",
               id.uuidString.prefix(8),
               componentType.rawValue,
               confidence,
               geometryIDs.count)
    }
}