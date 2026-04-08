# Noded

Noded is not a drawing app.
Noded is a circuit graph generation engine disguised as a sketch interface.

The system converts raw geometry into structured electrical topology and exports that topology to LTspice for simulation.

The architecture is layered and strictly separated. Violating layer boundaries will corrupt the system.

---

## Core Philosophy

Noded enforces separation between:

- **Geometry** — what the user drew
- **Recognition** — interpretation of geometry
- **Semantic Components** — electrical meaning
- **Topology** — graph representation
- **Export** — SPICE generation
- **Simulation** — external execution and result parsing
- **Persistence** — document storage

Each layer must remain isolated. No layer may import from a layer above it.

---

## System Flow

```
Geometry (raw strokes)
→ Feature Extraction
→ Recognition Candidates
→ Semantic Components (type + transform + terminals)
→ Graph Builder
→ CircuitGraph (nodes + edges + subgraphs)
→ SPICE Export
→ LTspice Execution
→ SimulationResult
```

Each stage must be independently testable.

---

## Implementation Order — Do Not Deviate

1. Geometry layer
2. CircuitGraph + manual component construction
3. SPICE exporter
4. LTspice integration
5. Recognition engine
6. Text/value recognition

Recognition is not first. Graph correctness comes before intelligence.

---

## Architectural Rules

### 1. Geometry Is Immutable and Sacred

Geometry represents raw user intent.

- It is never modified after creation.
- It does not store semantic meaning.
- It does not store topology data.
- It does not store simulation data.

If recognition changes, geometry does not. Geometry is the source of truth. When the user modifies a drawing, a new Stroke is created — the old one is never mutated.

### 2. Recognition Is Non-Destructive

Recognition produces candidates, not final components.

Recognition:
- does not alter geometry
- does not build topology
- does not run simulation
- does not produce terminals

It suggests a ComponentType and a confidence score. It is fully replaceable — swapping the classifier must never require changes to Geometry, Topology, or Simulation.

### 3. Terminals Are Template-Derived, Not Recognized

Terminal positions are never inferred from stroke geometry directly.

Once Recognition produces a ComponentType, the Semantic layer:
1. Looks up the canonical terminal layout for that ComponentType from the template registry.
2. Computes the affine transform (translation + scale + rotation) that maps the template's bounding box to the recognized stroke's bounding box.
3. Applies that transform to the template's terminal positions to produce world-space Terminal coordinates.

This transform is stored on the Component. It is reused for rendering the template overlay and recomputed only when the user selects a different ComponentType or explicitly rescales.

Terminal positions are authoritative as long as the component type and transform are unchanged.

### 4. Semantic Components Reference Geometry

Semantic components reference geometry by UUID. They do not own geometry.

This allows:
- Reprocessing recognition without data loss
- Switching back to raw drawing at any time
- Partial re-evaluation of a subset of strokes

### 5. Topology Is Built from Snap Events — Not Proximity

Nodes are not discovered by proximity scanning. They are formed by explicit snap events.

When a terminal snaps to another terminal, that event is the authoritative connection. The two terminals are assigned to the same Node at that moment.

GraphBuilder reads declared connections. It does not scan for nearby terminals. Proximity clustering is not used anywhere in this system.

A Node is the electrical net formed by one or more connected terminals. A wire stroke extends a node spatially but does not change its identity — it is still one net. The wire exists in GeometryDocument as a stroke. In CircuitGraph, it appears only as the reason two terminals share a Node.

Subgraph decomposition (identifying independently simulable circuits) is performed on CircuitGraph via connected-components traversal, not on GeometryDocument.

### 6. CircuitGraph Is Simulation-Ready

CircuitGraph must contain:
- Nodes (nets)
- Edges (components between two nodes)
- SubGraphs (connected components, each independently simulable)
- Component electrical values

CircuitGraph must NOT contain:
- Geometry
- Recognition scores
- UI state
- Wire stroke references

CircuitGraph is pure electrical structure. It must be SPICE-ready at all times.

A single Component with all terminals assigned to nodes is considered simulable and can be exported and run independently.

### 7. Simulation Is Stateless

Simulation:
- Receives a CircuitGraph or SubGraph
- Produces a SimulationResult
- Does not mutate the graph

Simulation results are stored separately from components and topology.

### 8. Persistence Is Document-Based

Noded uses file-based document storage. No database.

Each document contains:
- GeometryDocument
- Semantic Components
- CircuitGraph (including snap connections — these are stored explicitly)
- Simulation metadata

Snap connections are stored as declared terminal-to-terminal pairs. On load, the graph is reconstructed exactly from these pairs. There is no inference step on load. Documents are portable, self-contained, and reconstructable 1:1.

---

## Design Constraints

- No cross-layer imports
- No UI dependencies in any backend module
- UUID-based referencing only — no index-based linking
- No floating-point comparisons without grid snapping
- No simulation state stored inside components
- No geometry stored inside CircuitGraph
- No proximity clustering — snaps are always explicit and persisted
- No terminal inference from strokes — terminals always come from templates

If a struct imports something from a higher layer, the design is broken.

---

## Struct vs Class Decision Rules

Use **struct** for anything that is a pure value, is immutable after creation, or is passed between layers as data:

- `Point2D`, `StrokePoint`, `Stroke` — atomic geometry values
- `RecognitionCandidate`, `RecognitionResult` — ephemeral output, fully reproducible
- `Terminal`, `ComponentValue` — value types on a component
- `Node`, `Edge` — topology values
- `SubGraph` — a slice of CircuitGraph, passed to simulation
- `SimulationResult` — output artifact, never mutated

Use **class** for anything that has identity, is mutated in place over time, or needs to be observed:

- `GeometryDocument` — strokes are added and removed during drawing
- `CircuitGraph` — connections are established incrementally as the user snaps terminals
- `NodedDocument` — the live document model aggregating all layers

Recognition and Export have no persistent state. Their types are enums with static methods or plain structs with a single entry point.

---

## Module Structure

```
NodedCore/
│
├── Geometry/
│   ├── Point2D.swift
│   ├── StrokePoint.swift
│   ├── Stroke.swift
│   └── GeometryDocument.swift
│
├── Recognition/
│   ├── FeatureExtractor.swift
│   ├── ShapeNormalizer.swift
│   ├── SymbolClassifier.swift
│   ├── RecognitionCandidate.swift
│   └── RecognitionResult.swift
│
├── Semantic/
│   ├── ComponentType.swift
│   ├── ComponentTemplate.swift
│   ├── ComponentValue.swift
│   ├── Terminal.swift
│   └── Component.swift
│
├── Topology/
│   ├── Node.swift
│   ├── Edge.swift
│   ├── SubGraph.swift
│   ├── CircuitGraph.swift
│   └── GraphBuilder.swift
│
├── Export/
│   └── SpiceExporter.swift
│
├── Simulation/
│   ├── LTSpiceRunner.swift
│   └── SimulationResult.swift
│
└── Persistence/
    └── NodedDocument.swift
```

Layer direction:

```
Geometry → Recognition → Semantic → Topology → Export → Simulation
```

Never reverse this direction.

---

## File Intentions

### Geometry/

**Point2D.swift**
A lightweight, `Codable`, `Hashable` struct wrapping a 2D coordinate. Exists so the rest of the system is not coupled to CoreGraphics. Contains `x`, `y`, and a conversion to `CGPoint`. If the coordinate system changes, this is the only file that changes. Nothing else.

**StrokePoint.swift**
A struct representing a single captured input sample within a stroke. Stores `position: Point2D`, `timestamp: TimeInterval`, and optionally `pressure: CGFloat`. This is the atomic unit of user input. Must not store any derived or semantic data.

**Stroke.swift**
An immutable struct representing one continuous gesture. Stores an array of `StrokePoint` values and precomputes `boundingBox: CGRect` at init time. Has a stable UUID. Must never be mutated after creation — modifications produce a new Stroke. Must not reference components, nodes, or any semantic concept.

**GeometryDocument.swift**
A class (mutable, observed) acting as the root container for all raw strokes on a canvas. Stores strokes in a `[UUID: Stroke]` dictionary for O(1) lookup. Exposes `addStroke`, `removeStroke`, and `stroke(id:)`. This is the only geometry object the rest of the system sees. Nothing reaches past it into individual strokes directly.

---

### Recognition/

**FeatureExtractor.swift**
Takes a `Stroke` (or group of strokes) and produces a numerical feature representation — resampled point sequences, curvature vectors, bounding box aspect ratios, direction histograms. Pure geometry-to-math conversion. No classification happens here.

**ShapeNormalizer.swift**
Removes positional, scale, and rotational variance from extracted features so classification is invariant to position, size, and orientation. Handles resampling to uniform point spacing, centering to centroid, scale normalization, and principal-axis alignment. This is where $1-Recognizer normalization lives.

**SymbolClassifier.swift**
Accepts normalized features and returns a ranked list of `RecognitionCandidate` values with confidence scores. The only file containing classification logic. Intentionally swappable — if the algorithm changes, only this file changes. Must not produce `Component` objects. Must not assign terminals. Must not assign electrical values.

**RecognitionCandidate.swift**
A struct representing a single hypothesis produced by `SymbolClassifier`. Contains a `ComponentType`, a `confidence: Double`, and `geometryIDs: [UUID]` of the contributing strokes. This is not a component — it is a suggestion. Multiple candidates may exist for the same stroke group.

**RecognitionResult.swift**
A struct holding the complete output of one recognition pass over a `GeometryDocument`. Contains an array of `RecognitionCandidate` values sorted by confidence. Handed to the Semantic layer for resolution. Considered ephemeral — it can be regenerated at any time from the original strokes. Never stored inside geometry.

---

### Semantic/

**ComponentType.swift**
An enum of all supported electrical component types (e.g., `.resistor`, `.capacitor`, `.voltageSource`, `.wire`). Each case is the key used to look up its `ComponentTemplate`.

**ComponentTemplate.swift**
A struct defining the canonical geometry of a component type: its normalized bounding box and the relative positions of its terminals within that box. Acts as the source of truth for terminal layout. Stored in a static registry keyed by `ComponentType`. Never modified at runtime.

**ComponentValue.swift**
A struct representing the electrical parameter of a component — resistance in ohms, capacitance in farads, voltage, etc. Stores `magnitude: Double` and `unit: UnitType`. Present as a placeholder even before value parsing is implemented so `Component` is architecturally ready for value assignment.

**Terminal.swift**
A struct representing a named connection point on a component. Has a UUID, a `position: Point2D` in world/canvas space, and a `label: String` (e.g., `"anode"`, `"cathode"`, `"positive"`, `"negative"`). Terminal positions are computed from the component's template and affine transform — never inferred from strokes. Must not reference `Node` directly (forward dependency violation).

**Component.swift**
A struct representing the resolved semantic interpretation of one or more strokes. Contains:
- `id: UUID`
- `type: ComponentType`
- `terminals: [Terminal]`
- `value: ComponentValue`
- `geometryIDs: [UUID]` — references to source strokes
- `transform: AffineTransform` — the mapping from template space to canvas space, used to render the template overlay and recompute terminal positions if the type changes

Created by a factory that consumes a `RecognitionCandidate`. Not created by the recognizer itself. Does not store topology. Does not store simulation results.

---

### Topology/

**Node.swift**
A struct representing an electrical net. Has a `UUID` and stores the `terminalIDs: [UUID]` of all terminals assigned to it via snap events. Position can be derived as the centroid of its terminals if needed for rendering. No geometry references. No stroke references. Always derived — never created manually by the user.

**Edge.swift**
A struct representing a component's presence in the circuit graph. Stores the `componentID: UUID` and the two `nodeIDs` that the component's terminals are connected to. An edge is a component, not a wire. Wires are geometry that cause terminals to share a node — they do not appear as edges.

**SubGraph.swift**
A struct representing one independently simulable connected component of the full circuit. Contains a subset of `Node` and `Edge` values from `CircuitGraph`. Produced by running a connected-components traversal on `CircuitGraph`. Passed directly to `SpiceExporter` and `LTSpiceRunner`. A single component with all terminals assigned is a valid SubGraph.

**CircuitGraph.swift**
A class (mutable, built incrementally) representing the complete electrical topology of a canvas. Contains `nodes: [UUID: Node]`, `edges: [UUID: Edge]`, and a computed `subGraphs: [SubGraph]`. Accepts snap events via `connect(terminalA:terminalB:)` which creates or merges nodes. Exposes `subGraphs` by running connected-components on demand. Contains no geometry, no recognition scores, no UI state. Consumed by `SpiceExporter`.

**GraphBuilder.swift**
Constructs a `CircuitGraph` from a list of `Component` objects and a list of persisted terminal-to-terminal connections. The algorithm: for each stored connection, retrieve the two terminals, create or merge their nodes in the graph, create an edge for each component. Deterministic and order-independent. Does not scan geometry. Does not cluster by proximity. Used on document load to reconstruct the graph from persisted snap data.

---

### Export/

**SpiceExporter.swift**
Accepts a `SubGraph` and produces a SPICE netlist as a `String`. Maps each `Node` to a net name, each `Edge`/`Component` to the appropriate SPICE element line (e.g., `R1 net1 net2 10k`), and appends simulation directives (`.tran`, `.ac`, etc.) as configured. Must not import Geometry, Recognition, or Simulation. Pure `SubGraph → String` transform.

---

### Simulation/

**LTSpiceRunner.swift**
Manages the lifecycle of an LTspice process on macOS. Writes the netlist to a temp file, spawns LTspice via `Process()` in headless batch mode (`-b`), waits for completion, and returns the paths to the `.raw` and `.log` output files. Does not parse results. Does not mutate the graph. On iOS/iPadOS this would POST the netlist to a backend service instead.

**SimulationResult.swift**
A struct that parses the LTspice `.raw` waveform file and `.log` file into structured Swift data. Stores node voltages (`[UUID: Double]`), branch currents (`[UUID: Double]`), and waveform time-series data for graphing. Keyed by node/component UUID so the UI can annotate components with simulated values. Never stored inside `Component` — it is a separate artifact produced after simulation.

---

### Persistence/

**NodedDocument.swift**
A class conforming to `FileDocument` for SwiftUI document-based app integration. The top-level model for a single Noded file. Aggregates:
- `GeometryDocument`
- `[Component]`
- `CircuitGraph`
- Persisted snap connections: `[(terminalID: UUID, terminalID: UUID)]`
- Optional `SimulationResult` metadata

Responsible for encoding to and decoding from the `.noded` file bundle (JSON + binary assets). On load, passes the persisted snap connections to `GraphBuilder` to reconstruct `CircuitGraph` exactly. Must not contain any processing logic. It is a data container only. The only file that knows about all layers simultaneously — and only for serialization.

---

## Non-Negotiable Rules

Stop immediately if you find yourself doing any of the following:

- Adding node references inside `Stroke`
- Adding electrical values inside Geometry
- Importing Topology or Circuit into Geometry
- Storing simulation results inside `Component`
- Building `Node` objects by scanning stroke endpoints or clustering terminal proximity
- Inferring terminal positions from stroke geometry instead of computing them from the template and transform
- Storing snap connections only in memory without persisting them

That is architectural corruption.

---

## Current Development Phase

- **Phase 1** — Geometry layer
- **Phase 2** — Manual CircuitGraph construction
- **Phase 3** — SPICE export

Recognition comes later. Stay focused.

---

## Long-Term Vision

Noded will:

- Convert sketch to structured circuit topology
- Generate SPICE netlists
- Execute LTspice simulations
- Parse waveform results
- Allow intelligent circuit refinement

None of that works unless the graph layer is correct first.

**Graph correctness is everything.**