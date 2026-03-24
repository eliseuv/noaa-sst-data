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
    using NetCDF, Dates, JLD2, DataFrames, CairoMakie, GeoMakie
    NOAA = ingredients("./NOAA.jl").NOAA
end

# ╔═╡ b7c7b40c-1c2c-4937-bc4e-bf9100bbee6d
ncinfo("./data/noaa/raw/sst-oi/1981-09-01.nc")

# ╔═╡ 06950f82-ff19-4863-984a-b22826795ae7
NOAA.load_sst("./data/noaa/raw/sst-oi/1981-09-01.nc")

# ╔═╡ 8a181876-18e5-43b6-ac83-d7c228052a7e
# ╠═╡ disabled = true
#=╠═╡
let fig = Figure(),
	ga = GeoAxis(fig[1,1]; dest="+proj=wintri"),
	img = rotr90(GeoMakie.earth()),
	path = "./data/noaa/raw/sst-oi/1981-09-01.nc",
	mult = 10,
	sst = NOAA.load_sst(path)[begin:mult:end, begin:mult:end],
	latitudes = ncgetatt(path, "global", "geospatial_lat_min"):(mult*ncgetatt(path, "global", "geospatial_lat_resolution")):ncgetatt(path, "global", "geospatial_lat_max"),
	longitudes = ncgetatt(path, "global", "geospatial_lon_min"):(9*ncgetatt(path, "global", "geospatial_lon_resolution")):ncgetatt(path, "global", "geospatial_lon_max")
	
	#image!(ga, -180..180, -90..90, img; interpolate=false)

	surface!(ga, longitudes, latitudes, sst)
	
	fig
end	
  ╠═╡ =#

# ╔═╡ 90ccd907-a65e-4b2e-9909-2b015c16a9f9
let fig = Figure(),
	date = "2000-09-22",
	ax = Axis(fig[1,1];
			 title="DOISST $(date)"),
	path = "./data/noaa/raw/sst-oi/$(date).nc",
	sst = NOAA.load_sst(path),
	cmap = :thermal

	hidedecorations!(ax)
	
	hm = heatmap!(ax, sst; colormap=cmap)

	Colorbar(fig[end+1, begin], hm; vertical=false, flipaxis=false, label="Temperature (°C)")
	
	save("./plots/sst_example.png", fig)
	
	fig
end	

# ╔═╡ 67062ca7-fc4c-4c58-8b7b-f73036af1732
let fig = Figure(),
	date = "2000-09-22",
	ax = Axis(fig[1,1];
			 title="DOISST $(date)",
			 xlabel="Temperature"),
	path = "./data/noaa/raw/sst-oi/$(date).nc",
	sst = NOAA.load_sst(path)

	hist!(ax, filter(x -> !ismissing(x),sst), bins=128, normalization=:pdf)

	fig

end	

# ╔═╡ f7da6aae-a06a-4e57-9282-dea6055aff97
md"""
# Global temperature statistics
"""

# ╔═╡ 523344f1-f8b6-4d58-9dbb-666491203c57


# ╔═╡ b31045ae-8e23-4498-beff-a443ba21adaa
let df = load_object("./data/noaa/time_series/sst_global_stats.jld2"),
	fig = Figure(),
	n_days = nrow(df),
	tcks = 1:1550:n_days
	ax = Axis(fig[1,1];
			  title="Average Sea Surface Temperature",
			  limits=((1,n_days), nothing),
			  xticks=(tcks, string.(df.date[tcks])), xticklabelrotation=π/4)
	
	lines!(ax, df.var)
	
	save("./plots/average_sst.pdf", fig)

	fig
	
end

# ╔═╡ 1afb07d8-c255-4703-8702-dce9b4e5fdd5
md"""
# Uniform points
"""

# ╔═╡ fc4cec37-b89f-4917-b353-a0d862448038
let fig = Figure(),
	ga = GeoAxis(fig[1,1]; dest="+proj=wintri"),
	img = rotr90(GeoMakie.earth()),
	df_coords = load("./data/noaa/random_points/uniform.jld2", "df_coords"),
	latitudes = map(row -> row.latitude,eachrow(df_coords)),
	longitudes = map(row -> row.longitude,eachrow(df_coords))
	
	image!(ga, -180..180, -90..90, img; interpolate=false)

	scatter!(ga, longitudes, latitudes; color=:red)

	save("./plots/map_uniform_points.pdf", fig)
	
	fig
end	

# ╔═╡ Cell order:
# ╟─545aaffc-f9e6-11ef-3071-a1ea565f5cb0
# ╟─06f4e22b-9379-46a8-9477-824aa10f7bee
# ╠═b7c7b40c-1c2c-4937-bc4e-bf9100bbee6d
# ╠═06950f82-ff19-4863-984a-b22826795ae7
# ╠═8a181876-18e5-43b6-ac83-d7c228052a7e
# ╠═90ccd907-a65e-4b2e-9909-2b015c16a9f9
# ╠═67062ca7-fc4c-4c58-8b7b-f73036af1732
# ╟─f7da6aae-a06a-4e57-9282-dea6055aff97
# ╠═523344f1-f8b6-4d58-9dbb-666491203c57
# ╠═b31045ae-8e23-4498-beff-a443ba21adaa
# ╟─1afb07d8-c255-4703-8702-dce9b4e5fdd5
# ╠═fc4cec37-b89f-4917-b353-a0d862448038
