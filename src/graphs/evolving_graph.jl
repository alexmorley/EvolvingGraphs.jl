
####################################################
#
# EvolvingGraph type
#
#####################################################

type EvolvingGraph{V,T} <: AbstractEvolvingGraph{V, TimeEdge, T}
    is_directed::Bool
    ilist::Vector{V}
    jlist::Vector{V}
    timestamps::Vector{T} 
end

typealias IntEvolvingGraph EvolvingGraph{Int, Int}

function evolving_graph{V,T}(ils::Vector{V}, 
                             jls::Vector{V}, 
                             timestamps::Vector{T}; 
                             is_directed::Bool=true)
    length(ils) == length(jls) == length(timestamps)|| 
            error("3 input vectors must have the same length.")
    return EvolvingGraph{V,T}(is_directed, ils, jls, timestamps)    
end


is_directed(g::EvolvingGraph) = g.is_directed

function timestamps(g::EvolvingGraph)
    ts = unique(g.timestamps)
    if eltype(ts) <: Real
        ts = sort(ts)
    end
    return ts
end

num_timestamps(g::EvolvingGraph) = length(timestamps(g))

nodes(g::EvolvingGraph) = union(g.ilist, g.jlist)
num_nodes(g::EvolvingGraph) = length(nodes(g))


function edges(g::EvolvingGraph)
    n = length(g.ilist)

    edgelists = TimeEdge[]

    if g.is_directed
       for i = 1:n
           e = TimeEdge(g.ilist[i], g.jlist[i], g.timestamps[i])
           push!(edgelists, e)
       end
    else
        for i = 1:n
            e1 = TimeEdge(g.ilist[i], g.jlist[i], g.timestamps[i])
            e2 = TimeEdge(g.jlist[i], g.ilist[i], g.timestamps[i])
            push!(edgelists, e1)
            push!(edgelists, e2)
        end
    end
    return edgelists
end

# edge of an evolving graph at a given time
function edges{T}(g::EvolvingGraph, t::T)
    t in g.timestamps || error("unknown time stamp $(t)")

    n = length(g.ilist)
    
    edgelists = TimeEdge[]
  
    if g.is_directed
        for i = 1:n
            if t == g.timestamps[i]
                e = TimeEdge(g.ilist[i], g.jlist[i], g.timestamps[i])
                push!(edgelists, e)
            end
        end
    else
        for i = 1:n
            if t == g.timestamps[i]
                e1 = TimeEdge(g.ilist[i], g.jlist[i], g.timestamps[i])
                e2 = TimeEdge(g.jlist[i], g.ilist[i], g.timestamps[i])
                push!(edgelists, e1)
                push!(edgelists, e2)
            end
        end
    end
          
    return edgelists
end

num_edges(g::EvolvingGraph) = g.is_directed ? length(g.ilist) : length(g.ilist)*2

# reduce the number of timestamps by emerging the graph with less
# than n edges to a neighbour graph
function reduce_timestamps!(g::EvolvingGraph, n::Int = 2)
    times = timestamps(g)    
    
    for (i,t) in enumerate(times)
        v = find(x -> x == t, g.timestamps)
        if length(v) >= n
            continue
        end
        try 
            [g.timestamps[j] = times[i+1] for j in v] 
        catch BoundsError
        end
    end
    g
end 

# add a TimeGraph to an EvolvingGraph
function add_graph!(g::EvolvingGraph, tg::TimeGraph)

end

# merge two EvolvingGraph type objects
function merge!(g1::EvolvingGraph, g2::EvolvingGraph)

end

####################################################
#
# Weighted EvolvingGraph type
#
#####################################################

type WeightedEvolvingGraph{V,W,T} <: AbstractEvolvingGraph{V, TimeEdge, T}
    is_directed::Bool
    ilist::Vector{V}
    jlist::Vector{V}
    weights::Vector{W}
    timestamps::Vector{T} 
end