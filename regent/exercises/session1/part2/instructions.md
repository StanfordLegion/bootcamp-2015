# Session 1 Part 2

Let's implement the rest of the circuit simulation. Your task is to implement two of the three simulation tasks (we already gave you the last one for reference).

## Implement task `calculate_new_currents`

This task updates currents and voltages of wire segments. Each wire consists of three segments and can be drawn like this:

             `current.\_1`                  `current.\_2`                  `current.\_3`
`in\_node` ---------------- `voltage.\_1` ---------------- `voltage.\_2` ---------------- `out\_node`

On this topology of wire segments, the RLC model you are going to implement is described by the following equation:

    $I_i^s = ((V_i+1^s - V_i^s) - L * (I_i^s - I_i^0) / dT) / R$
    $V_i+1^s = V_i^0 + dT * (I_i^s - I_i+1^s) / C$

At each time step, the difference in voltages induces currents on each segment and the induced currents acculmulates to the voltage at each node. The task will repeatly compute new currents and voltages for `conf.steps` times, and once all steps are done, it should store the final currents and voltages back to the region of wires.

Implement the body of the task based on this description.

## Implement task `distribute_charge`

This task adjusts the charge of `in\_node` and `out\_node` of each wire. Since the currents have flown from `in\_node` to `out\_node`, charges have been taken from the former and delivered to the latter. The contribution of the currents to the charge is formulated as this:

    $dCharge = dT * I$

Implement the task body based on the given description.

## Complete the simulation loop

One iteration of the circuit simulation consists of three steps:

1. Calcualte currents (`calculate_new_currents`)
2. Distribute charges (`distribute_charge`)
3. Update voltages (`update_voltages`)

The main task will invoke them in the above order for `conf.num_loops` times.

Fill the for-loop given in the main task.

## Bonus Point: Calculate FLOPS of your implementation.

We are giving you a helper function `helper.calculate_gflops` which takes the execution time and the flops per iteration of each of the three tasks, and computes the total FLOPS of the simulation.

Analyze your task implementations and calculate the total GFLOPS.

## Syntax Guide

Like in the previous part, we include a syntax guide to teach you the syntax required in this part. The following snippets will help you define tasks and enumerates elements in regions.
