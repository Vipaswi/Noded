/**
    Author: Vipaswi Thapa
    Date: 2024-06-01
    Description: A class responsible for normalizing shapes, which includes scaling, translating, and rotating strokes to a standard form for recognition.
*/

import Stroke
import StrokePoint
import Point2D

struct ShapeNormalizer {

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
        return atan2(stroke.strokePoints.first!.point.y - centroid.y, stroke.strokePoints.first!.point.x - centroid.x)
    }

    // Rotates a stroke by a certain angle
    static func rotateBy(stroke: Stroke, angle: Double) -> Stroke{
        let centroid = calculateCentroid(stroke: stroke)
        var rotatedPoints: [StrokePoint] = []

        for strokePoint in stroke.strokePoints {
            let translatedX = strokePoint.point.x - centroid.x
            let translatedY = strokePoint.point.y - centroid.y

            let rotatedX = translatedX * cos(angle) - translatedY * sin(angle)
            let rotatedY = translatedX * sin(angle) + translatedY * cos(angle)

            let newPoint = Point2D(x: rotatedX + centroid.x, y: rotatedY + centroid.y)
            rotatedPoints.append(StrokePoint(point: newPoint, time: strokePoint.timestamp))
        }

        return Stroke(id: stroke.id, strokePoints: rotatedPoints)
    }

    static func scaleTo(stroke: Stroke, size: Double) -> Stroke {
        let boundingBox = stroke.boundingBox
        let scaleX = size / boundingBox.width
        let scaleY = size / boundingBox.height
        var scaledPoints: [StrokePoint] = []

        for strokePoint in stroke.strokePoints {
            let scaledX = (strokePoint.point.x - boundingBox.origin.x) * scaleX
            let scaledY = (strokePoint.point.y - boundingBox.origin.y) * scaleY
            let newPoint = Point2D(x: scaledX, y: scaledY)
            scaledPoints.append(StrokePoint(point: newPoint, time: strokePoint.timestamp))
        }

        return Stroke(id: stroke.id, strokePoints: scaledPoints)
    }

    static func translateTo(stroke: Stroke, target: Point2D) -> Stroke {
        let centroid = calculateCentroid(stroke: stroke)
        let deltaX = target.x - centroid.x
        let deltaY = target.y - centroid.y
        var translatedPoints: [StrokePoint] = []

        for strokePoint in stroke.strokePoints {
            let translatedX = strokePoint.point.x + deltaX
            let translatedY = strokePoint.point.y + deltaY
            let newPoint = Point2D(x: translatedX, y: translatedY)
            translatedPoints.append(StrokePoint(point: newPoint, time: strokePoint.timestamp))
        }

        return Stroke(id: stroke.id, strokePoints: translatedPoints)
    }

}