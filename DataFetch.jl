module DataFetch

using Dates, Downloads

export download

"""
    download(url::AbstractString, path::AbstractString)

Download a file from `url` and save it to `path`.
If the file already exists locally, it checks the remote file's modification time and size.
If the local file is up-to-date and complete, the download is skipped.
"""
function download(url::AbstractString, path::AbstractString)

    # Check if file already exists locally
    if isfile(path)
        println("Local file $(path) already exists")
        
        # Fetch remote HTTP headers using a HEAD request
        header = Dict(Downloads.request(url, method="HEAD").headers)
        
        # Compare last modified times
        last_modified_local = unix2datetime(stat(path).mtime)
        last_modified_remote_str = header["last-modified"]
        # Parse the remote datetime string (e.g., "Mon, 01 Jan 2023 12:00:00 GMT")
        last_modified_remote = DateTime(last_modified_remote_str[begin:end-4], DateFormat("e, d u y HH:MM:SS"))
        
        if last_modified_remote < last_modified_local
            println("\t✓ Up-to-date")
            
            # Compare file sizes to ensure the file was completely downloaded
            filesize_local = stat(path).size
            filesize_remote = parse(Int64, header["content-length"])
            if filesize_remote == filesize_local
                println("\t✓ Complete")
                return # Skip download if file is complete and up-to-date
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

    # Proceed with the actual file download
    println("""
Downloading...
$(url)
=> $(path)
""")
    Downloads.download(url, path)

end

end
