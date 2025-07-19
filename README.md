# TIC-80 Pro Build Tools

> [!IMPORTANT]
> The **`build` script requires TIC-80 Pro** as it relies on text-based cartridge formats which are only available in the Pro version.
>
> The **`make` script works with both free and Pro versions** of TIC-80:
> - **Free version**: Use the `--with-sources` (`-s`) flag to include sources in your binaries
> - **Pro version**: Works with or without the `--with-sources` flag (default excludes sources for smaller binaries)

A collection of simple, zero-dependency scripts that provide a powerful workflow for developing and distributing games for the [TIC-80](https://tic80.com/) fantasy computer.

-   **`build`**: Break free from the single-file limitation. Organize your project into multiple files and directories, and this script will bundle them into a single, valid cart file. *(Requires TIC-80 Pro)*
-   **`make`**: Go from a bundled cartridge to distributable binaries. This script automates the process of exporting your game for multiple platforms (Windows, macOS, Linux, Web, etc.). *(Works with free and Pro versions)*

## Features

-   **Modular Development**: Organize your code in separate files and folders.
-   **Multi-Platform Export**: Generate binaries for all major platforms with a single command.
-   **Automated Zipping**: Optionally compress your binaries into `.zip` archives.
-   **Source Inclusion**: Choose whether to include sources in your distributed binaries.
-   **Multi-Language Support**: Works with Lua, MoonScript, JS, Ruby, Wren, and more.
-   **Idempotent & Safe**: Scripts are safe to run multiple times and create timestamped outputs by default.
-   **Easy Cleanup**: Keep your project tidy with `cleanup` commands for both builds and distributions.
-   **Convention-based**: Uses a simple `bundle.txt` for source inclusion and sensible defaults.
-   **Zero-dependency**: Just two Ruby scripts. No external gems required.

## Installation

1.  Create a `bin/` directory in your project and place the `build` and `make` scripts there.
2.  Make the scripts executable (you only need to do this once):
    ```sh
    chmod +x bin/build bin/make
    ```
3.  Ensure you have TIC-80's executable (`tic80`) in your system's PATH for the `make` script to work.
    - For the `build` script: **TIC-80 Pro is required**
    - For the `make` script: Both free and Pro versions work (see usage notes below)
4.  Add the following entries to your `.gitignore` file to keep your repository clean:
    ```gitignore
    # TIC-80 Pro Build Tools output directories
    builds/
    dists/
    ```

## Usage

### Using the `build` Script

> [!NOTE]
> This script requires **TIC-80 Pro** as it works with text-based cartridge formats.

The `build` script assembles your source files from the `src/` directory into a single TIC-80 cartridge file.

**Building your Project**
```sh
# Create a new, timestamped build in the builds/ directory
bin/build mygame.lua
```
For a faster development cycle, use the `-f` flag to overwrite the master file directly:
```sh
# Overwrite mygame.lua with the bundled code
bin/build -f mygame.lua
```

**Cleaning up Old Builds**
```sh
# Remove all but the most recent build from the builds/ directory
bin/build cleanup
```

**Clearing Bundled Code**

To strip bundled code from a master file, use the `-c` flag:
```sh
bin/build -c mygame.lua
```

### Using the `make` Script

> [!NOTE]
> This script works with both **free and Pro versions** of TIC-80:
> - **If you have the free version**: Always use the `--with-sources` (`-s`) flag
> - **If you have TIC-80 Pro**: Use `--with-sources` (`-s`) to include sources, or omit it for smaller binaries without sources

The `make` script takes a TIC-80 cartridge file (usually a bundled one from `builds/`) and exports it into distributable binaries for multiple platforms.

**Making Binaries**
```sh
# For TIC-80 Pro (creates smaller binaries without sources)
bin/make builds/mygame-*.lua

# For free TIC-80 or if you want sources included
bin/make -s builds/mygame-*.lua
```

**Zipping Binaries**

To compress the exported files, use the `-z` flag. This is useful for sharing.
```sh
# Export and zip all binaries (Pro version)
bin/make -z builds/mygame-*.lua

# Export with sources and zip all binaries (free version or Pro with sources)
bin/make -sz builds/mygame-*.lua
```

**Including Sources in Binaries**

By default with TIC-80 Pro, the exported binaries don't include your source code for smaller file sizes. To include sources in the distributed binaries, use the `-s` flag:
```sh
# Export binaries with sources included (required for free TIC-80)
bin/make -s builds/mygame-*.lua

# You can combine flags: export with sources and zip everything
bin/make -sz builds/mygame-*.lua
```

**Cleaning up Old Distributions**
```sh
# Remove all but the most recent distribution from the dists/ directory
bin/make cleanup
```

## Recommended Project Structure

```
.
├── bin/
│   ├── build          # The build script (requires TIC-80 Pro)
│   └── make           # The make script (works with free and Pro)
├── builds/            # Bundled cartridges are generated here
│   └── ...
├── dists/             # Exported game binaries are generated here
│   └── ...
├── src/
│   ├── main.lua       # Your core game logic
│   └── player.lua     # An example module
├── .gitignore         # Should include builds/ and dists/
├── mygame.lua         # Your master TIC-80 file (entry point)
└── bundle.txt         # Lists source files for the `build` script
```

## Recommended Workflow

This toolset is designed for a smooth, iterative development cycle.

1.  **Code**: Write your game logic across multiple files in the `src/` directory.
2.  **Bundle**: Run the `build` script to assemble your source files into a single cartridge. *(Requires TIC-80 Pro)*
    ```sh
    # For quick iteration, update your master file directly
    bin/build -f mygame.lua
    ```
3.  **Test**: Open `mygame.lua` in the TIC-80 editor and test your changes. Repeat steps 1-3 as you develop.
4.  **Create a Versioned Build**: Once you're happy with your changes, create a final, timestamped build.
    ```sh
    bin/build mygame.lua
    ```
5.  **Make Binaries**: Use the `make` script to export your versioned build for all platforms.
    ```sh
    # For TIC-80 Pro users (smaller binaries without sources)
    bin/make builds/mygame-*.lua

    # For free TIC-80 users or if you want sources included
    bin/make -s builds/mygame-*.lua

    # Add -z flag to zip the outputs if desired
    ```
6.  **Distribute**: Your final, distributable game files are now organized in a new folder inside `dists/`.
7.  **Cleanup**: Periodically, run the cleanup commands to keep your workspace tidy.
    ```sh
    bin/build cleanup
    bin/make cleanup
    ```

## License

This project is licensed under the MIT License.
