using Dates, NetCDF, DataFrames, JLD2

include("NOAA.jl")
using .NOAA

# Define a list of reference geographical points (name => (latitude, longitude))
const points = [
    :tramandai => (-30, -50),
    :torres => (-29.34051, -49.71854),
    :buenos_aires => (-34.58110, -58.33740),
    :santos => (-24.00746, -46.35791),
    :natal => (-5.76970, -35.18937),
    :rio_de_janeiro => (-23.00082, -43.20290),
    :salvador => (-13.03543, -38.57957),
    :sao_luis => (-2.39158, -44.25513),
    :lisboa => (38.66165, -9.29347),
    :atenas => (37.91495, 23.66483),
    :magalhaes => (-58.44703, -63.93228),
    :golfo_do_mexico => (25.25662, -89.87256),
    :white_sea => (65.67993, 37.40944),
    :lima => (-12.13292, 282.93874),
    :caracas => (10.62099, 293.04746),
    :nemo => (-48.876667, -123.393333)]

# Create a DataFrame storing the approximate grid coordinates for each named point
df_coords = map(points) do (name, coord)
    coord_approx = approximate_coordinate(coord)
    (name=String(name), latitude=coord_approx.latitude, longitude=coord_approx.longitude)
end |> DataFrame
@show df_coords

# Initialize a dictionary to build the time-series dataset iteratively
data = Dict(:dates => Date[],
    [name => Union{Missing,Float64}[] for (name, _) in points]...)

# Iterate over all available daily NetCDF files in chronological order
for path in readdir("./data/noaa/raw/sst-oi", sort=true, join=true)
    println(path)
    # Extract date from the filename and add to the dates vector
    push!(data[:dates], filename_date(path))
    
    # Read fill value and scale factor for SST computation
    sst_missing = ncgetatt(path, "sst", "_FillValue")
    sst_scale = ncgetatt(path, "sst", "scale_factor")
    
    # For each reference point, extract the SST value for the current date
    for (name, coord) in points
        (i, j) = coord2index(coord)
        # Read the 1x1 chunk at the coordinate to avoid loading the whole globe
        sst_raw = dropdims(ncread(path, "sst", start=[j, i, 1, 1], count=[1, 1, 1, 1]), dims=(2, 3, 4))[begin]
        
        # Convert raw counts to physical units and handle missing data
        sst = if sst_raw == sst_missing
            missing
        else
            sst_raw * sst_scale
        end
        push!(data[name], sst)
    end
end

# Convert the populated dictionary into a DataFrame for easier analysis
df_sst = DataFrame(data)

# Save the extracted time-series and coordinates DataFrames into a JLD2 archive
const output_path = "./data/noaa/time_series/points.jld2"
mkpath(dirname(output_path))
jldsave(output_path; df_coords, df_sst)
