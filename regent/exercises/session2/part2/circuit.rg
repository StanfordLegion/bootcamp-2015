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

-- TODO: Change Wire to take three arguments: private, shared, and
-- ghost nodes.
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
local helper = require("session2/circuit_helper")
local validator = require("session2/circuit_validator")

local WIRE_SEGMENTS = 3
local dT = 1e-7

-- TODO: Change this task to take three regions of nodes (private,
-- shared, and ghost).
task calculate_new_currents(steps : uint,
                            rn : region(Node),
                            rw : region(Wire(rn)))
where
  reads(rn.voltage,
        rw.{in_node, out_node, inductance, resistance, capacitance}),
  reads writes(rw.{current, voltage})
do
  var recip_dt : float = 1.0 / dT
  __demand(__vectorize)
  for w in rw do
    var temp_v : float[WIRE_SEGMENTS + 1]
    var temp_i : float[WIRE_SEGMENTS]
    var old_i : float[WIRE_SEGMENTS]
    var old_v : float[WIRE_SEGMENTS - 1]

    temp_i[0] = w.current._0
    temp_i[1] = w.current._1
    temp_i[2] = w.current._2
    for i = 0, WIRE_SEGMENTS do old_i[i] = temp_i[i] end

    temp_v[1] = w.voltage._1
    temp_v[2] = w.voltage._2
    for i = 0, WIRE_SEGMENTS - 1 do old_v[i] = temp_v[i + 1] end

    -- Pin the outer voltages to the node voltages.
    temp_v[0] = w.in_node.voltage
    temp_v[WIRE_SEGMENTS] = w.out_node.voltage

    -- Solve the RLC model iteratively.
    var inductance : float = w.inductance
    var recip_resistance : float = 1.0 / w.resistance
    var recip_capacitance : float = 1.0 / w.capacitance
    for j = 0, steps do
      -- First, figure out the new current from the voltage differential
      -- and our inductance:
      -- dV = R*I + L*I' ==> I = (dV - L*I')/R
      for i = 0, WIRE_SEGMENTS do
        temp_i[i] = ((temp_v[i + 1] - temp_v[i]) -
                     (inductance * (temp_i[i] - old_i[i]) * recip_dt)) * recip_resistance
      end
      -- Now update the inter-node voltages.
      for i = 0, WIRE_SEGMENTS - 1 do
        temp_v[i + 1] = old_v[i] + dT * (temp_i[i] - temp_i[i + 1]) * recip_capacitance
      end
    end

    -- Write out the results.
    w.current._0 = temp_i[0]
    w.current._1 = temp_i[1]
    w.current._2 = temp_i[2]

    w.voltage._1 = temp_v[1]
    w.voltage._2 = temp_v[2]
  end
end

-- TODO: Change this task to take three regions of nodes (private,
-- shared, and ghost).
task distribute_charge(rn : region(Node),
                       rw : region(Wire(rn)))
where
  reads(rw.{in_node, out_node, current._0, current._2}),
  reduces +(rn.charge)
do
  for w in rw do
    var in_current = -dT * w.current._0
    var out_current = dT * w.current._2
    w.in_node.charge += in_current
    w.out_node.charge += out_current
  end
end

task update_voltages(rn : region(Node))
where
  reads(rn.{node_cap, leakage}),
  reads writes(rn.{voltage, charge})
do
  for node in rn do
    var voltage = node.voltage + node.charge / node.node_cap
    voltage = voltage * (1.0 - node.leakage)
    node.voltage = voltage
    node.charge = 0.0
  end
end

task toplevel()
  var conf : CktConfig
  conf:initialize_from_command()
  conf:show()

  var num_circuit_nodes = conf.num_pieces * conf.nodes_per_piece
  var num_circuit_wires = conf.num_pieces * conf.wires_per_piece

  var rn = region(ispace(ptr, num_circuit_nodes), Node)
  var rw = region(ispace(ptr, num_circuit_wires), Wire(wild))

  new(ptr(Node, rn), num_circuit_nodes)
  new(ptr(Wire(wild), rw), num_circuit_wires)

  c.printf("Generating a random circuit...\n")
  helper.generate_random_circuit(rn, rw, conf)

  var colors = ispace(int1d, conf.num_pieces)
  var pn_equal = partition(equal, rn, colors)
  var pw_outgoing = preimage(rw, pn_equal, rw.in_node)
  var pw_incoming = preimage(rw, pn_equal, rw.out_node)
  var pw_crossing_out = pw_outgoing - pw_incoming
  var pw_crossing_in = pw_incoming - pw_outgoing
  var pw_crossing = pw_crossing_out | pw_crossing_in
  var pn_shared = pn_equal & (image(rn, pw_crossing, rw.in_node) | image(rn, pw_crossing, rw.out_node))
  var pn_private = pn_equal - pn_shared
  var pn_ghost = (image(rn, pw_crossing_out, rw.out_node) | image(rn, pw_crossing_in, rw.in_node)) - pn_shared

  var pw = pw_outgoing

  helper.dump_graph(conf, rn, rw)

  c.printf("Starting main simulation loop\n")
  var ts_start = helper.timestamp()

  for j = 0, conf.num_loops do
    -- TODO: Change each of these calls to work on a piece of the
    -- graph.
    calculate_new_currents(conf.steps, rn, rw)
    distribute_charge(rn, rw)
    update_voltages(rn)
  end

  -- Wait for all previous tasks to complete and measure the elapsed time.
  helper.wait_for(rn, rw)
  var ts_end = helper.timestamp()
  c.printf("simulation complete\n")

  var sim_time = 1e-6 * (ts_end - ts_start)
  c.printf("ELAPSED TIME = %7.3f s\n", sim_time)
  var gflops =
    helper.calculate_gflops(sim_time, WS * 6 + (WS - 1) * 4, 4, 4, conf)
  c.printf("GFLOPS = %7.3f GFLOPS\n", gflops)

  c.printf("Validating simulation results...\n")
  validator.validate_solution(rn, rw, conf)
end
regentlib.start(toplevel)
