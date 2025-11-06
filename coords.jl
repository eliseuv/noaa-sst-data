using NetCDF

include("NOAA.jl")
using .NOAA

# Path to a sample NetCDF file used for testing/inspecting coordinate limits
const PATH = "./data/noaa/raw/sst-oi/1981-09-01.nc"

# Read latitude and longitude arrays from the dataset
lat = ncread(PATH, "lat")
lon = ncread(PATH, "lon")

# Find the index of specific coordinate values to verify grid alignment
@show findfirst(lat .== -30.125)
@show findfirst(lon .== 360 - 50 + 0.125)

#= The commented-out section below demonstrates how to map coordinates to indices manually
@show Int.((lat .+ 89.875) ./ 0.25) .+ 1
@show Int.((lon .- 0.125) ./ 0.25) .+ 1 =#

# Display the full arrays
@show lat
@show lon
