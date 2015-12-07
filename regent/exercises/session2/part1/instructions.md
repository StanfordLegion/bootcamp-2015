# Session 2 Part 1

So far, our circuit simulation has been running sequentially. In this session, we'll work on parallelizing the code. This will require us to do two things. First, we must describe how regions are *partitioned* (decomposed into pieces), so that Regent can determine what portions of the computation may run in parallel. Second, we'll need to update the tasks to use these newly partitioned regions.

Let's start with partitioning.

Partitioning is critical in Regent for two reasons. First, partitioning determines what data parallelism is available in the application (if any). Second, partitioning limits the amount of data movement required to perform a computation. Therefore, it will be important to think carefully about the access patterns (read and write sets) of each task in order to construct a good partitioning.

Generally speaking, we'll start by creating an initial *independent* partition of the data (i.e. a partition which does not depend on other partitions). We can make this partition intelligent by, for example, running METIS and partitioning based on the result. But for this exercise, we'll assume that a simple *equal* partition will suffice. An example of such a partition might look like this:

<table style="border: 0px;">
<tr style="border: 0px;">
<td style="border: 0px; padding: 10px;">
Equal Partition of Nodes
<img src="/images/circuit/partition1_equal.png" width="250">
</td>
</tr>
</table>

Now, if the application required no communication between tasks, this might be the only partition we would need. However, the circuit simulation requires communication: updates to nodes in the graph generally require access to the values stored on adjacent nodes. Conceptually, we could solve this by taking the partition above and bloating it by one node in each direction. But this could be really inefficient, because it would require the runtime to move much more data than actually required for the computation. Critically, the only data that *must* move is data for nodes connected to nodes of a different color.

This requires the use of *dependent* partitions (i.e. partitions computed from other partitions). With the *preimage* operator, we can obtain a partition of edges where each edge has the color of its `in_node` field (shown on the left, below). Then we can use the *image* operator to follow the `out_node` field back to nodes (shown in the center, below). Note in particular that nodes marked with multiple colors are exactly the nodes which will be involved in communication. With a little more work, we can obtain a partition of crossing nodes (shown on the right, below).

<table style="border: 0px;">
<tr style="border: 0px;">
<td style="border: 0px; padding: 10px;">
Preimage (Partition of Wires)
<img src="/images/circuit/partition2_wires.png" width="250">
</td>
<td style="border: 0px; padding: 10px;">
Image (Partition of Nodes)
<img src="/images/circuit/partition3_image.png" width="250">
</td>
<td style="border: 0px; padding: 10px;">
Crossing (Partition of Nodes)
<img src="/images/circuit/partition4_crossing.png" width="250">
</td>
</tr>
</table>

With this in mind, we can now compute three new partitions (which will actually be used directly in the application):

<table style="border: 0px;">
<tr style="border: 0px;">
<td style="border: 0px; padding: 10px;">
Private (Partition of Nodes)
<img src="/images/circuit/partition5_private.png" width="250">
</td>
<td style="border: 0px; padding: 10px;">
Shared (Partition of Nodes)
<img src="/images/circuit/partition6_shared.png" width="250">
</td>
<td style="border: 0px; padding: 10px;">
Ghost (Partition of Nodes)
<img src="/images/circuit/partition7_ghost.png" width="250">
</td>
</tr>
</table>

When take all nodes of a color (e.g. red) together, you'll see that they correspond to the bloated set of nodes required for task (as we noted above). However (and this is important for performance) only the shared and ghost partitions must be communicated. The private partition is non-overlapping with the other two, and thus it can safely stay put for the duration of the simulation.

Your goal is to construct the four partitions above (private, shared and ghost nodes, and wires). You may find it helpful to construct several intermediate partitions, such as the image, preimage, and crossing partition above. (Note that there are multiple valid solutions; your intermediate partitions might look different from those above.) We have given you an initial equal partition of the nodes to help you get started.

## Syntax Guide
