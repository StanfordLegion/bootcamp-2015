partition(equal, R, ispace(int1d, N)) -- Divide R into N roughly even pieces.
partition(R.F, ispace(int1d, N)) -- Partition R according to the field R.F.
image(R, P, R2.F) -- Image over P via the field R2.F. Result is a partition of R.
preimage(R, P2, R2.F) -- Preimage of P via the field R2.F. Result is a partition of R.
P1 & P2 -- Intersection of partitions P1 and P2.
P1 | P2 -- Union of partitions P1 and P2.
P1 - P2 -- Difference of partitions P1 and P2.