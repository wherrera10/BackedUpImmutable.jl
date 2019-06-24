module BackedUpImmutable

export BackedUpImmutableDict, getindex, setindex!, get!, get, restore!

mutable struct BackedUpImmutableDict{K, V} <: AbstractDict{K,V}
    d::Base.ImmutableDict
    defaults::Dict{K, V}
end

function BackedUpImmutableDict{K,V}(pairs::Vector{Pair{K,V}}) where V where K
    id = Base.ImmutableDict(pairs[1][1] => pairs[1][2])
    for p in pairs[2:end]
        id = Base.ImmutableDict(id, p[1] => p[2])
    end
    BackedUpImmutableDict(id, Dict{K,V}(pairs...))
end

getindex(dic::BackedUpImmutableDict, k) = dic.d[k]

Base.setindex!(dic::BackedUpImmutableDict{K,V}, v::V, k::K...) where V where K = setindex!(dic.d, v,  k...)

function Base.setindex!(dic::BackedUpImmutableDict{K,V}, v::V, k::K) where V where K
    if haskey(dic.d, k)
        id = Base.ImmutableDict(dic.d, k => v)
        dic.d = id
    else
        throw("Cannot add key $k to ImmutableDict")
    end
end

Base.get(dic::BackedUpImmutableDict, k, v) = get(dic.d, k, v)
Base.get!(dic::BackedUpImmutableDict, k::K, v::V) where V where K = get!(dic.d, k, v)

function restore!(dic, k)
    if haskey(dic.defaults, k)
        dic[k] = (v = dic.defaults[k])
        return v
    end
end

end # module
