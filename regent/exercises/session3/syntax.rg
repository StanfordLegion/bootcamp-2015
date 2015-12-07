__demand(__cuda) task T(...) ... -- Generates both x86 and CUDA variants for task T
bishop ... end                   -- Starts a bishop mapper
TE    { P : V; }                 -- Sets value V to property P of a task that matches with TE
TE RE { P : V; }                 -- Sets value V to property P of a region that matches RE and whose task matches TE
-- Task Element (TE)
task                             -- Matches with any task
task#T                           -- Matches with task T
task[P=$V]                       -- Matches with any task and binds the value of property P to variable $V
task#T[P=$V]                     -- As above, but only matches with task T
-- Region Element (RE)
region                           -- Matches with any region
region#P                         -- Matches with region passed by parameter P
-- Processor objects
processors                       -- A list of processors in the whole system
processors[isa=I]                -- Processors that supports ISA I
processors[N]                    -- N-th processor in the list
processors.size                  -- Size of the memory list
processors[N].memories           -- A list of memories visible to the N-th processor
-- Memory objects
memories                         -- A list of memories in the whole system
memories[kind=K]                 -- memorys of kind K (sysmem, regmem, fbmem, zcmem, ...)
memories[N]                      -- N-th memory in the list
memories.size                    -- Size of the memory list
