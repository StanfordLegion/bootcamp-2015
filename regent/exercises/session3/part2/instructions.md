# Session 3 Part 2

In the previous part, you might have seen some (but small) performance differences between different mapping decisions. Those differences of course will become more pronounced once the problem size you run your program gets bigger. The goal of this exercise is to explore different mapping choices and figure out which mappings perform the best and why.

We give you in this part of the exercise a bit bigger problem with 320K nodes and 1.3M wires in 128 circuit pieces. The number of time steps for each iteration has also changed from 10K steps to 100K steps. With this setting, your task of this exercise is:

- Find the best combination of mappings of tasks you can find.

As a starting point, we are giving you mapping rules that map the three simulation tasks to CPUs and map their regions to the system memory. For your information, the system you are going to use has four nodes each of which has 16 CPUs and 4 GPUs. We allocated each of them a big enough memory of each kind (system, RDMA, GPU framebuffer, and GPU zero-copy memory), feel free to map your regions on different memories as you wish.

The syntax guide from the preivous part will be useful, so we give it below as well.

## Syntax Guide
