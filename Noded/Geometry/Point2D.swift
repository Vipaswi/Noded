/**
    Author: Vipaswi Thapa
    Date: 2024-06-01
    Description: A simple struct representing a 2D point with x and y coordinates.
*/

import CoreGraphics

struct Point2D: Codable, Hashable {
    var x: Double
    var y: Double
    
    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    init(cgPoint: CGPoint) {
        self.x = Double(cgPoint.x)
        self.y = Double(cgPoint.y)
    }
    
    func distance(to point: Point2D) -> Double {
        let dx = self.x - point.x
        let dy = self.y - point.y
        return sqrt(dx * dx + dy * dy)
    }
}