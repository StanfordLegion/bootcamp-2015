# Session 1 Part 2

Let's implement the rest of the circuit simulation. Your task is to implement two of the three simulation tasks (we already gave you the last one for reference).

## Implement task `calculate_new_currents`

This task updates currents and voltages of wire segments. Each wire consists of three segments and can be drawn like this:

$\hskip{8em}I_0\hskip{11.5em}I_1\hskip{11em}I_2$

               current._0                 current._1                current._2
                   
    in_node --------------- voltage._1 -------------- voltage._2 ------------- out_node

$\hskip{2.5em}V_0\hskip{10em}V_1\hskip{11em}V_2\hskip{10em}V_3$

On this topology of wire segments, the RLC model you are going to implement is described by the following equation:

$\large I_i^s = \big((V_{i+1}^s - V_i^s) - L \frac{I_i^s - I_i^0}{dT}\big)/R\quad \textrm{for}\quad 0 \le i \le 3$

$\large V_{i+1}^s = V_i^0 + \frac{I_i^s - I_{i+1}^s}{C}dT \quad \textrm{for}\quad 0 \le i \le 2$


At each time step $s$, the difference in voltages induces currents on each segment and the induced currents acculmulates to the voltage at each node. The task will repeatly compute new currents and voltages for `conf.steps` times, and once all steps are done, it should store the final currents and voltages back to the region of wires.

Implement the body of the task based on this description.

## Implement task `distribute_charge`

This task adjusts the charge of `in_node` and `out_node` of each wire. Since the currents have flown from `in_node` to `out_node`, charges have been taken from the former and delivered to the latter. The contribution of the currents to the charge is formulated as this:

$\large \mathit{dCharge} = \mathit{I} \times \mathit{dT}$

Implement the task body based on the given description.

## Complete the simulation loop

One iteration of the circuit simulation consists of three steps:

1. Calcualte currents (`calculate_new_currents`)
2. Distribute charges (`distribute_charge`)
3. Update voltages (`update_voltages`)

The main task will invoke them in the above order for `conf.num_loops` times.

Fill the for-loop given in the main task.

## Bonus: Calculate FLOPS of your implementation.

We are giving you a helper function `helper.calculate_gflops` which takes the execution time and the flops per iteration of each of the three tasks, and computes the total FLOPS of the simulation.

Analyze your task implementations and calculate the total GFLOPS.

## Syntax Guide
