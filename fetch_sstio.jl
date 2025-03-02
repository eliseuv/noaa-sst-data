using Dates, Downloads

include("NOAA.jl")
include("DataFetch.jl")

date_start, date_end = if isempty(ARGS)
    (NOAA.SSTOI_INIT_DATE, today())
else
    init = if ARGS[1] == "init"
        NOAA.SSTOI_INIT_DATE
    else
        Date(ARGS[1])
    end
    if length(ARGS) == 1
        (init, today())
    elseif length(ARGS) == 2
        final = if ARGS[2] == "today"
            today()
        else
            Date(ARGS[2])
        end
        (init, final)
    else
        error("Unable to parse arguments")
    end
end

println("Fetching NOAA data from $(date_start) to $(date_end)...")

# Create output dir
const OUTPUT_DIR = NOAA.SSTOI_DATADIR
mkpath(OUTPUT_DIR)

# for date ∈ SST_OI.date_init:Day(1):today()
for date ∈ date_start:date_end

    println("\n$(date)")

    path = joinpath(OUTPUT_DIR, string(date) * ".nc")
    url = NOAA.sstio_url(date)

    DataFetch.download(url, path)

end
