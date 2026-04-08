/**
    Author: Vipaswi Thapa
    Date: 2024-06-01
    Description: Manages the lifecycle of an LTspice process on macOS. Writes the netlist
    to a temp file, spawns LTspice via Process() in headless batch mode (-b), waits for
    completion, and returns the paths to the .raw and .log output files.
    Does not parse results. Does not mutate the graph.
*/

import Foundation

struct LTSpiceRunner {

    static func run(netlist: String) -> (rawPath: URL, logPath: URL)? {
        return nil
    }
}
