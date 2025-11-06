using Dates, NetCDF, DataFrames, JLD2
include("NOAA.jl")
using .NOAA

# Reference data file used for grid dimensions and valid point checking
const REF_PATH = "./data/noaa/raw/sst-oi/1981-09-01.nc"
# ncinfo(REF_PATH)

const sst_ref = load_sst_raw(REF_PATH)
const latitudes = ncread(REF_PATH, "lat")
const longitudes = ncread(REF_PATH, "lon")

# Total desired number of valid sea coordinates
const n_points = 100_000

# Select random valid indices
indices = NTuple{2,Int64}[]
while length(indices) < n_points
    idx_lon = rand(1:1440)
    idx_lat = rand(1:720)
    
    # Check if this coordinate point has already been chosen and if it's over sea (!= -999)
    if (idx_lon, idx_lat) ∉ indices && sst_ref[idx_lon, idx_lat] != -999
        push!(indices, (idx_lon, idx_lat))
    end
end

# Get actual latitude and longitude coordinates mapping from indices
df_coords = map(indices) do (idx_lon, idx_lat)
    (idx_lat=idx_lat, idx_lon=idx_lon, longitude=longitudes[idx_lon], latitude=latitudes[idx_lat])
end |> DataFrame

@show df_coords

# Save the sampled point coordinates into a JLD2 archive
save_object("data/noaa/random_points/1e5_random_points.jld2", df_coords)
