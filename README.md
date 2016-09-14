## Usage

Edit an mp3 file. You'll see a buffer with its metadata stored as ID3 tags, formatted like this:

    File: attempt_1.mp3
    ===================

    Title:    Elevator Music Attempt 1
    Artist:   Christiaan Bakker
    Album:    Echoes From The Past
    Track No:
    Year:     2011
    Genre:
    Comment:  Attribution 3.0

Editing the buffer will update the tags. You can also rename the file by changing the value in the `File: ` section.

Note that, for mp3 files, this requires the `id3` command-line tool. On Arch Linux, this is available from the `id3` package, installable with:

    pacman -S id3

The plugin also supports FLAC files (somewhat misleadingly, since they don't use id3 tags). For those, you'll need the `metaflac` command, which, on Arch Linux, comes from the `flac` package:

    pacman -S flac

On other platforms, you can probably use your favorite package manager to search for these.
