using Documenter, BackedUpImmutable

makedocs(
    sitename = "BackedUpImmutable Module Documentation",
    format = Documenter.HTML(prettyurls = true, ansicolor = true),
)

deploydocs(
    repo = "github.com/wherrera10/BackedUpImmutable.jl.git",
    devbranch="master",
    forcepush=true,
)
