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

local validator = {}

local CktConfig = require("session1/circuit_config")
local helper = require("session1/circuit_helper")
local cmath = terralib.includec("math.h")

task validator.validate_solution(rn : region(Node),
                                 rw : region(Wire(rn)),
                                 conf : CktConfig)
where reads writes(rn, rw)
do
  if conf.num_loops ~= 5 or conf.num_pieces ~= 4 or
     conf.nodes_per_piece ~= 4 or conf.wires_per_piece ~= 8 or
     conf.pct_wire_in_piece ~= 80 or conf.random_seed ~= 12345 or
     conf.steps ~= 10000
  then
    c.printf("unknown circuit configuration. skipping validation...\n")
    return
  end

  var num_nodes = conf.num_pieces * conf.nodes_per_piece
  var num_wires = conf.num_pieces * conf.wires_per_piece

  --helper.dump_solution("result_n5_p5_npp4_wpp8_pct80_s12345_s10000.dat",
  --                     __runtime(), __context(),
  --                     __physical(rn), __fields(rn),
  --                     __physical(rw), __fields(rw))

  var node_charge = [&float](c.malloc([sizeof(float)] * num_nodes))
  var node_voltage = [&float](c.malloc([sizeof(float)] * num_nodes))
  var wire_currents = [&float](c.malloc([sizeof(float)] * num_wires * 3))
  var wire_voltages = [&float](c.malloc([sizeof(float)] * num_wires * 2))
  var filename = "session1/result_n5_p5_npp4_wpp8_pct80_s12345_s10000.dat"
  helper.read_solution(filename,
                       node_charge, node_voltage,
                       wire_currents, wire_voltages,
                       num_nodes, num_wires)
  var passed = true
  __forbid(__vectorize)
  for n in rn do
    var p = __raw(n).value
    if not (cmath.fabs(n.charge - node_charge[p]) < 1e-5) then
      c.printf("[node %d] computed charge: %.6f, expected charge: %.6f\n",
        p, n.charge, node_charge[p])
      passed = false
    elseif not (cmath.fabs(n.voltage - node_voltage[p]) < 1e-5) then
      c.printf("[node %d] computed voltage: %.6f, expected voltage: %.6f\n",
        p, n.voltage, node_voltage[p])
    end
  end
  for i = 0, 3 do
    var offset = num_wires * i
    __forbid(__vectorize)
    for w in rw do
      var current : float
      if i == 0 then current = w.current._0
      elseif i == 1 then current = w.current._1
      else current = w.current._2 end
      var p = __raw(w).value
      var diff = cmath.fabs(current - wire_currents[p + offset])
      if not (diff < 1e-5) then
        c.printf("[node %d] computed current%d: %.6f, expected current%d: %.6f\n",
          p, i, current, i, wire_currents[p + offset])
      end
    end
  end
  for i = 0, 2 do
    var offset = num_wires * i
    __forbid(__vectorize)
    for w in rw do
      var voltage : float
      if i == 0 then voltage = w.voltage._0
      else voltage = w.voltage._1 end
      var p = __raw(w).value
      var diff = cmath.fabs(voltage - wire_voltages[p + offset])
      if not (diff < 1e-5) then
        c.printf("[node %d] computed voltage%d: %.6f, expected voltage%d: %.6f\n",
          p, i, voltage, i, wire_voltages[p + offset])
      end
    end
  end
  regentlib.assert(passed, "validation failed!")
  c.printf("Validation passed!\n")
end

return validator
