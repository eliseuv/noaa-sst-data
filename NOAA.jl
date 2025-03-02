module NOAA

using Dates, NetCDF

export
    # Remote
    SSTOI_URL, SSTOI_INIT_DATE, SSTOI_DATADIR, sstio_url,
    # Filename
    filename_date,
    # Attributes
    load_date, load_coords

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

struct GeoCoords
    longitudes::AbstractVector{<:Real}
    latitudes::AbstractVector{<:Real}
end

@inline load_coords(path::AbstractString)::GeoCoords =
    GeoCoords(ncread(path, "lon"), ncread(path, "lat"))

end
