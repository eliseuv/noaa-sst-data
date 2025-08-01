using Dates, NetCDF, DataFrames, JLD2
include("NOAA.jl")
using .NOAA

const REF_PATH = "./data/noaa/raw/sst-oi/1981-09-01.nc"
# ncinfo(REF_PATH)

const sst = dropdims(ncread(REF_PATH, "sst"), dims=(3, 4))
const latitudes = ncread(REF_PATH, "lat")
const longitudes = ncread(REF_PATH, "lon")

const n_points = 1000

indices = NTuple{2,Int64}[]

while length(indices) < n_points
    i = rand(1:720)
    j = rand(1:1440)
    if sst[j, i] != -999
        push!(indices, (i, j))
    end
end

df_coords = map(indices) do (i, j)
    (latitude=latitudes[i], longitude=longitudes[j])
end |> DataFrame

@show df_coords

data = map(readdir("./data/noaa/raw/sst-oi", sort=true, join=true)) do path
    date = filename_date(path)
    sst_missing = ncgetatt(path, "sst", "_FillValue")
    sst_scale = ncgetatt(path, "sst", "scale_factor")
    sst_raw = dropdims(ncread(path, "sst"), dims=(3, 4))

    date => map(indices) do (i, j)
        sst = sst_raw[j, i]
        if sst == sst_missing
            missing
        else
            sst * sst_scale
        end
    end
end

@show data

df_sst = let df = DataFrame(reduce(hcat, map(last, data)) |> permutedims, :auto)

    df[!, :dates] = first.(data)
    select!(df, :dates, Not(:dates))

    df
end

jldsave("data/noaa/random_points/uniform.jld2"; df_coords, df_sst)

