/**
    Author : Vipaswi Thapa
    Date: 2024-06-01
    Description: A class responsible for extracting features from strokes, such as resampling, calculating angles, and other geometric properties.
*/

import Stroke
import StrokePoint
import Foundation
import Point2D
import GeometryDocument

struct FeatureExtractor {

    static func resample(stroke : Stroke, sampleSize: Int){
        // The average distance between points
        var I : double = pathLength(stroke: stroke) / Double(sampleSize);
        
        // The distance along the resampling algorithm
        var D : double = 0.0;

        // The resampled stroke
        var resampledStroke : Stroke = Stroke([], stroke.boundingBox);

        for i in 1..<stroke.strokePoints.count {
            var d : double= distance(p1: stroke.strokePoints[i-1], p2: stroke.strokePoints[i]);
            if(D + d >= I) {
                // Calculate the new point's x and y coordinates through linear interpolation
                var qx = stroke.strokePoints[i-1].point.x + ((I - D)/d) * (stroke.strokePoints[i].point.x - stroke.strokePoints[i-1].point.x);
                var qy = stroke.strokePoints[i-1].point.y + ((I - D)/d) * (stroke.strokePoints[i].point.y - stroke.strokePoints[i-1].point.y);
                
                // Get the average time stamp and new stroke point
                var averageTimestamp = (stroke.strokePoints[i-1].timestamp + stroke.strokePoints[i].timestamp) / 2.0;
                let newStrokePoint = StrokePoint(point: Point2D(x: qx, y: qy), timestamp: averageTimestamp);
                
                // Append to the resampled stroke and insert into the original stroke so that the new point is considered in the next iteration
                resampledStroke.strokePoints.append(newStrokePoint);
                stroke.strokePoints.insert(newStrokePoint, at: i);
                D = 0.0;
            } else {
                D += d;
            }
        }   

        return resampledStroke;
    }

    static func pathLength(stroke: Stroke) -> Double {
        var length: Double = 0.0
        for i in 1..<stroke.strokePoints.count {
            length += distance(p1: stroke.strokePoints[i-1], p2: stroke.strokePoints[i])
        }
        return length
    }

    static func distance(p1: StrokePoint, p2: StrokePoint) -> Double {
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        return sqrt(dx * dx + dy * dy)
    }
}