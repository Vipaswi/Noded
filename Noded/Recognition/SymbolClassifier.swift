/**
    Author: Vipaswi Thapa
    Date: 2024-06-01
    Description: A struct responsible for classifying symbols based on extracted features.
    The only file containing classification logic — intentionally swappable.
    Must not produce Component objects. Must not assign terminals or electrical values.
*/

import Foundation

struct SymbolClassifier {

    static func recognize(stroke: Stroke, templates: [Stroke]) -> (String, Double) {
        var b: Double = .infinity
        var bestTemplate: Stroke? = nil

        for templateStroke in templates {
            let d = distanceAtBestAngle(stroke: stroke, template: templateStroke, a: -45, b: 45, threshold: 2)
            if d < b {
                b = d
                bestTemplate = templateStroke
            }
        }

        return ("Unknown Symbol", 0.0)
    }

    static func distanceAtBestAngle(stroke: Stroke, template: Stroke, a: Double, b: Double, threshold: Double) -> Double {
        let phi = 0.5 * (-1.0 + sqrt(5.0))
        var a = a
        var b = b
        var x1 = phi * a + (1 - phi) * b
        var f1 = distanceAtAngle(stroke: stroke, template: template, angle: x1)
        var x2 = (1 - phi) * a + phi * b
        var f2 = distanceAtAngle(stroke: stroke, template: template, angle: x2)

        while abs(b - a) > threshold {
            if f1 < f2 {
                b = x2
                x2 = x1
                f2 = f1
                x1 = phi * a + (1 - phi) * b
                f1 = distanceAtAngle(stroke: stroke, template: template, angle: x1)
            } else {
                a = x1
                x1 = x2
                f1 = f2
                x2 = (1 - phi) * a + phi * b
                f2 = distanceAtAngle(stroke: stroke, template: template, angle: x2)
            }
        }

        return min(f1, f2)
    }

    static func distanceAtAngle(stroke: Stroke, template: Stroke, angle: Double) -> Double {
        let rotatedStroke = ShapeNormalizer.rotateBy(stroke: stroke, angle: angle)
        return pathDistance(stroke1: rotatedStroke, stroke2: template)
    }

    static func pathDistance(stroke1: Stroke, stroke2: Stroke) -> Double {
        var distance: Double = 0.0
        for i in 0..<stroke1.strokePoints.count {
            distance += FeatureExtractor.distance(p1: stroke1.strokePoints[i], p2: stroke2.strokePoints[i])
        }
        return distance / Double(stroke1.strokePoints.count)
    }
}
