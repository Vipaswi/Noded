/**
    Author: Vipaswi Thapa
    Date: 2024-06-01
    Description: A class representing a complete electrical circuit for SPICE export.
*/

struct Edge{
    var id: UUID := UUID();
    var fromNode: Node;
    var toNode: Node;
    var component: Component;

    init(id: UUID = UUID(), fromNode: Node, toNode: Node, component: Component) {
        self.id = id;
        self.fromNode = fromNode;
        self.toNode = toNode;
        self.component = component;
    }
}

class CircuitGraph{
    var nodes: Node[] := [];
    var components: Component[] := [];
    var edges: 

}