# Noded

Noded is not a drawing app.  
Noded is a **circuit graph generation engine disguised as a sketch interface**.

The system converts raw geometry into structured electrical topology and exports that topology to LTspice for simulation.

The architecture is layered and strictly separated. Violating layer boundaries will corrupt the system.

---

# Core Philosophy

Noded enforces separation between:

1. Geometry (what the user drew)
2. Recognition (interpretation of geometry)
3. Semantic Components (electrical meaning)
4. Topology (graph representation)
5. Translation (SPICE generation)
6. Simulation (external execution + parsing)
7. Persistence (document storage)

Each layer must remain isolated.

---

# Architectural Rules

## 1. Geometry Is Immutable and Sacred

Geometry represents raw user intent.

- It is never modified after creation.
- It does not store semantic meaning.
- It does not store topology data.
- It does not store simulation data.

If recognition changes, geometry does not.

Geometry is the source of truth.

---

## 2. Recognition Is Non-Destructive

Recognition produces candidates, not final components.

Recognition:
- does not alter geometry
- does not build topology
- does not run simulation

It suggests semantic interpretations.

---

## 3. Semantic Components Reference Geometry

Semantic components reference geometry by UUID.

They do not own geometry.

This allows:
- Reprocessing recognition
- Switching back to raw drawing
- Partial re-evaluation

---

## 4. Topology Is Built from Terminals — NOT Strokes

Nodes are formed by clustering terminals.

Never use raw stroke endpoints to build topology.

Process:

Components  
→ Terminals  
→ Snap to grid  
→ Cluster by proximity  
→ Create Nodes  

Topology must be deterministic and independent of recognition confidence.

---

## 5. CircuitGraph Is Simulation-Ready

CircuitGraph must contain:

- Nodes
- Edges
- Component electrical values

It must NOT contain:

- Geometry
- Recognition scores
- UI state

CircuitGraph is pure electrical structure.

---

## 6. Simulation Is Stateless

Simulation:

- Receives CircuitGraph
- Produces SimulationResult
- Does not mutate the graph

Simulation results are stored separately.

---

## 7. Persistence Is Document-Based

Noded uses file-based document storage.

Each document contains:

- Geometry
- Semantic Components
- Circuit Graph
- Simulation metadata

Documents must be portable and self-contained.

No database-backed document storage.

---

# System Flow

Geometry (raw strokes)  
→ Feature Extraction  
→ Recognition Candidates  
→ Semantic Components  
→ Graph Builder  
→ CircuitGraph  
→ SPICE Export  
→ LTspice Execution  
→ SimulationResult  

Each stage must be independently testable.

---

# Implementation Order (Do Not Deviate)

1. Geometry layer  
2. CircuitGraph + manual component construction  
3. SPICE exporter  
4. LTspice integration  
5. Recognition engine  
6. Text/value recognition  

Recognition is not first.

Graph correctness comes before intelligence.

---

# Design Constraints

- No cross-layer imports
- No UI dependencies in backend modules
- UUID-based referencing only
- No index-based linking
- No floating precision comparisons without snapping
- No simulation state stored inside components
- No geometry stored inside CircuitGraph

If a struct imports something from a higher layer, the design is broken.

---

# Module Structure
NodedCore/
│
├── Geometry/
│ ├── Stroke.swift
│ ├── StrokePoint.swift
│ ├── GeometryDocument.swift
│ └── Point2D.swift
│
├── Recognition/
│ ├── FeatureExtractor.swift
│ ├── SymbolClassifier.swift
│ └── RecognitionResult.swift
│
├── Semantic/
│ ├── Component.swift
│ ├── Terminal.swift
│ └── ComponentValue.swift
│
├── Topology/
│ ├── Node.swift
│ ├── CircuitGraph.swift
│ └── GraphBuilder.swift
│
├── Export/
│ └── SpiceExporter.swift
│
├── Simulation/
│ ├── LTSpiceRunner.swift
│ └── SimulationResult.swift
│
└── Persistence/
└── NodedDocument.swift


Layer direction:

Geometry → Recognition → Semantic → Topology → Export → Simulation  

Never reverse this direction.

---

# Geometry Layer Definition

Geometry contains only:

- Stroke
- StrokePoint
- Bounding boxes
- Raw coordinates
- Timestamps
- Pressure (optional)

It does not know what a resistor is.  
It does not know what a node is.  
It does not know what simulation is.

Geometry is pure data.

---

# Topology Definition

CircuitGraph contains:

- Nodes (electrical junctions)
- Edges (components between nodes)

No drawing data.  
No stroke references.  
No UI state.

This must be SPICE-ready at all times.

---

# Persistence Strategy

Each document stores:

- GeometryDocument
- Semantic Components
- CircuitGraph
- Simulation metadata

Documents are portable and reconstructable.

No database dependency.

---

# Non-Negotiable Rule

If you ever:

- Add node references inside Stroke
- Add electrical values inside Geometry
- Import Circuit into Geometry
- Store simulation results inside components

Stop immediately.

That is architectural corruption.

---

# Current Development Phase

You are currently building:

Phase 1 — Geometry Layer  
Phase 2 — Manual CircuitGraph construction  
Phase 3 — SPICE Export  

Recognition comes later.

Stay focused.

---

# Long-Term Vision

Noded will:

- Convert sketch to structured circuit topology
- Generate SPICE netlists
- Execute LTspice simulations
- Parse waveform results
- Allow intelligent circuit refinement

But none of that works unless the graph layer is perfect.

Graph correctness is everything.