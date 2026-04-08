/**
    Name: StrokePoint.swift
    Author: Vipaswi Thapa
    Date: 2024-06-01
    Description: A struct representing a point in a stroke, which includes a 2D point and a timestamp.
*/

import Foundation
import Point2D

struct StrokePoint: Codable { // Perhaps add equatable
    var point: Point2D
    var timestamp: TimeInterval
    
    init(point: Point2D, timestamp: TimeInterval) {
        self.point = point
        self.timestamp = timestamp
    }
}