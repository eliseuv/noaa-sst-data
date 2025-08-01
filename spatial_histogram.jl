### A Pluto.jl notebook ###
# v0.20.13

using Markdown
using InteractiveUtils

# ╔═╡ 545aaffc-f9e6-11ef-3071-a1ea565f5cb0
begin
    using Pkg
    Pkg.activate(".")
    include("/home/evf/.julia/pluto_notebooks/ingredients.jl")
end

# ╔═╡ 06f4e22b-9379-46a8-9477-824aa10f7bee
begin
    using Dates, LinearAlgebra, Statistics, StatsBase, JLD2, DataFrames, CairoMakie, ColorSchemes
    NOAA = ingredients("./NOAA.jl").NOAA
end

# ╔═╡ e1c98fa8-26c8-428d-ab84-4db7479e2367
const DATA_PATH = "./data/noaa/spatial_dist/yearly/"

# ╔═╡ 61eea775-9067-46e6-ab76-f10d5e184738
md"""
# Statistics
"""

# ╔═╡ 4d8e3614-6598-4a31-a020-c0ecfbba5868
df_stats = map(readdir(DATA_PATH, join=true)) do path
	y = parse(Int, splitext(basename(path))[1])
	data = load(path)
	(year=y, mean=data["mean"], var=data["var"], S=data["S"], K=data["K"])
end |> DataFrame

# ╔═╡ 745ed206-acee-4333-8947-861a7652fa0e
let fig = Figure(),
	ax = Axis(fig[1,1],
			 title="Yearly Average Temperature",
			 xlabel="Year")

	scatterlines!(ax, df_stats[!,:year], df_stats[!,:mean])

	save("./plots/spatial_hist/temp_avg.pdf", fig)
	
	fig
end

# ╔═╡ c0323b87-86ab-4b7f-accf-28e4d2169cb9
let fig = Figure(),
	ax = Axis(fig[1,1],
			 title="Yearly Temperature Variance",
			 xlabel="Year")

	scatterlines!(ax, df_stats[!,:year], df_stats[!,:var])

	save("./plots/spatial_hist/temp_var.pdf", fig)
	
	fig
end

# ╔═╡ 300d314c-fc44-4eb9-8bb3-95c842ca26b1
let fig = Figure(),
	ax = Axis(fig[1,1],
			 title="Yearly Temperature Skewness",
			 xlabel="Year")

	scatterlines!(ax, df_stats[!,:year], df_stats[!,:S])

	save("./plots/spatial_hist/temp_skewness.pdf", fig)
	
	fig
end

# ╔═╡ 1c66a39f-f71b-491d-9c4a-9edce34b18eb
let fig = Figure(),
	ax = Axis(fig[1,1],
			 title="Yearly Temperature Kurtosis",
			 xlabel="Year")

	scatterlines!(ax, df_stats[!,:year], df_stats[!,:K])

	save("./plots/spatial_hist/temp_kurtosis.pdf", fig)
	
	fig
end

# ╔═╡ 4c25fa5b-abfb-4658-a000-7e59fc5b547d
md"""
# Histograms
"""

# ╔═╡ 2fc1121b-4105-4a1a-8fe7-fedee3fe1e64
const years_range = 1982:2024

# ╔═╡ cecf48a4-352c-4871-a838-94881c9c0cfc
let y = 1982,
	fig = Figure(),
	dist = load(joinpath(DATA_PATH, "$(y).jld2"), "dist"),
	vals = dist |> skipmissing |> collect,
	ax = Axis(fig[1,1],
			 title="Temperature Spatial Distribution ($(y))",
			 xlabel="Temperature",
			 yscale=log10,
			 limits=(extrema(vals), nothing))

	hist!(ax, vals, bins=128, normalization=:pdf, gap=0)

	fig
end

# ╔═╡ fd87947f-3a39-4266-ade2-bfb9a98ba497
for y ∈ years_range
	
fig = let fig = Figure(),
	dist = load(joinpath(DATA_PATH, "$(y).jld2"), "dist"),
	vals = dist |> skipmissing |> collect,
	ax = Axis(fig[1,1],
			 title="Temperature Spatial Distribution ($(y))",
			 xlabel="Temperature",
			 limits=(extrema(vals), (0, nothing)))

	hist!(ax, vals, bins=128, normalization=:pdf)

	fig
end

	#save("./plots/spatial_hist/$(y).pdf", fig)

end

# ╔═╡ 86598846-4345-4a30-a39a-e165459e23f4
fig = let fig = Figure(),
	ax = Axis(fig[1,1],
			 title="Yearly Temperature Histogram",
			 xlabel=L"Temperature ($^\circ\textrm{C}$)",
			 yscale=log10,
			 limits=((-2.5, 31), (1e3, 4e5))),
	edges = range(-2, 32, 128),
	x = midpoints(edges),
	years_range = 1982:2024,
	cmap = cgrad(colorschemes[:jet], length(years_range), categorical=true)
	
	for (year_sel, color) ∈ zip(years_range, cmap)
	
		vals = load(joinpath(DATA_PATH, "$(year_sel).jld2"), "dist") |>
			skipmissing |>
			collect

		hist = normalize(fit(Histogram, vals, edges); mode=:density)

		y = hist.weights

		lines!(ax, x, y; color=color)

	end

	Colorbar(fig[begin,begin+1]; colormap=cmap, limits=(years_range[begin], years_range[end]), nsteps=length(years_range), ticks=years_range[begin]:3:years_range[end])

	save("./plots/spatial_hist/all_years.pdf", fig)
	
	fig

end

# ╔═╡ ab92ee84-84fa-430c-928c-79b3aee7bc41


# ╔═╡ Cell order:
# ╠═545aaffc-f9e6-11ef-3071-a1ea565f5cb0
# ╠═06f4e22b-9379-46a8-9477-824aa10f7bee
# ╠═e1c98fa8-26c8-428d-ab84-4db7479e2367
# ╟─61eea775-9067-46e6-ab76-f10d5e184738
# ╠═4d8e3614-6598-4a31-a020-c0ecfbba5868
# ╠═745ed206-acee-4333-8947-861a7652fa0e
# ╠═c0323b87-86ab-4b7f-accf-28e4d2169cb9
# ╠═300d314c-fc44-4eb9-8bb3-95c842ca26b1
# ╠═1c66a39f-f71b-491d-9c4a-9edce34b18eb
# ╟─4c25fa5b-abfb-4658-a000-7e59fc5b547d
# ╟─2fc1121b-4105-4a1a-8fe7-fedee3fe1e64
# ╠═cecf48a4-352c-4871-a838-94881c9c0cfc
# ╠═fd87947f-3a39-4266-ade2-bfb9a98ba497
# ╠═86598846-4345-4a30-a39a-e165459e23f4
# ╠═ab92ee84-84fa-430c-928c-79b3aee7bc41
