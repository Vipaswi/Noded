/**
    Author: Vipaswi Thapa
    Date: 2024-06-01
    Description: A class responsible for normalizing shapes, which includes scaling, translating, and rotating strokes to a standard form for recognition.
*/

import Stroke
import StrokePoint
import Point2D

class ShapeNormalizer{

    // Calculates a centroid for a given stroke
    static func calculateCentroid(stroke: Stroke) -> Point2D {
        var sumX: Double = 0.0
        var sumY: Double = 0.0
        let count = Double(stroke.strokePoints.count)

        for strokePoint in stroke.strokePoints {
            sumX += strokePoint.point.x
            sumY += strokePoint.point.y
        }

        return Point2D(x: sumX / count, y: sumY / count)
    }

    // Find the indicative angle w from the point's centroid to the first point
    static func indicativeAngle(stroke: Stroke) -> Double {
        let centroid = calculateCentroid(stroke: stroke)
        return atan2(firstPoint.y - centroid.y, firstPoint.x - centroid.x)
    }

    // Rotates a stroke by a certain angle
    static func rotate 

}