# TIC-80 Build Tools

> [!IMPORTANT]
> The **`bundle` script requires TIC-80 Pro** as it relies on text-based cartridge formats which are only available in the Pro version.
>
> The **`build` script works with both free and Pro versions** of TIC-80:
> - **Free version**: Works normally, sources are always included in binaries
> - **Pro version**: Excludes sources by default for smaller binaries. Use `--with-sources` (`-s`) to include them

A collection of simple, zero-dependency scripts that provide a powerful workflow for developing and distributing games for the [TIC-80](https://tic80.com/) fantasy computer.

-   **`bundle`**: Break free from the single-file limitation. Organize your project into multiple files and directories, and this script will bundle them into a single, valid cart file. *(Requires TIC-80 Pro)*
-   **`build`**: Go from a bundled cartridge to distributable binaries. This script automates the process of exporting your game for multiple platforms (Windows, macOS, Linux, Web, etc.). *(Works with free and Pro versions)*

## Features

-   **Modular Development**: Organize your code in separate files and folders.
-   **Multi-Platform Export**: Generate binaries for all major platforms with a single command.
-   **Automated Zipping**: Optionally compress your binaries into `.zip` archives.
-   **Source Inclusion**: Choose whether to include sources in your distributed binaries.
-   **Multi-Language Support**: Works with Lua, MoonScript, JS, Ruby, Wren, and more.
-   **Idempotent & Safe**: Scripts are safe to run multiple times and create timestamped outputs by default.
-   **Easy Cleanup**: Keep your project tidy with `cleanup` commands for both cartridges and builds.
-   **Convention-based**: Uses a simple `bundle.txt` file to specify which sources to include and in what order.
-   **Zero-dependency**: Just two Ruby scripts. No external gems required.

## Installation

1.  Create a `bin/` directory in your project and place the `bundle` and `build` scripts there.
2.  Make the scripts executable (you only need to do this once):
    ```sh
    chmod +x bin/bundle bin/build
    ```
3.  Ensure you have TIC-80's executable (`tic80`) in your system's PATH for the `build` script to work.
    - For the `bundle` script: **TIC-80 Pro is required**
    - For the `build` script: Both free and Pro versions work
4.  Add the following entries to your `.gitignore` file to keep your repository clean:
    ```gitignore
    # TIC-80 Build Tools output directories
    carts/
    dists/
    ```

## Usage

### Using the `bundle` Script

> [!NOTE]
> This script requires **TIC-80 Pro** as it works with text-based cartridge formats.

The `bundle` script assembles all your source files (listed in `bundle.txt`) into a single TIC-80 cartridge file.

**Bundling your Project**
```sh
# Create a new, timestamped cartridge in the carts/ directory
bin/bundle mygame.lua
```

> [!TIP]
> When you first run the script, if `bundle.txt` doesn't exist, it will create a template for you with examples. Make sure to list your files in dependency order (utilities first, main game logic last).
For a faster development cycle, use the `-f` flag to overwrite the master file directly:
```sh
# Overwrite mygame.lua with the bundled code
bin/bundle -f mygame.lua
```

**Cleaning up Old Cartridges**
```sh
# Remove all but the most recent cartridge from the carts/ directory
bin/bundle cleanup
```

**Clearing Bundled Code**

To strip bundled code from a master file, use the `-c` flag:
```sh
bin/bundle -c mygame.lua
```

**Example `bundle.txt`**

```
# This file lists all the source files to be included in the final build.
# The bundle script respects the order of inclusion, so make sure to
# list files with dependencies before the files that use them.

# Add your files here using the #include directive. For example:
#
# #include config.lua
# #include lib/utils.lua
# #include src/entities/player.lua
# #include src/main.lua
```

### Using the `build` Script

> [!NOTE]
> This script works with both **free and Pro versions** of TIC-80:
> - **Free version**: Sources are always included in the exported binaries
> - **Pro version**: Sources are excluded by default for smaller binaries. Use `--with-sources` (`-s`) to include them

The `build` script takes a TIC-80 cartridge file (usually a bundled one from `carts/`) and exports it into distributable binaries for multiple platforms.

**Building Binaries**
```sh
# Works with both free and Pro versions (sources won't be included with Pro version)
bin/build carts/mygame-*.lua

# Pro version only: include sources in binaries (makes them larger)
bin/build -s carts/mygame-*.lua
```

**Zipping Binaries**

To compress the exported files, use the `-z` flag. This is useful for sharing.
```sh
# Export and zip all binaries
bin/build -z carts/mygame-*.lua

# Pro version only: export with sources and zip all binaries
bin/build -sz carts/mygame-*.lua
```

**Including Sources in Binaries**

With TIC-80 Pro, sources are excluded by default for smaller file sizes. To include sources in the distributed binaries, use the `-s` flag:
```sh
# Pro version only: export binaries with sources included
bin/build -s carts/mygame-*.lua

# Pro version only: combine flags to export with sources and zip everything
bin/build -sz carts/mygame-*.lua
```

**Cleaning up Old Builds**
```sh
# Remove all but the most recent build from the dists/ directory
bin/build cleanup
```

## Recommended Project Structure

```
.
├── bin/
│   ├── bundle         # The bundle script (requires TIC-80 Pro)
│   └── build          # The build script (works with free and Pro)
├── carts/             # Bundled cartridges are generated here
│   └── ...
├── dists/             # Exported game binaries are generated here
│   └── ...
├── lib/               # Shared utilities and libraries
│   └── utils.lua      # Helper functions
├── src/
│   ├── entities/      # Game entities
│   │   └── player.lua # Player entity
│   └── main.lua       # Core game logic
├── .gitignore         # Should include carts/ and dists/
├── bundle.txt         # Lists source files in dependency order
└── mygame.lua         # Your master TIC-80 file (entry point)
```

## Recommended Workflow

This toolset is designed for a smooth, iterative development cycle.

1.  **Code**: Write your game logic across multiple files and directories.
2.  **Include**: List your source files in `bundle.txt` in the correct dependency order (dependencies first, then files that use them).
3.  **Bundle**: Run the `bundle` script to assemble your source files into a single cartridge. *(Requires TIC-80 Pro)*
    ```sh
    # For quick iteration, update your master file directly
    bin/bundle -f mygame.lua
    ```
4.  **Test**: Open `mygame.lua` in the TIC-80 editor and test your changes. Repeat steps 1-4 as you develop.
5.  **Create a Versioned Cartridge**: Once you're happy with your changes, create a final, timestamped cartridge.
    ```sh
    bin/bundle mygame.lua
    ```
6.  **Build Binaries**: Use the `build` script to export your versioned cartridge for all platforms.
    ```sh
    # Works with both free and Pro versions
    bin/build carts/mygame-*.lua

    # Pro version only: include sources (makes binaries larger)
    bin/build -s carts/mygame-*.lua

    # Add -z flag to zip the outputs if desired
    ```
7.  **Distribute**: Your final, distributable game files are now organized in a new folder inside `dists/`.
8.  **Cleanup**: Periodically, run the cleanup commands to keep your workspace tidy.
    ```sh
    bin/bundle cleanup
    bin/build cleanup
    ```

## License

This project is licensed under the MIT License.
