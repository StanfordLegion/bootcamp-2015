task T(A1 : T1, ...) ... end -- Creates a task T with parameters A1 (of type T1), etc.
task T(A1 : T1, ...) where reads(A1) do ... end -- As above, but with read-only privileges on A1.
task T(A1 : T1, ...) where reads writes(A1) do ... end -- As above, but with read-write privileges on A1.
for V in R do ... end -- Loops over each element V in R. (V is a pointer to each element.)
