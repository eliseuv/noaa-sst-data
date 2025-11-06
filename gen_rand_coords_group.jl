using Dates, NetCDF, DataFrames, JLD2
include("NOAA.jl")
using .NOAA

# Path to the reference NetCDF file used to extract valid grid points
const REF_PATH = "./data/noaa/raw/sst-oi/1981-09-01.nc"
# ncinfo(REF_PATH)

# Load the raw Sea Surface Temperature and coordinate arrays
const sst = dropdims(ncread(REF_PATH, "sst"), dims=(3, 4))
const latitudes = ncread(REF_PATH, "lat")
const longitudes = ncread(REF_PATH, "lon")

# Number of random valid sea points to choose
const n_points = 1000

indices = NTuple{2,Int64}[]

# Randomly select `n_points` from the grid that contain valid data (not land/ice, -999)
while length(indices) < n_points
    i = rand(1:720) # Latitude index
    j = rand(1:1440) # Longitude index
    if sst[j, i] != -999
        push!(indices, (i, j))
    end
end

# Build a DataFrame mapping indices to geographical coordinates
df_coords = map(indices) do (i, j)
    (latitude=latitudes[i], longitude=longitudes[j])
end |> DataFrame

@show df_coords

# Extract the SST time series for each randomly selected point across all daily files
data = map(readdir("./data/noaa/raw/sst-oi", sort=true, join=true)) do path
    date = filename_date(path)
    sst_missing = ncgetatt(path, "sst", "_FillValue")
    sst_scale = ncgetatt(path, "sst", "scale_factor")
    sst_raw = dropdims(ncread(path, "sst"), dims=(3, 4))

    # Map the indices to the value for the given day
    date => map(indices) do (i, j)
        sst = sst_raw[j, i]
        if sst == sst_missing
            missing
        else
            sst * sst_scale # Scale raw values to physical temperature (°C)
        end
    end
end

@show data

# Process the resulting list of (Date => Vector{SST}) pairs into a single DataFrame
df_sst = let df = DataFrame(reduce(hcat, map(last, data)) |> permutedims, :auto)

    # Insert the date column at the beginning
    df[!, :dates] = first.(data)
    select!(df, :dates, Not(:dates))

    df
end

# Save the sampled coordinates and their generated time series to a JLD2 archive
jldsave("data/noaa/random_points/uniform.jld2"; df_coords, df_sst)

