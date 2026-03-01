/**
The representation of a singular stroke.
*/

import Foundation
import SwiftUI

struct Stroke{
  let id : UUID;
  var points : [CGPoint];
  let boundingBox : CGRect;
}