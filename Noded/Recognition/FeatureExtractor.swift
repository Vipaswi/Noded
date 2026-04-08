/**
    Author: Vipaswi Thapa
    Date: 2024-06-01
    Description: A struct responsible for extracting features from strokes, such as resampling,
    calculating angles, and other geometric properties. No classification happens here.
*/

import Foundation

struct FeatureExtractor {

    static func resample(stroke: Stroke, sampleSize: Int) -> Stroke {
        let I: Double = pathLength(stroke: stroke) / Double(sampleSize)
        var D: Double = 0.0
        var resampledStroke = Stroke(strokePoints: [], boundingBox: stroke.boundingBox)

        for i in 1..<stroke.strokePoints.count {
            let d: Double = distance(p1: stroke.strokePoints[i-1], p2: stroke.strokePoints[i])
            if D + d >= I {
                let qx = stroke.strokePoints[i-1].point.x + ((I - D) / d) * (stroke.strokePoints[i].point.x - stroke.strokePoints[i-1].point.x)
                let qy = stroke.strokePoints[i-1].point.y + ((I - D) / d) * (stroke.strokePoints[i].point.y - stroke.strokePoints[i-1].point.y)
                let averageTimestamp = (stroke.strokePoints[i-1].timestamp + stroke.strokePoints[i].timestamp) / 2.0
                let newStrokePoint = StrokePoint(point: Point2D(x: qx, y: qy), timestamp: averageTimestamp)
                resampledStroke.strokePoints.append(newStrokePoint)
                D = 0.0
            } else {
                D += d
            }
        }

        return resampledStroke
    }

    static func pathLength(stroke: Stroke) -> Double {
        var length: Double = 0.0
        for i in 1..<stroke.strokePoints.count {
            length += distance(p1: stroke.strokePoints[i-1], p2: stroke.strokePoints[i])
        }
        return length
    }

    static func distance(p1: StrokePoint, p2: StrokePoint) -> Double {
        let dx = p2.point.x - p1.point.x
        let dy = p2.point.y - p1.point.y
        return sqrt(dx * dx + dy * dy)
    }
}
