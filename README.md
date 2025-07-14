# TIC-80 Pro Bundler

> [!IMPORTANT]
> This tool requires the **Pro version** of TIC-80. It relies on the ability to save and load cartridges as text-based files (`.rb`, `.lua`, etc.), a feature only available in TIC-80 Pro.

A simple, zero-dependency build script that empowers you to develop modular games for the [TIC-80](https://tic80.com/) fantasy computer, in any of its supported languages.

Break free from the single-file limitation of TIC-80's editor. This tool lets you organize your project into multiple files and directories, then bundles them into a single, valid cart file ready to be run.

## Features

-   **Multi-Language Support**: Works with Lua, MoonScript, JS, Ruby, Wren, and more.
-   **Modular Development**: Organize your game logic into separate files and folders.
-   **Idempotent**: Safe to run multiple times; automatically cleans up previous builds.
-   **In-place Updates**: Use the `-f` flag to overwrite your master file for a faster workflow.
-   **Code Clearing**: Use the `-c` flag to easily strip bundled code from a master file.
-   **Easy Cleanup**: A `cleanup` command to remove old builds and keep your project tidy.
-   **Convention-based**: Uses a simple `bundle.txt` to manage file inclusion order.
-   **Safe by Default**: Creates new timestamped build files instead of modifying your sources.
-   **Validation**: Performs basic checks on your master file to catch common errors.
-   **Zero-dependency**: A single Ruby script with no external gems required.

## Installation

1.  Create a `bin` directory at the root of your project.
2.  Place the `build` script inside this `bin` directory.
3.  Make the script executable (you only need to do this once):
    ```sh
    chmod +x bin/build
    ```

## Usage

### Building your Project

To build your project, run the script from your project's root and point it to your master file:
```sh
# Create a new, timestamped build in the builds/ directory
bin/build mygame.lua
```

For a faster development cycle, you can use the `-f` flag to overwrite the master file directly, instead of creating a new file:
```sh
# Overwrite mygame.lua with the bundled code
bin/build -f mygame.lua
```

### Cleaning up Old Builds

To remove all but the most recent build file from the `builds/` directory, run:
```sh
bin/build cleanup
```

### Clearing Bundled Code from the Master File

To remove the bundled code block from a master file, reverting it to its original state (before any bundling), use the `-c` flag:
```sh
# Remove bundled code from mygame.lua
bin/build -c mygame.lua
```

> [!NOTE]
> The first time you run a build command, if `bundle.txt` doesn't exist, the script will create a template file for you. Just fill it in and run the command again.

## Example `bundle.txt`

The files listed in `bundle.txt` will be included in the final build in the exact order they are written. The bundler supports paths with or without quotes.

```
# The order of inclusion is respected by the build script.
# Ensure dependencies are loaded before files that use them.

#include src/player.lua
#include src/main.lua
```

## Recommended Project Structure

```
.
├── builds/
│   └── (generated files will appear here)
├── bin/
│   └── build          # The build script
├── src/
│   ├── main.lua       # Your core game logic
│   └── player.lua     # An example module
├── mygame.lua           # Your master TIC-80 file (entry point)
└── bundle.txt         # The file that lists your source files
```

## Recommended Workflow

The key feature of this bundler is its idempotent design, which allows for a flexible development cycle.

1.  **Initial Build**: Start with your master file (`mygame.rb`) and your source files in the `src/` directory. Run `./bin/build mygame.rb`.
2.  **Test**: Open the newly generated, timestamped file from the `builds/` directory in TIC-80 and test your game.
3.  **Iterate**: Make changes to your code in the `src/` files.
4.  **Rebuild**: Run the build script again.
    *   To directly update your master file for a quicker feedback loop (recommended for most development), use the `-f` flag.
        ```sh
        bin/build -f mygame.rb
        ```
    *   To create a versioned snapshot, run the build without flags.
        ```sh
        bin/build mygame.rb
        ```
5.  **Clean up**: Periodically, run `bin/build cleanup` to remove old builds from the `builds/` directory.

This cycle allows you to stay productive without ever worrying about creating code duplication.

## How It Works

The build script performs the following steps:
1.  It detects the language from your master file's extension (e.g., `.lua`, `.rb`).
2.  It validates the master file's header to ensure it's a standard TIC-80 file for that language.
3.  It automatically removes any code that was injected by a previous run of the script.
4.  It parses a `bundle.txt` file in your project root to get an ordered list of source files to include.
5.  It concatenates the content of each included file.
6.  It assembles a brand new file in the `builds/` directory, structured as follows:
    1.  The header from your master file (metadata comments).
    2.  The concatenated code from the files listed in `bundle.txt`, wrapped in special markers.
    3.  The code from your master file itself.
    4.  The asset sections (`# <TILES>`, `# <SPRITES>`, etc.) from your master file.

## License

This project is licensed under the MIT License.
