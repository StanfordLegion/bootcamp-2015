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

-- The length of a timestep is 0.1 us.
local dT = 1e-7

-- TODO: Implement task 'calculate_new_currents'.
task calculate_new_currents(conf : CktConfig)
                            -- TODO: Declare more parameters as needed.
-- TODO: Declare privileges.

  -- TODO: Starting with the following code, implement the body of the task.
  --for w in rw do
  --  for s = 1, conf.steps + 1 do
  --  end
  --end
end

-- TODO: Implement task 'distribute_charge'.
task distribute_charge() -- TODO: Declare parameters as needed.
-- TODO: Declare privileges.

  -- TODO: Starting with the following code, implement the body of the task.
  --for w in rw do
  --end
end

-- The 'update_voltages' task accumulates the contribution of charge
-- to voltage and then applies leakage.
task update_voltages(rn : region(Node))
where
  reads(rn.{capacitance, leakage}),
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

  -- This is our solution for Session 1 Part 1. Does it match what you wrote?
  var num_circuit_nodes = conf.num_pieces * conf.nodes_per_piece
  var num_circuit_wires = conf.num_pieces * conf.wires_per_piece

  var rn = region(ispace(ptr, num_circuit_nodes), Node)
  var rw = region(ispace(ptr, num_circuit_wires), Wire(rn))

  new(ptr(Node, rn), num_circuit_nodes)
  new(ptr(Wire(rn), rw), num_circuit_wires)

  c.printf("Generating a random circuit...\n")
  helper.generate_random_circuit(rn, rw, conf)
  helper.dump_graph(conf, rn, rw)

  c.printf("Starting main simulation loop\n")
  var ts_start = helper.timestamp()

  -- TODO: Complete the simulation loop by calling the other two tasks.
  for j = 0, conf.num_loops do
    update_voltages(rn)
  end

  -- Wait for all previous tasks to complete and measure the elapsed time.
  helper.wait_for(rn, rw)
  var ts_end = helper.timestamp()
  c.printf("Simulation complete\n")

  var sim_time = 1e-6 * (ts_end - ts_start)
  c.printf("ELAPSED TIME = %7.3f s\n", sim_time)

  -- Bonus: Calculate FLOPS of your implementation.
  var flops_cnc, flops_dc, flops_uv = 0, 0, 0
  var gflops =
    helper.calculate_gflops(sim_time, flops_cnc, flops_dc, flops_uv, conf)
  c.printf("GFLOPS = %7.3f GFLOPS\n", gflops)

  c.printf("Validating simulation results...\n")
  validator.validate_solution(rn, rw, conf)
end
regentlib.start(toplevel)
