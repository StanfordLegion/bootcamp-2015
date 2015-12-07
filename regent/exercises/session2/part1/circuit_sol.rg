-- Copyright 2015 Stanford University
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

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
  var pw_outgoing = preimage(rw, pn_equal, rw.in_node)
  var pw_incoming = preimage(rw, pn_equal, rw.out_node)
  var pw_crossing_out = pw_outgoing - pw_incoming
  var pw_crossing_in = pw_incoming - pw_outgoing
  var pw_crossing = pw_crossing_out | pw_crossing_in
  var pn_shared = pn_equal & (image(rn, pw_crossing, rw.in_node) | image(rn, pw_crossing, rw.out_ptr))
  var pn_private = pn_equal - pn_shared
  var pn_ghost = (image(rn, pw_crossing_out, rw.out_ptr) | image(rn, pw_crossing_in, rw.in_node)) - pn_shared

  helper.dump_graph(conf, rn, rw)
end
regentlib.start(toplevel)
