# Session 2 Part 2

Now we need to change the simulation tasks to use the partitions we've created. There are two steps to this process:

First, the field space declarations will need to change to accomodate the new partitions. Remember that the nodes have been partitioned three ways: into private, shared, and ghost subregions (example reproduced below). This means that a task which wants to operate for example on the red nodes will need three regions (private, shared, and ghost). This also means that any fspace which points to nodes must be updated to take three arguments as well.

<table style="border: 0px;">
<tr style="border: 0px;">
<td style="border: 0px; padding: 10px;">
Private (Partition of Nodes)
<img src="//regent-lang.org/images/circuit/partition5_private.png" width="250">
</td>
<td style="border: 0px; padding: 10px;">
Shared (Partition of Nodes)
<img src="//regent-lang.org/images/circuit/partition6_shared.png" width="250">
</td>
<td style="border: 0px; padding: 10px;">
Ghost (Partition of Nodes)
<img src="//regent-lang.org/images/circuit/partition7_ghost.png" width="250">
</td>
</tr>
</table>

After this is done, the rest is straightforward: change each task call in the main simulation loop to operate over subregions of the partitions. (Hint: Use a for loop.)

## Syntax Guide
