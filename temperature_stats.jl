using Dates, NetCDF, Statistics, StatsBase, DataFrames, JLD2

include("NOAA.jl")
using .NOAA

# Find all available raw SST files and map them to their corresponding Date
date_paths = map(readdir("./data/noaa/raw/sst-oi", sort=true, join=true)) do path
    date = filename_date(path)
    date => path
end
# Ensure data is sorted chronologically
sort!(date_paths, by=first)

# Compute global daily statistics for each daily dataset
df = map(date_paths) do (date, path)

    println(date)

    # Load and scale full resolution SST data, omitting land/ice mass
    sst = load_sst(path)

    # Compute descriptive statistics, skipping missing values
    T_min = minimum(skipmissing(sst))
    T_max = maximum(skipmissing(sst))

    (T_mean, T_var) = mean_and_var(skipmissing(sst))

    # Normalize values for skewness and kurtosis
    sst_norm = (sst .- T_mean) ./ sqrt(T_var)

    T_skewness = mean(skipmissing(sst_norm .^ 3))
    T_kurtosis = mean(skipmissing(sst_norm .^ 4))

    # Return NamedTuple to build the DataFrame
    (date=date,
        min=T_min, max=T_max,
        mean=T_mean, var=T_var,
        skewness=T_skewness, kurtosis=T_kurtosis)

end |> DataFrame

@show df

# Save daily global statistics to JLD2
save_object("./data/noaa/time_series/sst_global_stats.jld2", df)
