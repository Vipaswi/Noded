/**
    Name: GeometryDocument.swift
    Author: Vipaswi Thapa
    Date: 2024-06-01
    Description: A class acting as the root container for all raw strokes on a canvas.
    Strokes are stored by UUID for O(1) lookup.
*/

import Foundation
import Observation

@Observable
class GeometryDocument: Codable {
    var strokes: [UUID: Stroke] = [:]

    private enum CodingKeys: String, CodingKey {
        case strokes
    }

    init(strokes: [Stroke] = []) {
        for stroke in strokes {
            self.strokes[stroke.id] = stroke
        }
    }

    func addStroke(_ stroke: Stroke) {
        strokes[stroke.id] = stroke
    }

    func removeStroke(_ stroke: Stroke) {
        strokes.removeValue(forKey: stroke.id)
    }

    func stroke(id: UUID) -> Stroke? {
        strokes[id]
    }
}
