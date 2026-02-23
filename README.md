# TIC-80 Build Tools

> [!IMPORTANT]
> The **`bundle` script requires TIC-80 Pro** as it relies on text-based cartridge formats which are only available in the Pro version.
>
> The **`build` script works with both free and Pro versions** of TIC-80:
> - **Free version**: Works normally, sources are always included in binaries
> - **Pro version**: Excludes sources by default for smaller binaries. Use `--with-sources` (`-s`) to include them

A collection of simple, zero-dependency scripts that provide a powerful workflow for developing and distributing games for the [TIC-80](https://tic80.com/) fantasy computer.

- **`bundle`**: Break free from the single-file limitation. Organize your project into multiple files and directories, and this script will bundle them into a single, valid cart file. *(Requires TIC-80 Pro)*
- **`build`**: Go from a bundled or a `.tic` cartridge to distributable binaries. This script automates the process of exporting your game for multiple platforms (Windows, macOS, Linux, Web, etc.). *(Works with free and Pro versions)*

## Features

- **Modular Development**: Organize your code in separate files and folders. (TIC-80 Pro only)
- **Multi-Platform Export**: Generate binaries for all major platforms with a single command.
- **Automated Zipping**: Optionally compress your binaries into `.zip` archives.
- **Source Inclusion**: Choose whether to include sources in your distributed binaries. (TIC-80 Pro only)
- **Multi-Language Support**: Works with Lua, MoonScript, JS, Ruby, Wren, and more. **(all examples in this file are Lua based but it should works with any language supported by TIC-80)**
- **Idempotent & Safe**: Scripts are safe to run multiple times and create timestamped outputs by default.
- **Easy Cleanup**: Keep your project tidy with `cleanup` commands for both cartridges and builds.
- **Convention-based**: Uses a simple `bundle.txt` file to specify which sources to include and in what order. (TIC-80 Pro only)
- **Zero-dependency & Broad Compatibility**: Just two Ruby scripts with no external dependencies. Works with Ruby 2.6+ already present on most systems.
- **Optional Environment Configuration** Variants: Auto-detect and preload `config.lua` and `config.<env>.lua` files for flexible environment-based configurations. (TIC-80 Pro only)

## Requirements

- **TIC-80**: Pro version required for `bundle` script, free version works for `build` script
- **Ruby 2.6+**: Already installed on macOS, Ubuntu/Debian, and most Linux distributions
- **TIC-80 executable** (`tic80`) in your PATH: Required for the `build` script, typically installed automatically with TIC-80 (especially on Debian/Ubuntu when using the `.deb` installer)
- **`zip`**: Required only when using `build -z`

## Installation

1.Create a `bin/` directory in your project and place the `bundle` and `build` scripts there.
2.Make the scripts executable (you only need to do this once):
  ```sh
  chmod +x bin/bundle bin/build
  ```
3.Add the following entries to your `.gitignore` file to keep your repository clean:
  ```gitignore
  # TIC-80 Build Tools output directories
  carts/
  dists/
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
├── config.lua         # Optional base configuration (auto-detected by bundle)
├── config.local.lua   # Optional local configuration variant (auto-detected by bundle)
└── mygame.lua         # Your master TIC-80 file
```

## Usage

### Using the `bundle` Script

The `bundle` script assembles all your source files (listed in `bundle.txt`) into one TIC-80 cartridge file.
It also auto-detects and preloads optional config variants:
- `config.lua` (base/prod config)
- `config.<env>.lua` (extra variants, where `<env>` has no dots, e.g. `local`)

**Basic Commands**
```sh
# Create a new, timestamped cartridge in the carts/ directory
bin/bundle mygame.lua

# For quick iteration, overwrite the master file directly
bin/bundle -f mygame.lua

# Clear bundled code from a master file
bin/bundle -c mygame.lua

# Remove old carts, keeping the most recents (one per variant)
bin/bundle cleanup
```

When config variants exist, `bundle` emits one artifact per config:
- Base: `mygame.lua` (or `carts/mygame-<timestamp>.lua`) with `config.lua` if present
- Variant: `mygame.local.lua` (or `carts/mygame.local-<timestamp>.lua`) for `config.local.lua`

> [!TIP]
> When you first run the script, if `bundle.txt` doesn't exist, it will create a template for you with examples. Make sure to list your files in dependency order (utilities first, main game logic last).
> Keep `config.lua` and `config.<env>.lua` files out of `bundle.txt`; they are preloaded automatically.
>
> Note: `-c` and `-f` are mutually exclusive.

**Example `bundle.txt`**

```
# This file lists all the source files to be included in the final build.
# The bundle script respects the order of inclusion, so make sure to
# list files with dependencies before the files that use them.

# Add your files here using the #include directive. For example:
#
# #include lib/utils.lua
# #include src/entities/player.lua
# #include src/main.lua
```

### Using the `build` Script

The `build` script takes a TIC-80 cartridge file (usually a bundled one from `carts/`) and exports it into distributable binaries for multiple platforms.

**Basic Commands**
```sh
# Export binaries for all platforms
bin/build mygame.lua

# Pro version: include sources in binaries (makes them larger)
bin/build -s mygame.lua

# Export and zip all binaries
bin/build -z mygame.lua

# Combine flags: export with sources and zip everything
bin/build -sz mygame.lua

# Remove old builds, keeping the most recents (one per variant)
bin/build cleanup
```
(works the same with .tic files, just replace `mygame.lua` with `mygame.tic`)


> [!NOTE]
> With TIC-80 Pro, sources are excluded by default for smaller file sizes. Use `-s` to include them. The free version always includes sources.

## Recommended Workflow

This toolset is designed for a smooth, iterative development cycle:

> [!NOTE]
> **For TIC-80 free users**: Steps 2, 3, and 5 (bundling workflow) are not available since they require TIC-80 Pro's text-based cartridge format. You can skip directly to step 6 and use `bin/build` with your existing `.tic` cartridge files.

1. **Code**: Write your game logic on TIC-80 or (TIC-80 Pro only) across multiple files and directories.
2. **Configure**: List your source files in `bundle.txt` in dependency order. *(TIC-80 Pro only)*
    - Please note that config files (`config.lua`, `config.local.lua`, etc.) are auto-detected and preloaded by `bundle`.
3. **Bundle**: Run `bin/bundle -f mygame.lua` for quick iteration. *(TIC-80 Pro only)*
4. **Test**: Open `mygame.lua` in TIC-80 and test your changes. Repeat steps 1-4 as you develop.
5. **Create Release**: Run `bin/bundle mygame.lua` for a timestamped cartridge. *(TIC-80 Pro only)*
6. **Build Binaries**: Run `bin/build [carts/]mygame.lua` or `bin/build mygame.tic` (add `-z` to zip, `-s` to include sources for TIC-80 Pro projects).
7. **Distribute**: Your game files are organized in `dists/`.
8. **Cleanup**: Periodically run `bin/bundle cleanup` and `bin/build cleanup`.

## License

This project is licensed under the MIT License.

## Refactor Safety Check

Run the cleanup regression test after changes to `bundle` or `build`:

```sh
bin/test_cleanup.sh
```
