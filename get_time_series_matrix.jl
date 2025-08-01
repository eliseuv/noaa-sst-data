using Dates, NetCDF, DataFrames, JLD2
include("NOAA.jl")
using .NOAA

# Load indices
const df_coords = load_object("./data/noaa/random_points/1e5_random_points.jld2")
const indices = map(eachrow(df_coords[!, [:idx_lon, :idx_lat]])) do row
    (row.idx_lon, row.idx_lat)
end

# For each date
data = map(readdir("./data/noaa/raw/sst-oi", sort=true, join=true)) do path
    date = filename_date(path)
    println(date)
    sst_missing = ncgetatt(path, "sst", "_FillValue")
    sst_scale = ncgetatt(path, "sst", "scale_factor")
    sst_raw = load_sst_raw(path)

    # Read the SST data for the random points
    date => map(indices) do (idx_lon, idx_lat)
        sst = sst_raw[idx_lon, idx_lat]
        if sst == sst_missing
            missing
        else
            sst * sst_scale
        end
    end
end
#= @show data =#

df_sst = let df = DataFrame(reduce(hcat, map(last, data)) |> permutedims, :auto)

    df[!, :dates] = first.(data)
    select!(df, :dates, Not(:dates))

    df
end
#= @show df_sst =#

save_object("./data/noaa/time_series/sst_1e5_random_points.jld2", df_sst)
