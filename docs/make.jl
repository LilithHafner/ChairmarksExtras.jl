using ChairmarksExtras
using Documenter

DocMeta.setdocmeta!(ChairmarksExtras, :DocTestSetup, :(using ChairmarksExtras); recursive=true)

makedocs(;
    modules=[ChairmarksExtras],
    authors="Lilith Orion Hafner <lilithhafner@gmail.com> and contributors",
    sitename="ChairmarksExtras.jl",
    format=Documenter.HTML(;
        canonical="https://LilithHafner.github.io/ChairmarksExtras.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/LilithHafner/ChairmarksExtras.jl",
    devbranch="main",
)
