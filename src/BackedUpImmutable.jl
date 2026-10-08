module BackedUpImmutable

export StaticDict, BackedUpImmutableDict, restore!, restoreall!, ImmutableDictError

"""
    ImmutableDictError(msg)

Thrown when an operation would require adding or removing a key from the
fixed key set of a `StaticDict` / `BackedUpImmutableDict`.
"""
struct ImmutableDictError <: Exception
    msg::String
end

Base.showerror(io::IO, e::ImmutableDictError) = print(io, e.msg)

""" Another name for ImmutableDict, but here as with an extra constructor. """
const StaticDict = Base.ImmutableDict

""" Constructor for StaticDict / ImmutableDict to take an array of key value pairs. """
function Base.ImmutableDict(pairs::Vector{Pair{K,V}}) where V where K
    isempty(pairs) && throw(ArgumentError("cannot construct a StaticDict from an empty collection of pairs"))
    id = Base.ImmutableDict(pairs[1][1] => pairs[1][2])
    for p in pairs[2:end]
        id = StaticDict(id, p[1] => p[2])
    end
    id
end

""" Constructor for StaticDict to take a series of pairs, varargs style """
function Base.ImmutableDict(pairs::Pair...)
    isempty(pairs) && throw(ArgumentError("cannot construct a StaticDict from an empty collection of pairs"))
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
    d::StaticDict{K, V}
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

Base.haskey(dic::BackedUpImmutableDict, k) = haskey(dic.d, k)
Base.getindex(dic::BackedUpImmutableDict, k) = getindex(dic.d, k)
Base.get(dic::BackedUpImmutableDict, k, default) = get(dic.d, k, default)
Base.get(dic::BackedUpImmutableDict, k) = get(dic.d, k)
Base.delete!(dic::BackedUpImmutableDict, k) = throw(ImmutableDictError("Cannot delete from an ImmutableDict"))
Base.empty!(dic::BackedUpImmutableDict) = throw(ImmutableDictError("Cannot empty! an ImmutableDict"))
Base.pop!(dic::BackedUpImmutableDict) = throw(ImmutableDictError("Cannot pop! from an ImmutableDict"))
Base.length(dic::BackedUpImmutableDict) = length(dic.d)
Base.iterate(dic::BackedUpImmutableDict) = iterate(dic.d)
Base.iterate(dic::BackedUpImmutableDict, s) = iterate(dic.d, s)

function Base.setindex!(dic::BackedUpImmutableDict, v, k)
    if haskey(dic.d, k)
        id = Base.ImmutableDict(dic.d, k => v)
        dic.d = id
    else
        throw(ImmutableDictError("Cannot add key $k to ImmutableDict"))
    end
end

function Base.get!(dic::BackedUpImmutableDict, k, default)
    if haskey(dic.d, k)
        return getindex(dic.d, k)
    else
        throw(ImmutableDictError("Cannot add key $k to ImmutableDict with default $default"))
    end
end

"""
    Restore a key's backed up default value.
"""
function restore!(dic, k)
    if !haskey(dic.defaults, k)
        throw(ImmutableDictError("Cannot restore key $k: no default value is stored for it"))
    end
    v = dic.defaults[k]
    dic[k] = v
    return v
end

"""
    Restore all values back to defaults
"""
function restoreall!(dic)
    dic.d = StaticDict(collect(dic.defaults))
end


end # module
