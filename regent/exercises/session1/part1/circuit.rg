-- Every Regent program starts with the following line, which loads
-- the language definition.
import "regent"

-- We're going to need access to a few C functions (e.g. printf).
local c = regentlib.c

-- These two field spaces hold currents and voltages,
-- respectively. You'll need to reference them below.
struct Currents {
  _0 : float,
  _1 : float,
  _2 : float,
}

struct Voltages {
  _1 : float,
  _2 : float,
}

-- TODO: Add the following fields to the 'Node' field space:
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

-- These are some helper modules for the exercise.
local CktConfig = require("session1/circuit_config")
local helper = require("session1/circuit_helper")

task toplevel()
  -- Variable 'conf' contains the configuration of the circuit we're simulating.
  var conf : CktConfig
  conf:initialize_from_command()
  conf:show()

  -- TODO: Create two logical regions for nodes and wires. The index
  -- spaces should be large enough to hold the nodes and wires. Hint:
  -- The sizes can be computed from the following fields of conf:
  --   * conf.num_pieces (the number of pieces in the graph)
  --   * conf.nodes_per_piece (the number of nodes per piece)
  --   * conf.wires_per_piece (the number of wires per piece)
  var rn
  var rw

  -- TODO: Allocate enough number of elements in the two regions. Use
  -- the 'new' operator to allocate the elements. (Hint: Refer to the
  -- syntax guide for the syntax.)

  c.printf("Generating random circuit...\n")
  helper.generate_random_circuit(rn, rw, conf)

  -- Once you've filled in the code above, this will print out the graph.
  helper.dump_graph(conf, rn, rw)
end
regentlib.start(toplevel)
