using Test
using BackedUpImmutable

@testset "StaticDict           " begin

    d = StaticDict(["a" => 7, "d" => 2])
    @test d["d"] == 2

    d2 = StaticDict("a" => 7, "d" => 2, "e" => 4)
    @test d2["e"] != 3
end

@testset "BackedUpImmutableDict" begin

    fibr = BackedUpImmutableDict{String,Int64}(["a" => 0, "b" => 1, "c" => 1, "d" => 2,
        "e" => 3, "f" => 5, "g" => 8, "h" => 13, "i" => 21, "j" => 34, "extra" => -1])

    x = fibr["extra"]
    @test x == -1

    fibr["extra"] = 0
    y = fibr["extra"]
    @test y == 0

    restore!(fibr, "extra")
    z = fibr["extra"]
    @test z == -1
    
    @test_throws ImmutableDictError begin fibr["k"] = 55 end
    
    # test alternative constructor
    fibr = BackedUpImmutableDict{String, Int64}("a" => 0, "b" => 1, "c" => 1, "d" => 2,
        "e" => 3, "f" => 5, "g" => 8, "h" => 13, "i" => 21, "j" => 34, "extra" => -1)
    
    fibr["a"] = 9
    fibr["b"] = 7
    
    # test restore all to default
    restoreall!(fibr)
    @test fibr["a"] == 0
    @test fibr["b"] == 1
    @test fibr["c"] == 1
    @test fibr["d"] == 2
    @test fibr["e"] == 3
    @test fibr["f"] == 5
    @test fibr["g"] == 8
    @test fibr["h"] == 13
    @test fibr["i"] == 21
    @test fibr["j"] == 34
    @test fibr["extra"] == -1

    # test adding a new key throws an error
    @test_throws ImmutableDictError begin fibr["newkey"] = 99 end
end

true
