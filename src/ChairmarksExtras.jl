module ChairmarksExtras

using Reexport
@reexport using Chairmarks

export @belapsed, @ballocated, @ballocations, @btime, @btimed

macro belapsed(args...)
    :(@b($(args...)).time)
end
macro ballocated(args...)
    :(Int(@b($(args...)).bytes))
end
macro ballocations(args...)
    :(Int(@b($(args...)).allocs))
end

function save_result(expr)
    result = gensym("result")
    args = expr.args[1].args
    length(args) == 2 && return expr
    length(args) == 3 && insert!(args, 3, nothing)
    while length(args) < 5; push!(args, nothing) end
    i = lastindex(args)
    if args[i] === nothing
        args[i] = :(Base.Fix1(setindex!, $result))
    elseif args[i] isa Expr && args[i].head == :->
        args[i].args[2] = :($result[] = $(args[i].args[2]))
    else
        x = gensym()
        args[i] = :($x -> $result[] = $(args[i])($x))
    end
    quote
        $(esc(result)) = Ref{Any}()
        Chairmarks.summarize($expr), $(esc(result))[]

    end
end

macro btimed(args...)
    quote
        perf,value = $(save_result(Chairmarks.process_args(args)))
        (
            value=value,
            time=perf.time,
            bytes=perf.bytes,
            gctime=perf.gc_fraction*perf.time,
            allocations=perf.allocs,
            compile_time=perf.compile_fraction*perf.time,
            recompile_time=perf.time*perf.compile_fraction*perf.recompile_fraction,
        )
    end
end
macro btime(args...)
    quote
        perf,value = $(save_result(Chairmarks.process_args(args)))
        print("  ")
        show(stdout, MIME"text/plain"(), perf)
        println()
        value
    end
end

end
