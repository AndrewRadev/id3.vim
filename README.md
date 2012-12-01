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

Editing the buffer will update the tags.

Note that this requires the `id3` command-line tool. On Arch Linux, this is available from the `id3` package, installable with:

    pacman -S id3

On other platforms, you can probably use your favorite package manager to search for it.
