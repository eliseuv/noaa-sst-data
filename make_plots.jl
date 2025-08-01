using LinearAlgebra, Statistics, JLD2, Dates, DataFrames, CairoMakie, ColorSchemes

@inline get_matrix(name::AbstractString, df_sst::DataFrame) =
    let df = dropmissing(select(df_sst, ["dates", name]), disallowmissing=true)
        reduce(hcat, sort(df[(Dates.year).(df.dates).==y, :], "dates")[begin:365, name] for y in years_range)
    end

@inline normalized(ts::AbstractVector) =
    let m = mean(ts),
        s = std(ts; mean=m)

        (ts .- m) ./ s
    end

@inline normalized(M_ts::AbstractMatrix) =
    reduce(hcat, map(normalized, eachcol(M_ts)))

@inline covariance_matrix(M_ts::AbstractMatrix) =
    Symmetric(M_ts' * M_ts) ./ size(M_ts, 1)

const df_sst = load("./data/noaa/time_series/points.jld2", "df_sst")
const points = names(df_sst) |> filter(!=("dates"))
const years_range = 1982:2024
const plots_dir = "./plots/"

mkpath(plots_dir)

for name in points
    @show name

    # Time Series
    println("Time Series")
    M_ts = get_matrix(name, df_sst)

    let fig = Figure(),
        ax = Axis(fig[1, 1];
            title="Time series for $(name)",
            xlabel="day",
            ylabel="Temperature (°C)",
            limits=((0, 365), nothing)),
        cbarPal = :viridis

        cmap = cgrad(colorschemes[cbarPal], size(M_ts, 2), categorical=true)
        for (ts, color) in zip(eachcol(M_ts), cmap)
            lines!(ax, ts, color=color)
        end
        Colorbar(fig[begin, end+1], limits=extrema(years_range), colormap=cmap, ticks=years_range[begin]:3:years_range[end])

        save(joinpath(plots_dir, "time_series_point=$(name).pdf"), fig)
    end

    # Normalized Time Series
    println("Normalized Time Series")
    M_ts_norm = normalized(M_ts)

    let fig = Figure(),
        ax = Axis(fig[1, 1];
            title="Normalized time series for $(name)",
            xlabel="day",
            ylabel="Normalized temperature",
            limits=((0, 365), nothing)),
        cbarPal = :viridis

        cmap = cgrad(colorschemes[cbarPal], size(M_ts, 2), categorical=true)
        for (ts, color) in zip(eachcol(M_ts_norm), cmap)
            lines!(ax, ts, color=color)
        end
        Colorbar(fig[begin, end+1], limits=extrema(years_range), colormap=cmap, ticks=years_range[begin]:3:years_range[end])

        save(joinpath(plots_dir, "time_series_norm_point=$(name).pdf"), fig)
    end

    # Covariance Matrix
    println("Covariance Matrix")
    M_cov = covariance_matrix(M_ts_norm)

    let fig = Figure(),
        ax = Axis(fig[1, 1];
            aspect=1,
            title="Covariance matrix for $(name)")

        hm = spy!(ax, M_cov, colormap=:jet)
        Colorbar(fig[begin, end+1], hm, ticks=0:0.05:1)

        save(joinpath(plots_dir, "covariance_matrix_point=$(name).pdf"), fig)
    end

    # Covariance Eigenvalues
    println("Covariance Matrix Eigenvalues")
    cov_eigvals = eigvals(M_cov)

    let fig = Figure(),
        ax = Axis(fig[1, 1];
            title="Covariance eigenvalues $(name)",
            xlabel=L"i",
            ylabel=L"\log(\lambda_i)")

        scatter!(ax, 0:(length(cov_eigvals)-1), log.(reverse(cov_eigvals)))

        save(joinpath(plots_dir, "covariance_eigvals_point=$(name).pdf"), fig)
    end

end
