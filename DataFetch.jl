module DataFetch

using Dates, Downloads

export download

function download(url::AbstractString, path::AbstractString)

    # Check if file exists
    if isfile(path)
        println("Local file $(path) already exists")
        # Fetch header
        header = Dict(Downloads.request(url, method="HEAD").headers)
        # Compare last modified time
        last_modified_local = unix2datetime(stat(path).mtime)
        last_modified_remote_str = header["last-modified"]
        last_modified_remote = DateTime(last_modified_remote_str[begin:end-4], DateFormat("e, d u y HH:MM:SS"))
        if last_modified_remote < last_modified_local
            println("\t✓ Up-to-date")
            # Compare filesize
            filesize_local = stat(path).size
            filesize_remote = parse(Int64, header["content-length"])
            if filesize_remote == filesize_local
                println("\t✓ Complete")
                return
            else
                println("""
\t File incomplete:
\t\tLocal filesize: $(filesize_local)
\t\tRemote filesize: $(filesize_remote)
""")
            end
        else
            println("""
\t File outdated:
\t\tLocal file last modified on $(last_modified_local)
\t\tRemote file last modified on $(last_modified_remote)
""")
        end
    end

    println("""
Downloading...
$(url)
=> $(path)
""")
    Downloads.download(url, path)

end

end
