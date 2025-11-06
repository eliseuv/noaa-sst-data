using Dates, Downloads

include("NOAA.jl")
include("DataFetch.jl")

# Parse command line arguments to determine the start and end dates for fetching data
date_start, date_end = if isempty(ARGS)
    # Default to fetching from the beginning of the dataset to today
    (NOAA.SSTOI_INIT_DATE, today())
else
    # Determine the start date
    init = if ARGS[1] == "init"
        NOAA.SSTOI_INIT_DATE
    else
        Date(ARGS[1])
    end
    
    # Determine the end date
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

# Create output dir if it doesn't already exist
const OUTPUT_DIR = NOAA.SSTOI_DATADIR
mkpath(OUTPUT_DIR)

# Loop over the requested date range and download each daily file
for date ∈ date_start:date_end

    println("\n$(date)")

    # Construct local path and remote url
    path = joinpath(OUTPUT_DIR, string(date) * ".nc")
    url = NOAA.sstio_url(date)

    # Use custom DataFetch module which checks mod time and size before downloading
    DataFetch.download(url, path)

end
