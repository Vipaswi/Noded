/**
    Author: Vipaswi Thapa
    Date: 2024-06-01
    Description: A struct that parses LTspice .raw and .log output into structured Swift data.
    Keyed by node/component UUID so the UI can annotate components with simulated values.
    Never stored inside Component — it is a separate artifact produced after simulation.
*/

import Foundation

struct SimulationResult: Codable {
    var nodeVoltages: [UUID: Double]
    var branchCurrents: [UUID: Double]

    init(nodeVoltages: [UUID: Double] = [:], branchCurrents: [UUID: Double] = [:]) {
        self.nodeVoltages = nodeVoltages
        self.branchCurrents = branchCurrents
    }
}
