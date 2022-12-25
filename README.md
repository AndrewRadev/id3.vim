![Demo](http://i.andrewradev.com/e3062961da3c802a1e860ef8e14cbc55.gif)

## Usage

Edit an mp3 file. You'll see a buffer with its metadata stored as ID3 tags, formatted like this:

```
File: Christiaan Bakker - Elevator Music Attempt #1.mp3
=======================================================

Title:    Elevator Music Attempt #1
Artist:   Christiaan Bakker
Album:    Echoes From The Past
Track No:
Year:
Genre:    (255)
Comment:  http://www.jamendo.com Attribution 3.0
```

Editing the buffer will update the tags. You can also rename the file by changing the value in the `File:` section.

## Dependencies

### ID3-JSON

The plugin uses a command-line tool to read and write the metadata. Annoyingly, the most reliable tool to do this is something I had to write myself, because all the other ones have varying availability in different operating systems, and/or have difficult-to-parse outputs.

If you have the Rust toolchain installed, you can install it from crates.io:

```
$ cargo install id3-json
```

But you can also use the precompiled binary for your operating system from the releases tab in github: <https://github.com/AndrewRadev/rust-id3-json/releases>:

- Linux: [binary](https://github.com/AndrewRadev/id3-json/releases/download/v0.1.2/id3-json_v0.1.2_x86_64-unknown-linux-musl.zip), [sha256 checksum](https://github.com/AndrewRadev/id3-json/releases/download/v0.1.2/id3-json_v0.1.2_x86_64-apple-darwin.zip.sha256sum)
- Windows: [binary](https://github.com/AndrewRadev/id3-json/releases/download/v0.1.2/id3-json_v0.1.2_x86_64-pc-windows-gnu.zip), [sha256 checksum](https://github.com/AndrewRadev/id3-json/releases/download/v0.1.2/id3-json_v0.1.2_x86_64-pc-windows-gnu.zip.sha256sum)
- Mac: [binary](https://github.com/AndrewRadev/id3-json/releases/download/v0.1.2/id3-json_v0.1.2_x86_64-apple-darwin.zip), [sha256 checksum](https://github.com/AndrewRadev/id3-json/releases/download/v0.1.2/id3-json_v0.1.2_x86_64-unknown-linux-musl.zip.sha256sum)

If the tool is in your PATH, it should work, but if you'd rather encapsulate it in your vimfiles or inside of your plugin installation, you can put it in any folder in Vim's runtime and set this variable:

```
let g:id3_executable_directory = 'vendor'
```

In this particular example, the plugin might find it in `~/.vim/vendor/id3-json`. This same lookup will work for all the other tools, just in case you'd like to build those from source and encapsulate them here as well.

### Other mp3 tools:

If you'd rather not install a special executable for it, you could use an existing command-line tool. This plugin works with:

1. `id3`
1. `id3v2`
1. `id3tool`

You should be able to install any of these with your system's package manager, for example on Arch Linux:

    pacman -S id3

Be warned that there are some issues with these (which is why I have my own). The first one has mostly worked reliably for me, but it seems it's not widely available. The `id3v2` tool works well, but some systems (including mine) have a version that doesn't support the `-R` flag. The last one only works with v1 tags and seems to truncate data to a certain character limit.

If there are multiple tools installed, the plugin will decide which to use based on a priority list stored in the `g:id3_mp3_backends` setting. See the Vim help docs for details.

### Flac, opus files

The plugin also supports FLAC and Opus files (somewhat misleadingly, since they don't use id3 tags). For FLAC support, you'll need the `metaflac` command, which, on Arch Linux, comes from the `flac` package:

    pacman -S flac

For opus, the plugin uses the `opustags` package which on Arch is in the AUR: <https://aur.archlinux.org/packages/opustags>

On other platforms, you can probably use your favorite package manager to search for these.

## Updating genres using id3v2

The ID3 specification attributes a specific number to each genre. To edit the genre when using the `id3v2` tool with this plugin you just need to set the number inside the brackets to the correct genre identifier. When you write the buffer the text string in front of the brackets will be updated to match the number specified.
