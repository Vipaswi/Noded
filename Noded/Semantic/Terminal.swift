/**

Author: Vipaswi Thapa
Date: 2024-06-01
Description: A struct representing a named point on a component. Names are optional.
*/

struct Terminal {
    var name: String? := nil;
    var point: Point2D;

    init(name: String? = nil, point: Point2D) {
        self.name = name;
        self.point = point;
    }
}