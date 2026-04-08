/**
    Author: Vipaswi Thapa
    Date: 2024-06-01
    Description: The top-level model for a single Noded file. Conforms to FileDocument for
    SwiftUI document-based app integration. Aggregates all layers for serialization.
    The only file that knows about all layers simultaneously — and only for serialization.
    Must not contain any processing logic.
*/

import Foundation
import SwiftUI
import UniformTypeIdentifiers

class NodedDocument: FileDocument {
    var geometryDocument: GeometryDocument
    var components: [Component]
    var circuitGraph: CircuitGraph
    var snapConnections: [(UUID, UUID)]
    var simulationResult: SimulationResult?

    static var readableContentTypes: [UTType] { [.json] }

    init() {
        geometryDocument = GeometryDocument()
        components = []
        circuitGraph = CircuitGraph()
        snapConnections = []
        simulationResult = nil
    }

    required init(configuration: ReadConfiguration) throws {
        geometryDocument = GeometryDocument()
        components = []
        circuitGraph = CircuitGraph()
        snapConnections = []
        simulationResult = nil
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper()
    }
}
