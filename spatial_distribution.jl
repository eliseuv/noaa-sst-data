using Dates, NetCDF, Statistics, StatsBase, JLD2

include("NOAA.jl")
using .NOAA

const years_range = 1982:2024
const output_dir = "./data/noaa/spatial_dist/"

# Find all NetCDF data files corresponding to each year
const datafiles =
    let paths = readdir(NOAA.SSTOI_DATADIR, join=true),
        parse_date(path) = splitext(basename(path))[1] |> Date

        map(years_range) do y
            # Filter files by matching year
            y => paths |> filter(==(y) ∘ year ∘ parse_date)
        end

    end

# Iterate over each year and calculate spatial statistics over the averaged map
for (t, paths) ∈ datafiles
    println("year = $(t)")

    # 1. Average over all days of the year (Temporal mean)
    n_days = length(paths)
    ξₜⱼ = reduce(map(load_sst, paths)) do acc, Tₜₖ⁽ʲ⁾
        acc .+ Tₜₖ⁽ʲ⁾
    end ./ n_days

    # 2. Normalize over space
    # Compute the global spatial mean and spatial standard deviation for the given year
    (ξ̄ₜ, σₜ) = mean_and_std(skipmissing(ξₜⱼ))
    # Normalize the average yearly field
    zₜⱼ = (ξₜⱼ .- ξ̄ₜ) ./ σₜ

    # 3. Higher spatial moments
    # Skewness
    S = mean(skipmissing(zₜⱼ .^ 3))
    # Kurtosis
    K = mean(skipmissing(zₜⱼ .^ 4))

    # Save spatial metrics for the current year
    jldsave(joinpath(output_dir, "$(t).jld2"); dist=ξₜⱼ, mean=ξ̄ₜ, var=σₜ^2, S, K)

end
