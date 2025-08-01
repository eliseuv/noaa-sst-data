### A Pluto.jl notebook ###
# v0.20.8

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
    using Dates, JLD2, DataFrames, CairoMakie
    NOAA = ingredients("./NOAA.jl").NOAA
end

# ╔═╡ abe4a16c-1a7b-448f-8d1a-ac8ebc196fb4
const df = load_object("./data/noaa/time_series/sst_global_stats.jld2")

# ╔═╡ 52a3b8f6-8d02-43fd-8482-22ff3a41b4c6
let fig = Figure(),
	ax = Axis(fig[1,1];
			 title="Daily Average Temperature")

	lines!(ax, df[!,:date], df[!,:mean])

	save("./plots/stats/temp_avg.pdf", fig)

	fig
end

# ╔═╡ beb61065-c550-4a26-9769-4fff9e5bf999
let fig = Figure(),
	ax = Axis(fig[1,1];
			 title="Daily Temperature Variance")

	lines!(ax, df[!,:date], df[!,:var])
	
	save("./plots/stats/temp_var.pdf", fig)

	fig
end

# ╔═╡ 5a9395ac-105e-4fcc-9f07-6cab53405e83
let fig = Figure(),
	ax = Axis(fig[1,1];
			 title="Daily Temperature Skewness")

	lines!(ax, df[!,:date], df[!,:skewness])

	save("./plots/stats/temp_skewness.pdf", fig)
	
	fig
end

# ╔═╡ eaade5b3-51b1-4cfe-b1b8-a14904bc9225
let fig = Figure(),
	ax = Axis(fig[1,1];
			 title="Daily Temperature Kurtosis")

	lines!(ax, df[!,:date], df[!,:kurtosis])

	save("./plots/stats/temp_kurtosis.pdf", fig)

	fig
end

# ╔═╡ Cell order:
# ╟─545aaffc-f9e6-11ef-3071-a1ea565f5cb0
# ╟─06f4e22b-9379-46a8-9477-824aa10f7bee
# ╟─abe4a16c-1a7b-448f-8d1a-ac8ebc196fb4
# ╠═52a3b8f6-8d02-43fd-8482-22ff3a41b4c6
# ╠═beb61065-c550-4a26-9769-4fff9e5bf999
# ╠═5a9395ac-105e-4fcc-9f07-6cab53405e83
# ╠═eaade5b3-51b1-4cfe-b1b8-a14904bc9225
