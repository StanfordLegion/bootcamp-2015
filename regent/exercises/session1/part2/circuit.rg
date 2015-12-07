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
local validator = require("session1/circuit_validator")

-- The length of a timestep is 0.1 us
local dT = 1e-7

-- FIXME: Implement task 'calculate_new_currents'.
task calculate_new_currents(conf : CktConfig
                            -- FIXME: Declare parameters as you need
                           )
-- FIXME: Declare right privileges

  --for w in rw do
  --  for j = 0, conf.steps do
  --  end
  --end
end

-- FIXME: Implement task 'distribute_charge'.
task distribute_charge( -- FIXME: Declare parameters as you need
                      )
-- FIXME: Declare right privileges

  --for w in rw do
  --end
end

-- The 'update_voltages' task accumulates the contribution of
-- charge to voltage and then applies leakage
task update_voltages(rn : region(Node))
where reads(rn.{capacitance, leakage}),
      reads writes(rn.{voltage, charge})
do
  for n in rn do
    var voltage = n.voltage + n.charge / n.capacitance
    voltage = voltage * (1.0 - n.leakage)
    n.voltage = voltage
    n.charge = 0.0
  end
end

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
  helper.dump_graph(conf, rn, rw)

  c.printf("Starting main simulation loop\n")
  var ts_start = helper.timestamp()

  -- FIXME: Complete the simulation loop.
  for j = 0, conf.num_loops do
    update_voltages(rn)
  end

  -- Force all previous tasks to complete before continuing.
  helper.wait_for(rn, rw)
  var ts_end = helper.timestamp()
  c.printf("simulation complete\n")

  var sim_time = 1e-6 * (ts_end - ts_start)
  c.printf("ELAPSED TIME = %7.3f s\n", sim_time)

  -- Bonus Point: Calculate FLOPS of your implementation.
  var flops_cnc, flops_dc, flops_uv = 0, 0, 0
  var gflops =
    helper.calculate_gflops(sim_time, flops_cnc, flops_dc, flops_uv, conf)
  c.printf("GFLOPS = %7.3f GFLOPS\n", gflops)

  c.printf("Validating simulation results...\n")
  validator.validate_solution(rn, rw, conf)
end
regentlib.start(toplevel)
