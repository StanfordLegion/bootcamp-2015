# Session 1 Part 2

Let's implement the rest of the circuit simulation. The simulation will solve some differential equations (described below) with a simple timestep loop. Each loop iteration will have three steps:

 1. `calculate_new_currents`
 2. `distribute_charge`
 3. `update_voltages` (provided for your reference)

Your goal for this exercise is to implement the two remaining tasks and finish the simulation loop.

## Task `calculate_new_currents`

This task updates currents and voltages of wire segments. Each wire consists of three segments and can be drawn like this:

$\hskip{8em}I_0\hskip{11.5em}I_1\hskip{11em}I_2$

               current._0                 current._1                current._2
                   
    in_node --------------- voltage._1 -------------- voltage._2 ------------- out_node

$\hskip{2.5em}V_0\hskip{10em}V_1\hskip{11em}V_2\hskip{10em}V_3$

On this topology of wire segments, the RLC model you are going to implement is described by the following equation:

$\large I_i^s = \big((V_{i+1}^{s-1} - V_i^{s-1}) - L \frac{I_i^{s-1} - I_i^0}{dT}\big)/R\quad \textrm{for}\quad 0 \le i < 3$

$\large V_{i+1}^s = V_i^0 + \frac{I_i^s - I_{i+1}^s}{C}dT \quad \textrm{for}\quad 0 \le i < 2$


At each time step $s$, the difference in voltages induces currents on each segment and the induced current accumulates to the voltage at each node. The task repeatedly computes new currents and voltages for `conf.steps` times, and once all steps are done, it should store the final currents and voltages back to the region of wires.

Implement the body of the task based on this description.

## Task `distribute_charge`

This task adjusts the charge of `in_node` and `out_node` of each wire. Since the currents flowed from `in_node` to `out_node`, charges have been taken from the former and delivered to the latter. The contribution of the currents to the charge is formulated as:

$\large \mathit{dCharge} = \mathit{I} \times \mathit{dT}$

Implement the task body based on this description.

## Complete the Simulation Loop

The body of circuit simulation is a timestep loop with three steps (in the following order):

 1. `calculate_new_currents`
 2. `distribute_charge`
 3. `update_voltages`

The loop will run for `conf.num_loops` timesteps. Finish the loop and run the application to make sure everything is working correctly.

## Bonus: Calculate the FLOPS of Your Implementation

Optionally, you can calculate the FLOPS used by your implementation. We've provided code that measures the time elapsed during the simulation. The helper function `helper.calculate_gflops` takes this time and the FLOPs per iteration of each of the three tasks (which you must provide), and computes the total FLOPS of the simulation.

Analyze your task implementations and calculate the total FLOPS.

## Syntax Guide
