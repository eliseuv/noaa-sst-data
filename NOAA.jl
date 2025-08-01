module NOAA

using Dates, NetCDF

export
    # Remote
    SSTOI_URL, SSTOI_INIT_DATE, SSTOI_DATADIR, sstio_url,
    # Filename
    filename_date,
    # Attributes
    load_date,
    # SST data
    load_sst_raw, load_sst,
    # Coordinates
    GeoCoord,
    coord2index,
    approximate_coordinate,
    read_sst


# Sea Surface Temperature – Optimum Interpolation
const SSTOI_URL = "https://www.ncei.noaa.gov/data/sea-surface-temperature-optimum-interpolation/v2.1/access/avhrr/"
const SSTOI_INIT_DATE = Date(1981, 09, 01)
const SSTOI_DATADIR = "./data/noaa/raw/sst-oi/"

# Get URL for SST-OI data for given date
@inline sstio_url(date::Date) =
    joinpath(SSTOI_URL, Dates.format(date, "yyyymm"), "oisst-avhrr-v02r01." * Dates.format(date, "yyyymmdd") * ".nc")

# Get date from filename

# Get timestamp from file
@inline filename_date(path::AbstractString) = splitext(basename(path))[begin] |> Date

# Get date attribute
@inline load_date(path::AbstractString)::Date =
    Date(ncgetatt(path, "global", "time_coverage_start"), "yyyy-mm-ddTHH:MM:SSZ")

function check_file(path::AbstractString)
    date_filename = splitext(basename(path))[begin] |> Date
    @assert date_filename == load_date(path) "Filename date mismatch with `time_coverage_start` variable!"
    # Load time: `time` variable is number of days since 1978-01-01
    time = ncread(path, "time") |> only
    date_time = Date(1978, 01, 01) + Day(Int64(time))
    @assert date_time == date_filename "Filename date mismatch with `time` variable!"
    # Assert the data is from sea level
    zlev = ncread(path, "zlev") |> only
    @assert zlev == zero(Float32) "`zlev` different from zero!"
end

@inline load_sst_raw(path::AbstractString) =
    dropdims(ncread(path, "sst"), dims=(3, 4))

@inline load_sst(path::AbstractString) =
    let sst_raw = load_sst_raw(path),
        sst_missing = ncgetatt(path, "sst", "_FillValue"),
        sst_scale = convert(Float64, ncgetatt(path, "sst", "scale_factor"))

        map(sst_raw) do sst
            if sst == sst_missing
                missing
            else
                sst * sst_scale
            end
        end

    end

# Geographic coordinates
struct GeoCoord
    # latitude ∈ [-90, 90)
    latitude::Real
    # longitude ∈ [0, 360)
    longitude::Real

    GeoCoord(latitude::Real, longitude::Real) =
        let latitude = rem(latitude + 90, 180, RoundDown) - 90,
            longitude = rem(longitude, 360, RoundDown)

            new(latitude, longitude)
        end
end

# Convert geographic coordinates to indices
@inline coord2index(coord::GeoCoord) =
    let latitude_idx = round(Int, (coord.latitude + 89.875) / 0.25) + 1,
        longitude_idx = round(Int, (coord.longitude - 0.125) / 0.25) + 1

        (latitude_idx, longitude_idx)
    end

# Approximate geographic coordinates to grid
@inline approximate_coordinate(coord::GeoCoord) =
    let (i, j) = coord2index(coord)
        GeoCoord((i - 1) * 0.25 - 89.875, (j - 1) * 0.25 + 0.125)
    end

# Read SST at given coordinates from file
@inline read_sst(path::AbstractString, coord::GeoCoord) =
    let (i, j) = coord2index(coord)
        sst_missing = ncgetatt(path, "sst", "_FillValue")
        sst_scale = convert(Float64, ncgetatt(path, "sst", "scale_factor"))
        sst_raw = dropdims(ncread(path, "sst", start=[j, i, 1, 1], count=[1, 1, 1, 1]), dims=(2, 3, 4))[begin]
        if sst_raw == sst_missing
            missing
        else
            sst_raw * sst_scale
        end
    end

end
