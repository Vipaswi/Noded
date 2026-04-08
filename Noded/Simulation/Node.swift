/**
    Author: Vipaswi Thapa
    Date: 2024-06-01
    Description: A struct representing an electrical net. Stores the UUIDs of all terminals
    assigned to this net via explicit snap events. Never created manually by the user.
*/

import Foundation

struct Node: Codable, Identifiable {
    let id: UUID
    var terminalIDs: [UUID]

    init(id: UUID = UUID(), terminalIDs: [UUID] = []) {
        self.id = id
        self.terminalIDs = terminalIDs
    }
}
