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

struct Currents {
  _0 : float,
  _1 : float,
  _2 : float,
}

struct Voltages {
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

  var colors = ispace(int1d, conf.num_pieces)
  var pn_equal = partition(equal, rn, colors)
  var pw = preimage(rw, pn_equal, rw.in_node)
  var pn_extrefs = image(rn, preimage(rw, pn_equal, rw.out_node) - pw, rw.out_node)
  var pn_private = pn_equal - pn_extrefs
  var pn_shared = pn_equal & pn_extrefs
  var pn_ghost = image(rn, pw, rw.out_node) - pn_equal

  --helper.dump_graph(conf, rn, rw)

  c.printf("Validating your circuit partitions...\n")
  validator.validate_partitions(conf, rn, rw,
                                pn_private, pn_shared, pn_ghost, pw)
end
regentlib.start(toplevel)
