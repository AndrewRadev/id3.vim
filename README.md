![Demo](http://i.andrewradev.com/e3062961da3c802a1e860ef8e14cbc55.gif)

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

Editing the buffer will update the tags. You can also rename the file by changing the value in the `File:` section.

## Dependencies

### mp3 files

To edit an mp3 file you need a command-line id3 tag editor installed.
This plugin works with:

1. `id3`
1. `id3v2`
1. `id3tool`

You should be able to install any of these with your system's package manager, for example on Arch Linux:

    pacman -S id3

### flac files

The plugin also supports FLAC files (somewhat misleadingly, since they don't use id3 tags). For those, you'll need the `metaflac` command, which, on Arch Linux, comes from the `flac` package:

    pacman -S flac

On other platforms, you can probably use your favorite package manager to search for these.

## Updating genres using id3v2

The ID3 specification attributes a specific number to each genre.
To edit the genre when using the `id3v2` tool with this plugin you just need to set the number inside the brackets to the correct genre identifier.
When you write the buffer the text string in front of the brackets will be updated to match the number specified.
