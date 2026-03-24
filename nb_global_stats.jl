### A Pluto.jl notebook ###
# v0.20.21

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
    using Dates, JLD2, DataFrames, CairoMakie, TimeSeries
    NOAA = ingredients("./NOAA.jl").NOAA
end

# ╔═╡ abe4a16c-1a7b-448f-8d1a-ac8ebc196fb4
const df = load_object("./data/noaa/time_series/sst_global_stats.jld2")

# ╔═╡ 9a227d7e-5e88-4e86-bae7-2694deb286d5
let fig = Figure()

	lines(fig[1,1], df[!,:date], df[!,:mean];
		  axis=(;
				xticks=DateTime(1982):Year(6):DateTime(2025),
		 		ylabel=L"\langle T \rangle", ylabelrotation=0, ylabelsize=20
			   )
		 )
	
	save("./plots/stats/temp_avg.pdf", fig)

	fig
end

# ╔═╡ a1509a2a-a566-4e92-99aa-98c51d5d4142
let fig = Figure()

	lines(fig[1,1], df[!,:date], df[!,:var];
		  axis=(;
				xticks=DateTime(1982):Year(6):DateTime(2025),
		 		ylabel=L"\text{var}(T)", ylabelrotation=0, ylabelsize=20
			   )
		 )
	
	save("./plots/stats/temp_var.pdf", fig)

	fig
end

# ╔═╡ 736fd761-aea3-47f7-a5b9-e35e8cd22f73
let fig = Figure()

	lines(fig[1,1], df[!,:date], df[!,:skewness];
		  axis=(;
				xticks=DateTime(1982):Year(6):DateTime(2025),
		 		ylabel=L"\text{S}(T)", ylabelrotation=0, ylabelsize=20
			   )
		 )
	
	save("./plots/stats/temp_skewness.pdf", fig)

	fig
end

# ╔═╡ a79f47c5-4f0f-4cd7-9d6e-e59a10f0407f
let fig = Figure()

	lines(fig[1,1], df[!,:date], df[!,:kurtosis];
		  axis=(;
				xticks=DateTime(1982):Year(6):DateTime(2025),
		 		ylabel=L"\text{K}(T)", ylabelrotation=0, ylabelsize=20
			   )
		 )
	
	save("./plots/stats/temp_kurtosis.pdf", fig)

	fig
end

# ╔═╡ Cell order:
# ╟─545aaffc-f9e6-11ef-3071-a1ea565f5cb0
# ╠═06f4e22b-9379-46a8-9477-824aa10f7bee
# ╠═abe4a16c-1a7b-448f-8d1a-ac8ebc196fb4
# ╠═9a227d7e-5e88-4e86-bae7-2694deb286d5
# ╠═a1509a2a-a566-4e92-99aa-98c51d5d4142
# ╠═736fd761-aea3-47f7-a5b9-e35e8cd22f73
# ╠═a79f47c5-4f0f-4cd7-9d6e-e59a10f0407f
