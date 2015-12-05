var V = E -- Creates a variable named V, with initial value E.
ispace(ptr, N) -- Creates an empty index space with room for N pointers.
fspace { F1: T1, ... } -- Creates a field space with fields F1 (of type T1), etc.
region(IS, FS) -- Creates a region with index space IS and field space FS.
new(ptr(T, R)) -- Allocates a pointer in R. Points to a value of type T.
new(ptr(T, R), N) -- As above, but allocates a block of N pointers.
