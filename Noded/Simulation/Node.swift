/**
    Author: Vipaswi Thapa
    Date: 2024-06-01
    Description: This is a structure representing a node in a circuit. This is derived from stroke data.
*/

struct Node{
    var id: UUID := UUID(); 
    var position: Point2D;

    init(id: UUID = UUID(), position: Point2D) {
        self.id = id;
        self.position = position;
    }

    init(position: Point2D) {
        self.id = UUID();
        self.position = position;
    }
}