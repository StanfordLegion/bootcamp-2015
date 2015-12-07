import "regent"

local c = regentlib.c

fspace Currents {
  _0 : float,
  _1 : float,
  _2 : float,
}

fspace Voltages {
  _1 : float,
  _2 : float,
}

fspace Node {
  capacitance : float,
  leakage     : float,
  charge      : float,
  voltage     : float,
}

fspace Wire(rn : region(Node)) {
  in_node     : ptr(Node, rn),
  out_node    : ptr(Node, rn),
  inductance  : float,
  resistance  : float,
  capacitance : float,
  current     : Currents,
  voltage     : Voltages,
}

local CktConfig = require("session1/circuit_config")
local helper = require("session1/circuit_helper")
local validator = require("session2/circuit_partition_validator")

task toplevel()
  var conf : CktConfig
  conf:initialize_from_command()
  conf:show()

  var num_circuit_nodes = conf.num_pieces * conf.nodes_per_piece
  var num_circuit_wires = conf.num_pieces * conf.wires_per_piece

  var rn = region(ispace(ptr, num_circuit_nodes), Node)
  var rw = region(ispace(ptr, num_circuit_wires), Wire(rn))

  new(ptr(Node, rn), num_circuit_nodes)
  new(ptr(Wire(rn), rw), num_circuit_wires)

  c.printf("Generating a random circuit...\n")
  helper.generate_random_circuit(rn, rw, conf)

  -- This initial partition of nodes should be the basis of other partitions.
  var colors = ispace(int1d, conf.num_pieces)
  var pn_equal = partition(equal, rn, colors)

  -- TODO: Compute the following partitions of nodes.
  var pn_private
  var pn_shared
  var pn_ghost

  -- TODO: Compute the partition of wires.
  var pw

  -- Put back this call if you want to print out the graph.
  -- helper.dump_graph(conf, rn, rw)

  -- Your partitions should pass this validation.
  -- For each node and wire, validator checks if it belongs to a right region.
  c.printf("Validating your circuit partitions...\n")
  validator.validate_partitions(conf, rn, rw,
                                pn_private, pn_shared, pn_ghost, pw)
end
regentlib.start(toplevel)
