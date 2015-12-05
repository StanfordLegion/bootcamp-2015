task T(ARG1 : T1, ...) end -- Creates a task named T, with parameters ARG1 (of type T1), etc.
task T(ARG1 : T1, ...) where reads(T1) do end -- As above, but declares read-only privilege on T1
task T(ARG1 : T1, ...) where reads writes(T1) do end -- As the first, but declares read-write privilege on T1
for V in R do ... end -- Creates a loop that enumerates elements in region R and bind them to pointer V
