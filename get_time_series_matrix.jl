using Dates, NetCDF, DataFrames, JLD2
include("NOAA.jl")
using .NOAA

# Load previously generated random coordinates/indices from file
const df_coords = load_object("./data/noaa/random_points/1e5_random_points.jld2")
const indices = map(eachrow(df_coords[!, [:idx_lon, :idx_lat]])) do row
    (row.idx_lon, row.idx_lat)
end

# Iterate over all available SST files for each date chronologically
data = map(readdir("./data/noaa/raw/sst-oi", sort=true, join=true)) do path
    date = filename_date(path)
    println(date)
    
    # Read scaling information and the entire raw data matrix
    sst_missing = ncgetatt(path, "sst", "_FillValue")
    sst_scale = ncgetatt(path, "sst", "scale_factor")
    sst_raw = load_sst_raw(path)

    # Read and scale the SST data for the loaded random points
    date => map(indices) do (idx_lon, idx_lat)
        sst = sst_raw[idx_lon, idx_lat]
        if sst == sst_missing
            missing
        else
            sst * sst_scale # Convert raw values to actual temperature
        end
    end
end
#= @show data =#

# Convert the array-of-pairs list into a single DataFrame
df_sst = let df = DataFrame(reduce(hcat, map(last, data)) |> permutedims, :auto)

    # Insert the date column at the start of the DataFrame
    df[!, :dates] = first.(data)
    select!(df, :dates, Not(:dates))

    df
end
#= @show df_sst =#

# Save the aggregated time series DataFrame mapping dates to SST readings
save_object("./data/noaa/time_series/sst_1e5_random_points.jld2", df_sst)
