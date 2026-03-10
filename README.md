# Noded

Noded is not a drawing app.  
Noded is a **circuit graph generation engine disguised as a sketch interface**.

The system converts raw geometry into structured electrical topology and exports that topology to LTspice for simulation.

The architecture is layered and strictly separated. Violating layer boundaries will corrupt the system.

---

## Core Philosophy

Noded enforces separation between:

1. **Geometry** — what the user drew
2. **Recognition** — interpretation of geometry
3. **Semantic Components** — electrical meaning
4. **Topology** — graph representation
5. **Translation** — SPICE generation
6. **Simulation** — external execution and result parsing
7. **Persistence** — document storage

Each layer must remain isolated. No layer may import from a layer above it.

---

## System Flow

```
Geometry (raw strokes)
→ Feature Extraction
→ Recognition Candidates
→ Semantic Components
→ Graph Builder
→ CircuitGraph
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

**Recognition is not first. Graph correctness comes before intelligence.**

---

## Architectural Rules

### 1. Geometry Is Immutable and Sacred

Geometry represents raw user intent.

- It is never modified after creation.
- It does not store semantic meaning.
- It does not store topology data.
- It does not store simulation data.

If recognition changes, geometry does not. Geometry is the source of truth.

---

### 2. Recognition Is Non-Destructive

Recognition produces **candidates**, not final components.

Recognition:
- does not alter geometry
- does not build topology
- does not run simulation

It suggests semantic interpretations. It is fully replaceable — swapping the classifier must never require changes to Geometry, Topology, or Simulation.

---

### 3. Semantic Components Reference Geometry

Semantic components reference geometry by UUID. They do not own geometry.

This allows:
- Reprocessing recognition without data loss
- Switching back to raw drawing at any time
- Partial re-evaluation of a subset of strokes

---

### 4. Topology Is Built from Terminals — NOT Strokes

Nodes are formed by clustering terminals.

**Never use raw stroke endpoints to build topology.**

Process:
```
Components
→ Terminals
→ Snap to grid
→ Cluster by proximity
→ Create Nodes
```

Topology must be deterministic and independent of recognition confidence.

---

### 5. CircuitGraph Is Simulation-Ready

CircuitGraph must contain:
- Nodes
- Edges
- Component electrical values

CircuitGraph must NOT contain:
- Geometry
- Recognition scores
- UI state

CircuitGraph is pure electrical structure. It must be SPICE-ready at all times.

---

### 6. Simulation Is Stateless

Simulation:
- Receives `CircuitGraph`
- Produces `SimulationResult`
- Does not mutate the graph

Simulation results are stored separately from components and topology.

---

### 7. Persistence Is Document-Based

Noded uses file-based document storage. No database.

Each document contains:
- `GeometryDocument`
- Semantic Components
- `CircuitGraph`
- Simulation metadata

Documents must be portable, self-contained, and reconstructable.

---

## Design Constraints

- No cross-layer imports
- No UI dependencies in any backend module
- UUID-based referencing only — no index-based linking
- No floating-point comparisons without grid snapping
- No simulation state stored inside components
- No geometry stored inside `CircuitGraph`

**If a struct imports something from a higher layer, the design is broken.**

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
│   ├── ComponentValue.swift
│   ├── Terminal.swift
│   └── Component.swift
│
├── Topology/
│   ├── Node.swift
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

**`Point2D.swift`**  
A lightweight, `Codable`, `Hashable` wrapper around `CGPoint`. Exists so that the rest of the system is not directly coupled to CoreGraphics. If the coordinate system ever changes, this is the only file that needs to change. Contains `x`, `y`, and a conversion back to `CGPoint`. Nothing else.

**`StrokePoint.swift`**  
Represents a single captured input sample within a stroke. Stores `position: Point2D`, `timestamp: TimeInterval`, and optionally `pressure: CGFloat`. This is the atomic unit of user input. Must not store any derived or semantic data.

**`Stroke.swift`**  
An immutable sequence of `StrokePoint` values representing one continuous gesture by the user. Precomputes and stores a `boundingBox: CGRect` at init time for efficient spatial queries downstream. Has a stable `UUID`. Must never be mutated after creation — if the user modifies a drawing, a new `Stroke` is created. Must not reference components, nodes, or any semantic concept.

**`GeometryDocument.swift`**  
The root container for all raw strokes on a single canvas. Acts as the boundary object passed into the Recognition layer. Stores strokes in a `[UUID: Stroke]` dictionary for O(1) lookup by ID. Exposes `addStroke`, `removeStroke`, and `stroke(id:)`. This is the only geometry object the rest of the system sees — nothing reaches past it into individual strokes directly.

---

### Recognition/

**`FeatureExtractor.swift`**  
Takes a `Stroke` (or group of strokes) and produces a numerical feature representation — e.g., resampled point sequences, curvature vectors, bounding box aspect ratios, direction histograms. This is pure geometry-to-math conversion. No classification happens here. Output feeds into `ShapeNormalizer` and `SymbolClassifier`.

**`ShapeNormalizer.swift`**  
Removes positional, scale, and rotational variance from extracted features so that classification is order-invariant and position-invariant. Handles resampling to uniform point spacing, centering to centroid, scale normalization, and principal-axis alignment. Without this step, the same resistor drawn at different sizes or angles would classify differently. This file is where Procrustes alignment, Hausdorff prep, or $1-Recognizer normalization lives.

**`SymbolClassifier.swift`**  
Accepts normalized features and returns a ranked list of `RecognitionCandidate` values with confidence scores. This is the only file that contains classification logic. It is intentionally designed to be swappable — if the algorithm changes from heuristic to CoreML to a transformer, only this file changes. Must not produce `Component` objects directly. Must not assign electrical values. Must not assign terminals.

**`RecognitionCandidate.swift`**  
A single hypothesis produced by `SymbolClassifier`. Contains a `ComponentType`, a `confidence: Double`, and the `geometryIDs: [UUID]` of the strokes that contributed to this hypothesis. This is not a component — it is a suggestion. Multiple candidates may be generated for the same stroke group.

**`RecognitionResult.swift`**  
The complete output of one recognition pass over a `GeometryDocument`. Contains an array of `RecognitionCandidate` values. This is what gets handed to the Semantic layer for resolution into actual `Component` objects. Must not be stored inside geometry. Is considered ephemeral — it can be regenerated at any time from the original strokes.

---

### Semantic/

**`ComponentValue.swift`**  
Represents the electrical parameter of a component — e.g., resistance in ohms, capacitance in farads, voltage. Stores `magnitude: Double` and `unit: UnitType`. Even in early phases where values are not yet parsed from handwriting, this struct exists as a placeholder so that `Component` is already architecturally ready for value assignment later.

**`Terminal.swift`**  
A named connection point on a component. Has a `UUID`, a `position: Point2D` (in world/canvas space), and a `label: String` (e.g., `"anode"`, `"cathode"`, `"positive"`, `"negative"`). Terminals are what the `GraphBuilder` clusters into `Node` objects — they are the bridge between semantic components and circuit topology. Must not reference `Node` directly (that would be a forward dependency violation).

**`Component.swift`**  
The resolved semantic interpretation of one or more strokes. Contains a `UUID`, a `ComponentType`, an array of `Terminal` values, a `ComponentValue`, and `geometryIDs: [UUID]` referencing the source strokes. This is the authoritative semantic object. It is created by a factory that consumes `RecognitionCandidate` — not by the recognizer itself. Does not store topology. Does not store simulation results.

---

### Topology/

**`Node.swift`**  
Represents an electrical junction — a net in SPICE terminology. Has a `UUID` and a `position: Point2D` (the centroid of the clustered terminals that formed it). No geometry references. No stroke references. This is pure electrical topology. A `Node` is always derived — it is never created manually by the user.

**`CircuitGraph.swift`**  
The complete electrical representation of a circuit, ready for SPICE export at any time. Contains `nodes: [Node]` and `edges: [Edge]`, where each `Edge` links a `Component` to two `Node` UUIDs. Contains no geometry, no recognition scores, no UI state. This is the single object consumed by `SpiceExporter`. It is the output artifact of the entire backend pipeline.

**`GraphBuilder.swift`**  
Constructs a `CircuitGraph` from a list of `Component` objects. The algorithm: extract all terminals → snap positions to grid → cluster terminals within a proximity threshold → create one `Node` per cluster → create one `Edge` per component linking its terminal nodes. This file owns the snapping and clustering logic. It is deterministic and must produce the same graph given the same components regardless of insertion order.

---

### Export/

**`SpiceExporter.swift`**  
Accepts a `CircuitGraph` and produces a SPICE netlist as a `String`. Maps each `Node` to a net name, each `Edge`/`Component` to the appropriate SPICE element line (e.g., `R1 net1 net2 10k`), and appends simulation directives (`.tran`, `.ac`, etc.) as configured. This file must not import Geometry, Recognition, or Simulation. It is a pure `CircuitGraph → String` transform.

---

### Simulation/

**`LTSpiceRunner.swift`**  
Manages the lifecycle of an LTspice process on macOS. Writes the netlist to a temp file, spawns LTspice via `Process()` in headless batch mode (`-b`), waits for completion, and returns the paths to the `.raw` and `.log` output files. Does not parse results — that is `SimulationResult`'s job. Does not mutate the `CircuitGraph`. On iOS/iPadOS this would instead POST the netlist to a backend service.

**`SimulationResult.swift`**  
Parses the LTspice `.raw` waveform file and `.log` file into structured Swift data. Stores node voltages (`[UUID: Double]`), branch currents (`[UUID: Double]`), and waveform time-series data for graphing. Keyed by node/component UUID so that the UI can annotate components with their simulated values. This is never stored inside `Component` — it is a separate artifact produced after simulation.

---

### Persistence/

**`NodedDocument.swift`**  
The top-level document model for a single Noded file. Conforms to `FileDocument` for SwiftUI document-based app integration. Aggregates: `GeometryDocument`, `[Component]`, `CircuitGraph`, and optional `SimulationResult` metadata. Responsible for encoding to and decoding from the `.noded` file bundle (JSON + binary assets). This is the only file that knows about all layers simultaneously — and only for the purpose of serialization. It must not contain any processing logic; it is a data container only.

---

## Non-Negotiable Rules

If you ever find yourself doing any of the following, stop immediately:

- Adding node references inside `Stroke`
- Adding electrical values inside `Geometry`
- Importing `Topology` or `Circuit` into `Geometry`
- Storing simulation results inside `Component`
- Building `Node` objects directly from stroke endpoints

**That is architectural corruption.**

---

## Current Development Phase

- **Phase 1** — Geometry layer
- **Phase 2** — Manual `CircuitGraph` construction
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