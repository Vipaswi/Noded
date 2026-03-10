/**
    Name: StrokePoint.swift
    Author: Vipaswi Thapa
    Date: 2024-06-01
    Description: The class responsible for extracting features given a stroke, or an array of strokes.
                 Since the recognizer uses a $1 algorithm, the feature extraction is minimal. It simply
                 resamples a stroke to 64 points.
*/


import Foundation
import GeometryDocument
import Stroke

class FeatureExtractor {
    
    static func extractFeatures(from stroke: Stroke) -> [Stroke] {
        // Placeholder for feature extraction logic
        // This could include features like stroke length, curvature, speed, etc.
        strokePoints = stroke.strokePoints; 

        if(strokePoints.count > 64) {
            // Resample to 64 points
            strokePoints = resample(strokePoints, to: 64);
        } else if(strokePoints.count < 64) {
            // Pad with duplicate points if less than 64
            while(strokePoints.count < 64) {
                strokePoints.append(strokePoints.last!);
            }
        }

        return strokePoints;
    }

    static func resample(from strokePoints: [StrokePoint], to count: Int) -> [StrokePoint] {
        // Placeholder for resampling logic
        // This would involve calculating the total length of the stroke and resampling points at regular intervals
        
        if(strokePoints.count == 1) {
            // If there's only one point, duplicate it to reach the desired count
            return Array(repeating: strokePoints[0], count: count)
        }

        var resampledPoints: [StrokePoint] = []
        let totalLength = calculateTotalLength(of: strokePoints)

        let interval = totalLength / Double(count - 1)
        var accumulatedLength: Double = 0.0
        var currentIndex = 0

        resampledPoints.append(strokePoints[0]) // Add the first point
        for i in 1..<strokePoints.count {
            let segmentLength = calculateDistance(from: strokePoints[i - 1], to: strokePoints[i])
            accumulatedLength += segmentLength

            while accumulatedLength >= interval {
                let t = (interval - (accumulatedLength - segmentLength)) / segmentLength
                let newPoint = interpolate(from: strokePoints[i - 1], to: strokePoints[i], t: t)
                resampledPoints.append(newPoint)
                accumulatedLength -= interval
            }
        }
        return resampledPoints
    }

    static func calculateTotalLength(of strokePoints: [StrokePoint]) -> Double {
        var length: Double = 0.0
        for i in 1..<strokePoints.count {
            length += calculateDistance(from: strokePoints[i - 1], to: strokePoints[i])
        }
        return length
    }

    static func calculateDistance(from point1: StrokePoint, to point2: StrokePoint) -> Double {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        return sqrt(dx * dx + dy * dy)
    }

    static func interpolate(from point1: StrokePoint, to point2: StrokePoint, t: Double) -> StrokePoint {
        let x = point1.x + (point2.x - point1.x) * t
        let y = point1.y + (point2.y - point1.y) * t
        return StrokePoint(x: x, y: y)
    }

    static func extractFeatures(from strokes: [Stroke]) -> [Stroke] {
        return strokes.map { extractFeatures(from: $0) }
    }
    
    static func extractFeatures(from document: GeometryDocument) -> [[String: Any]] {
        return document.strokes.values.map { extractFeatures(from: $0) }
    }
}