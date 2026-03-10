/**
  Name: Stroke.swift
  Author: Vipaswi Thapa
  Date: 2024-06-01
  Description: A struct representing a stroke, which consists of an array of points and a bounding box.
*/

import Foundation
import SwiftUI
import StrokePoint

class Stroke : Codable {
  let id : UUID;
  var strokePoints : [StrokePoint];
  let boundingBox : CGRect;

  init(strokePoints: [StrokePoint], boundingBox: CGRect) {
    self.id = UUID();
    self.strokePoints = strokePoints;
    self.boundingBox = boundingBox;
  }

  init(strokePoints: [StrokePoint]) {
    self.id = UUID();
    self.strokePoints = strokePoints;
    self.boundingBox = Stroke.calculateBoundingBox(for: strokePoints);
  }

  static func calculateBoundingBox(for strokePoints: [StrokePoint]) -> CGRect {
    guard let firstPoint = strokePoints.first else {
      return .zero
    }
    
    var minX = firstPoint.point.x
    var maxX = firstPoint.point.x
    var minY = firstPoint.point.y
    var maxY = firstPoint.point.y
    
    for strokePoint in strokePoints {
      let point = strokePoint.point
      minX = min(minX, point.x)
      maxX = max(maxX, point.x)
      minY = min(minY, point.y)
      maxY = max(maxY, point.y)
    }
    
    return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
  }

}