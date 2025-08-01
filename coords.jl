using NetCDF

include("NOAA.jl")
using .NOAA

const PATH = "./data/noaa/raw/sst-oi/1981-09-01.nc"

lat = ncread(PATH, "lat")
lon = ncread(PATH, "lon")

@show findfirst(lat .== -30.125)
@show findfirst(lon .== 360 - 50 + 0.125)

#= @show Int.((lat .+ 89.875) ./ 0.25) .+ 1 =#
#= @show Int.((lon .- 0.125) ./ 0.25) .+ 1 =#

@show lat
@show lon
