# Session 3 Part 1

In this sesseion, you make the circuit simulation run on GPUs. We are going to see that mapping decisions do not interfere with the correctness of the application (modulo mapping failures from incorrect mapping decisions).

The task of this exercise is to write some mapping rules to map the three simulation tasks to GPUs. To write mapping rules, you use a new mapper language called Bishop. In the syntax guide below, you can find how you can select a set of tasks (regions) and set their target to a particular processor (memory). We are giving you a mapping rule for task 'update_voltages' that maps the task to CPUs (more precisely, processors that supports x86 ISA). Based on this example and the syntax guide given below, you write

- Mapping rules that map tasks `calculate_new_currents`, `distribute_charges`, and `update_voltages` to GPUs (i.e. processors that support CUDA ISA)
- Mapping rule(s) that map regions of these tasks to a zero-copy memory that is visible to the processor that the tasks have been mapped to.
- As a bonus point, mapping rules that map task `distribute_charges` to even numbered GPUs and task `update_voltages` to odd numbered GPUs (you can assume that there are even number of GPUs).

With all your mapping rules written correctly, you should see the solution passes validation.

## Syntax Guide
