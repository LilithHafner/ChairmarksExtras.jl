# ChairmarksExtras

[![Build Status](https://github.com/LilithHafner/ChairmarksExtras.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/LilithHafner/ChairmarksExtras.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/LilithHafner/ChairmarksExtras.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/LilithHafner/ChairmarksExtras.jl)
[![PkgEval](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/C/ChairmarksExtras.svg)](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/C/ChairmarksExtras.html)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

[Chairmarks.jl](https://chairmarks.lilithhafner.com) with extra features. If a feature
is useful only very rarely, doesn't fit in with the Chairmarks.jl API, or isn't fully
finalized then it may belong here instead. Chairmarks.jl aims to have a small yet complete
feature set while this package aims to provide everything one may want, quite likely in many
different ways.

Features include
- Everything from Chairmarks
- `@belapsed`
- `@ballocated`
- `@ballocations`
- `@btime`
- `@btimed`
- Access benchmark properties with `benchmark.time` as an alias for `getproperty.(benchmark.samples, :time)`
