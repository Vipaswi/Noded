/**
    Name: GeometryDocument.swift
    Author: Vipaswi Thapa
    Date: 2024-06-01
    Description: A document representing a collection of strokes.
*/

import Foundation
class GeometryDocument: Codable {
    var strokes: [UUID : Stroke]
    
    init(strokes: [Stroke]) {
        self.strokes = [:]
        for stroke in strokes {
            self.strokes[stroke.id] = stroke;
        }
    }

    addStroke(_ stroke: Stroke) {
        self.strokes[stroke.id] = stroke;
    }

    removeStroke(_ stroke: Stroke) {
        self.strokes.removeValue(forKey: stroke.id);
    }
}
