using Dates, NetCDF, DataFrames, JLD2
include("NOAA.jl")
using .NOAA

# Reference data file
const REF_PATH = "./data/noaa/raw/sst-oi/1981-09-01.nc"
# ncinfo(REF_PATH)

const sst_ref = load_sst_raw(REF_PATH)
const latitudes = ncread(REF_PATH, "lat")
const longitudes = ncread(REF_PATH, "lon")

const n_points = 100_000

# Select random valid indices
indices = NTuple{2,Int64}[]
while length(indices) < n_points
    idx_lon = rand(1:1440)
    idx_lat = rand(1:720)
    if (idx_lon, idx_lat) ∉ indices && sst_ref[idx_lon, idx_lat] != -999
        push!(indices, (idx_lon, idx_lat))
    end
end

# Get coordinates
df_coords = map(indices) do (idx_lon, idx_lat)
    (idx_lat=idx_lat, idx_lon=idx_lon, longitude=longitudes[idx_lon], latitude=latitudes[idx_lat])
end |> DataFrame

@show df_coords

save_object("data/noaa/random_points/1e5_random_points.jld2", df_coords)
