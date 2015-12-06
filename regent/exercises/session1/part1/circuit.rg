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

-- TODO: The following fields to the 'Node' field space:
--   * 'capacitance' of type float
--   * 'leakage' of type float
--   * 'charge' of type float
--   * 'voltage' of type float
fspace Node
{
}

-- TODO: Add the following fields to the 'Wire' field space:
--   * 'in_node' of pointer type to region(Node)
--   * 'out_node' of pointer type to region(Node)
--   * 'inductance' of type float
--   * 'resistance' of type float
--   * 'current' of structure type 'Currents'
--   * 'voltage' of structure type 'Voltages'
fspace Wire(rn : region(Node))
{
}


local CktConfig = require("session1/circuit_config")
local helper = require("session1/circuit_helper")

task toplevel()
  -- Variable 'conf' contains the configuration of a circuit we're simulating.
  var conf : CktConfig
  conf:initialize_from_command()
  conf:show()

  -- TODO: Create two logical regions for nodes and wires. The
  -- indexspaces of the two should be large enough to hold the nodes
  -- and wires.
  var rn
  var rw

  -- TODO: Allocate enough number of elements in the two regions. Use
  -- the 'new' operator to allocate a pointer to a region which takes
  -- a type of the pointer to create.

  c.printf("Generating random circuit...\n")

  helper.generate_random_circuit(rn, rw, conf)

  -- you would be able to see the graph once you complete this exercise, 
  helper.dump_graph(conf, rn, rw)
end
regentlib.start(toplevel)
