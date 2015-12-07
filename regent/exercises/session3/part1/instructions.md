# Session 3 Part 1

In this sesseion, you make the circuit simulation run on GPU. We are going to see that mapping decisions do not interfere with the correctness of the application (modulo mapping failures from incorrect mapping decisions).

The task for this exercise is to write some mapping rules to map the three simulation tasks you have written so far to GPUs. To write mapping rules, you are going to need a new embedded language called Bishop. In the syntax guide below, you can find how you can pick a set of tasks or regions to set a target for. We are giving you a mapping rule for the top-level task that maps that task to CPU (more precisely, a processor that supports x86 ISA). Based on the example and the syntax guide given below, you

- Write mapping rules that map `calculates_new_currents`, `distribute_charges`, and `update_voltages` to a processor that supports CUDA ISA.
- Write mapping rules that map regions for these tasks to a zero-copy memory that is visible to the processor the task has been mapped to.

With all your mapping rules, you should either get a mapping failure or see your solution passed the validation. Again, this is the decision choice that the Legion programming model emphasizes; mapping decisions do not (and should not) interfere with the correctness.

## Syntax Guide
