# TIC-80 Pro Bundler

> [!IMPORTANT]
> This tool requires the **Pro version** of TIC-80. It relies on the ability to save and load cartridges as text-based files (`.rb`, `.lua`, etc.), a feature only available in TIC-80 Pro.

A simple, zero-dependency build script that empowers you to develop modular games for the [TIC-80](https://tic80.com/) fantasy computer, in any of its supported languages.

Break free from the single-file limitation of TIC-80's editor. This tool lets you organize your project into multiple files and directories, then bundles them into a single, valid cart file ready to be run.

## Features

-   **Multi-Language Support**: Works with Lua, MoonScript, JS, Ruby, Wren, and more.
-   **Modular Development**: Organize your game logic into separate files and folders.
-   **Idempotent**: The build process is safe to run multiple times. It automatically cleans up code from previous builds to prevent duplication.
-   **Convention-based**: Uses a simple `bundle.txt` file with an `#include` syntax to manage file order.
-   **Safe**: Never modifies your source files. It creates a new timestamped file in a `builds/` directory.
-   **Validation**: Performs basic checks on your master file to catch common errors early.
-   **Zero-dependency**: It's a single Ruby script with no external gems required.

## Installation

1.  Create a `bin` directory at the root of your project.
2.  Place the `build` script inside this `bin` directory.
3.  Make the script executable (you only need to do this once):
    ```sh
    chmod +x bin/build
    ```

## Usage

To build your project, run the script from your project's root and point it to your master file:
```sh
bin/build mygame.lua
```

> [!NOTE]
> The first time you run this command, if `bundle.txt` doesn't exist, the script will create a template file for you. Just fill it in and run the command again.

A new, bundled game file will be created in the `builds/` directory, ready to be loaded into TIC-80.

### Example `bundle.txt`

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
3.  **Iterate**:
    *   **For major changes**, edit the code in your `src/` files.
    *   **For quick tweaks**, you can edit the code directly inside TIC-80 and save the cartridge. This saved file can now be used as the master file for the next build.
4.  **Rebuild**: Run the build script again, using either your original master file or the file you just saved from TIC-80. The script is smart enough to clean up the old bundled code before injecting the new version.
    ```sh
    # Use the original master file
    bin/build mygame.rb

    # Or use the previously generated file as the new master
    bin/build builds/mygame-2023-10-27-103000.rb
    ```
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
