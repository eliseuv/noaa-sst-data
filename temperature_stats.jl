using Dates, NetCDF, Statistics, StatsBase, DataFrames, JLD2

include("NOAA.jl")
using .NOAA

date_paths = map(readdir("./data/noaa/raw/sst-oi", sort=true, join=true)) do path
    date = filename_date(path)
    date => path
end
sort!(date_paths, by=first)

df = map(date_paths) do (date, path)

    println(date)

    sst = load_sst(path)

    T_min = minimum(skipmissing(sst))
    T_max = maximum(skipmissing(sst))

    (T_mean, T_var) = mean_and_var(skipmissing(sst))

    sst_norm = (sst .- T_mean) ./ sqrt(T_var)

    T_skewness = mean(skipmissing(sst_norm .^ 3))
    T_kurtosis = mean(skipmissing(sst_norm .^ 4))

    (date=date,
        min=T_min, max=T_max,
        mean=T_mean, var=T_var,
        skewness=T_skewness, kurtosis=T_kurtosis)

end |> DataFrame

@show df

save_object("./data/noaa/time_series/sst_global_stats.jld2", df)
