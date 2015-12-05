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

-- FIXME: declare fieldspace 'Node' that contains the following fields:
--          'capacitance' of type float
--          'leakage' of type float
--          'charge' of type float
--          'voltage' of type float
fspace Node
{
}

-- FIXME: declare fieldspace 'Wire' that contains following fields:
--          'in_node' of pointer type to region(Node)
--          'out_node' of pointer type to region(Node)
--          'inductance' of type float
--          'resistance' of type float
--          'current' of structure type 'Currents'
--          'voltage' of structure type 'Voltages'
fspace Wire(rn : region(Node))
{
}


local CktConfig = require("session1/circuit_config")
local helper = require("session1/circuit_helper")

task toplevel()
  -- variable 'conf' contains the configuration of a circuit we're simulating.
  var conf : CktConfig
  conf:initialize_from_command()
  conf:show()

  -- FIXME: create two logical regions for nodes and wires.
  --        the indexspaces of the two should be large enough
  --        to hold the nodes and wires.
  var rn
  var rw

  -- FIXME: allocate enough number of elements in the two regions.
  --        you should use operator 'new' to allocate a pointer to a region
  --        which takes a type of the pointer to create

  c.printf("Generating random circuit...\n")

  helper.generate_random_circuit(rn, rw, conf)

  -- you would be able to see the graph once you complete this exercise, 
  helper.dump_graph(conf, rn, rw)
end
regentlib.start(toplevel)
