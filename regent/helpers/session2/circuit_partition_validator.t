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
local cstring = terralib.includec("string.h")

local CktConfig = require("session1/circuit_config")

local validator = {}

task validator.validate_partitions(conf       : CktConfig,
                                   rn         : region(Node),
                                   rw         : region(Wire(rn)),
                                   pn_private : partition(disjoint, rn),
                                   pn_shared  : partition(disjoint, rn),
                                   pn_ghost   : partition(aliased,  rn),
                                   pw         : partition(disjoint, rw))
where reads(rn, rw)
do
  var np = conf.num_pieces
  var npp = conf.nodes_per_piece
  var wpp = conf.wires_per_piece
  var num_nodes = np * npp
  var num_wires = np * wpp
  var num_crossings : &int = [&int](c.malloc([sizeof(int)] * num_nodes))
  cstring.memset(num_crossings, 0, num_nodes * [sizeof(int)])

  -- first calcaultes the ground truth
  for w in rw do
    var in_node  = __raw(w.in_node).value
    var out_node = __raw(w.out_node).value

    if in_node / npp ~= out_node / npp then
      num_crossings[in_node] += 1
      num_crossings[out_node] += 1
    end
  end

  var valid = true
  for p = 0, conf.num_pieces do
    var rprivate = pn_private[p]
    var rshared  = pn_shared[p]
    var rghost   = pn_ghost[p]
    var rwprivate = pw[p]

    var start_node_id = npp * p
    var end_node_id   = npp * (p + 1) - 1
    var start_wire_id = wpp * p
    var end_wire_id   = wpp * (p + 1) - 1

    c.printf("piece %d:\n", p)
    for n in rprivate do
      var node = __raw(n).value
      var check = "O"
      if not (start_node_id <= node and node <= end_node_id and
              num_crossings[node] == 0)
      then
        check = "X"
        valid = false
      end
      c.printf("  private node %d (%s)\n", __raw(n), check)
    end
    for n in rshared do
      var node = __raw(n).value
      var check = "O"
      if not (start_node_id <= node and node <= end_node_id and
              num_crossings[node] > 0)
      then
        check = "X"
        valid = false
      end
      c.printf("  shared node %d (%s)\n", __raw(n), check)
    end
    for n in rghost do
      var node = __raw(n).value
      var check = "X"
      var valid_ghost = false

      for wire = 0, num_wires do
        var w = dynamic_cast(ptr(Wire(rn), rw), [ptr](wire))
        var in_node  = __raw(w.in_node).value
        var out_node  = __raw(w.out_node).value
        if (in_node == node and num_crossings[out_node] > 0) or
           (out_node == node and num_crossings[in_node] > 0)
        then
          check = "O"
          valid_ghost = true
          break
        end
      end
      valid = valid and valid_ghost

      c.printf("  ghost node %d (%s)\n", node, check)
    end

    for w in rwprivate do
      var wire = __raw(w).value
      var check = "O"
      if not (start_wire_id <= wire and wire <= end_wire_id) then
        check = "X"
        valid = false
      end

      var in_node  = __raw(w.in_node).value
      var out_node  = __raw(w.out_node).value

      if not (start_node_id <= in_node and in_node <= end_node_id) then
        check = "X"
        valid = false
      end
      if not (0 <= out_node and out_node < num_nodes) then
        check = "X"
        valid = false
      end

      c.printf("  edge %d: %d -- %d (%s)\n",
        __raw(w), in_node, out_node, check)
    end
  end
  regentlib.assert(valid, "Some of partitions are invalid")
  c.printf("Your partitions pass the validation! Proceed to the next part.\n")
  c.free(num_crossings)
end

return validator
