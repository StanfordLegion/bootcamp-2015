__demand(__cuda) task T ... -- Generates both x86 and CUDA variants for task T
bishop ... end              -- Starts a bishop mapper
TE    { P : V; }            -- Sets value V to property P of a task that matches with TE
TE RE { P : V; }            -- Sets value V to property P of a region that matches RE and whose task matches TE

-- Task Element (TE)
task                        -- Selects any tasks
task#T                      -- Selects tasks named T
task[isa=I]                 -- Selects tasks mapped to a processor that supports ISA I
TE[target=$T]               -- Selects tasks that satisfy TE and then binds their target to $T
TE[index=$P]                -- Selects tasks that satisfy TE and then binds their point in the launch domain to $P

-- Region Element (RE)
region                      -- Selects any regions
region#P                    -- Selects regions named P in the signature

-- Processor objects
processors                  -- A list of processors in the whole system
processors[isa=I]           -- A list of processors that support ISA I (either x86 or cuda)
processors[N]               -- The N-th processor in the list
L.size                      -- The size of list L of processors
P.memories                  -- A list of memories visible to processor P

-- Memory objects
memories                    -- A list of memories in the whole system
memories[kind=K]            -- A list of memories of kind K (sysmem, regmem, fbmem, or zcmem)
memories[N]                 -- The N-th memory in the list
L.size                      -- The size of list L of memories

-- Expressions for list indices
$P                          -- Variable $P bound to a point
E1 + E2, E1 - E2, E1 * E2, E1 / E2, E1 % E2 -- Usual integer arithmetic expressions
