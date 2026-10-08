using Documenter, BackedUpImmutable

makedocs(
    sitename = "BackedUpImmutable Module Documentation",
    format = Documenter.HTML(prettyurls = false),
)

deploydocs(
    repo = "github.com/wherrera10/BackedUpImmutable.jl.git",
    devbranch = "main",
)
