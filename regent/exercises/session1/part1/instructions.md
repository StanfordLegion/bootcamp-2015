# Session 1 Part 1

In these exercises, we're going to walk through the creation of a simple Regent application: a circuit simulation on an unstructured graph. We'll describe the differential equations we're solving in the next part of the exercise. First, let's look at the data structures we're going to be using in our simulation.

In Regent, data structures are stored in *regions*. Regions are like arrays in other languages: they contain elements indexed by keys, and each element stores a set of fields. We call the set of keys the *index space* and the set of fields the *field space*. A region is just the cross product of these two spaces.

Regent has two kinds of index spaces: *structured* and *unstructured*. We'll be using mostly unstructured index spaces in these exercises. Unstructured index spaces are initially empty; the elements inside must be allocated explicitly (either individually or in bulk).

This stage of the exercise has four goals:

 1. Create field spaces for nodes and wires with the appropriate fields.
 2. Create unstructured index spaces for the nodes and wires.
 3. Create regions for nodes and wires from field and index spaces above.
 4. Allocate all the nodes and wires for the graph.

## Syntax Guide

Along with each section, we'll include a syntax guide to help teach you the syntax required in each part. The following snippets will help you get started with creating regions.
