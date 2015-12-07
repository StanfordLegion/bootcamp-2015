import "regent"

local c = regentlib.c

fspace Currents {
  _0 : float,
  _1 : float,
  _2 : float,
}

fspace Voltages {
  _0 : float,
  _1 : float,
}

fspace Node {
  capacitance : float,
  leakage     : float,
  charge      : float,
  voltage     : float,
}

fspace Wire(rn : region(Node)) {
  in_ptr      : ptr(Node, rn),
  out_ptr     : ptr(Node, rn),
  inductance  : float,
  resistance  : float,
  capacitance : float,
  current     : Currents,
  voltage     : Voltages,
}

local CktConfig = require("session2/circuit_config")
local helper = require("session2/circuit_helper")

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

  c.printf("Generating random circuit...\n")
  helper.generate_random_circuit(rn, rw, conf)

  var colors = ispace(int1d, conf.num_pieces)
  var pn_equal = partition(equal, rn, colors)

  var pn_private
  var pn_shared
  var pn_ghost

  helper.dump_graph(conf, rn, rw)
end
regentlib.start(toplevel)
