/**
    Author: Vipaswi Thapa
    Date: 2024-06-01
    Description: A struct representing one independently simulable connected component of the
    full circuit. Produced by running a connected-components traversal on CircuitGraph.
    Passed directly to SpiceExporter and LTSpiceRunner.
*/

import Foundation

struct SubGraph: Codable {
    var nodes: [Node]
    var edges: [Edge]

    init(nodes: [Node] = [], edges: [Edge] = []) {
        self.nodes = nodes
        self.edges = edges
    }
}
