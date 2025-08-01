using Dates, NetCDF, Statistics, StatsBase, JLD2

include("NOAA.jl")
using .NOAA

const years_range = 1982:2024
const output_dir = "./data/noaa/spatial_dist/"

# Find all datafiles for each year
const datafiles =
    let paths = readdir(NOAA.SSTOI_DATADIR, join=true),
        parse_date(path) = splitext(basename(path))[1] |> Date

        map(years_range) do y
            y => paths |> filter(==(y) ∘ year ∘ parse_date)
        end

    end

for (t, paths) ∈ datafiles
    println("year = $(t)")

    # Average over all days of the year
    n_days = length(paths)
    ξₜⱼ = reduce(map(load_sst, paths)) do acc, Tₜₖ⁽ʲ⁾
        acc .+ Tₜₖ⁽ʲ⁾
    end ./ n_days

    # Normalize over space
    (ξ̄ₜ, σₜ) = mean_and_std(skipmissing(ξₜⱼ))
    zₜⱼ = (ξₜⱼ .- ξ̄ₜ) ./ σₜ

    # Higher moments
    S = mean(skipmissing(zₜⱼ .^ 3))
    K = mean(skipmissing(zₜⱼ .^ 4))

    jldsave(joinpath(output_dir, "$(t).jld2"); dist=ξₜⱼ, mean=ξ̄ₜ, var=σₜ^2, S, K)

end
