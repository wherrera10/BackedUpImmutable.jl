module BackedUpImmutable

import Base.getindex, Base.setindex!, Base.get!, Base.get, Base.empty!, Base.pop!
import Base.haskey, Base.delete!, Base.iterate, Base.length

export StaticDict, BackedUpImmutableDict, restore!, restoreall!


""" Another name for ImmutableDict, but here as with an extra constructor. """
StaticDict = Base.ImmutableDict

""" Constructor for StaticDict / ImmutableDict to take an array of key value pairs. """
function Base.ImmutableDict(pairs::Vector{Pair{K,V}}) where V where K
    id = Base.ImmutableDict(pairs[1][1] => pairs[1][2])
    for p in pairs[2:end]
        id = StaticDict(id, p[1] => p[2])
    end
    id
end

""" Constructor for StaticDict to take a series of pairs, varargs style """
function Base.ImmutableDict(pairs...)
    pairvect = [pairs...]
    id = Base.ImmutableDict(pairvect[1][1] => pairvect[1][2])
    for p in pairvect[2:end]
        id = StaticDict(id, p[1] => p[2])
    end
    id
end

"""
    # BackedUpImmutableDict{K, V} 
    * Combines a key, not value, immutable hash dictionary with a backup of the original value defaults.
    * For configuration data storage, with a simple restore to default
"""
mutable struct BackedUpImmutableDict{K, V} <: AbstractDict{K,V}
    d::StaticDict
    defaults::Dict{K, V}
end

"""
    Makes a BackedUpImmutableDict from a vector of key, value pairs
"""
BackedUpImmutableDict{K,V}(pairs::Vector{Pair{K,V}}) where V where K =
    BackedUpImmutableDict(StaticDict(pairs), Dict{K,V}(pairs...))

"""
    Makes a BackedUpImmutableDict from a tuple of key, value pairs (varargs style)
"""
BackedUpImmutableDict{K,V}(pairs...) where V where K = BackedUpImmutableDict{K,V}([pairs...])

Base.haskey(dic::BackedUpImmutableDict, k) = haskey(dic.d[k])
Base.getindex(dic::BackedUpImmutableDict, k) = getindex(dic.d, k)
Base.get(dic::BackedUpImmutableDict) = get(dic.d, k)
Base.delete!(dic::BackedUpImmutableDict, k) = throw("Cannot delete from an ImmutableDict")
Base.empty!(dic::BackedUpImmutableDict) = throw("Cannot empty! an ImmutableDict")
Base.pop!(dic::BackedUpImmutableDict) = throw("Cannot pop! from an ImmutableDict")
Base.length(dic::BackedUpImmutableDict) = length(dic.d)
Base.iterate(dic::BackedUpImmutableDict) = iterate(dic.d)
Base.iterate(dic::BackedUpImmutableDict, s) = iterate(dic.d, s)

function Base.setindex!(dic::BackedUpImmutableDict, v, k)
    if haskey(dic.d, k)
        id = Base.ImmutableDict(dic.d, k => v)
        dic.d = id
    else
        throw("Cannot add key $k to ImmutableDict")
    end
end

function Base.get!(dic::BackedUpImmutableDict, k, v)
    if haskey(dic.d, k)
        return get(dic.c, k)
    else
        throw("Cannot add key $k to ImmutableDict")
    end
end


"""
   # Restore a key's backed up default value.
"""
function restore!(dic, k)
    if haskey(dic.defaults, k)
        dic[k] = (v = dic.defaults[k])
        return v
    end
end

"""
   # Restore all values back to defaults
"""
function restoreall!(dic)
    dic.d = StaticDict(collect(dic.defaults))
end


end # module
