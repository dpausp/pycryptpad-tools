# Pycryptpad-Tools

A tools collection for [Cryptpad](https://cryptpad.fr).
Currently, there is a command line tool to create pads, set and get pad content.
Cryptpad lacks a proper API for external tools, so browser automation via Selenium
web driver is used for a quick-and-dirty solution without implementing the crypto stuff.
It's will likely break with future versions, but I hope there will be a better way to interact with Cryptpad.


## Tech Stack

* [Python 3.7](https://www.python.org)
* Chromium / Chromedriver
* Build / dependency management: [Nix Package Manager](https://nixos.org/nix)

## Using it

If you have installed the [Nix Package Manager](https://nixos.org/nix), running the CLI script is easy.
Nix installs all dependencies including Chromium / Chromedriver.

1. Clone the repository with:
    ~~~Shell
    git clone https://github.com/dpausp/pycryptpad-tools
    ~~~
2. Enter the project root folder:
    ~~~Shell
    cd pycryptpad-tools
    ~~~
3. Run the CLI script to see the available commands:
    ~~~Shell
    ./cryptpad-cli --help
    ~~~

- Running the Nix wrapper script ./cryptpad-cli takes some seconds.
  If you want to use the CLI regulary with shorter startup time, install it with:

  ~~~Shell
  nix-env -if .
  ~~~

If your shell is configured correctly (nix bin dir in PATH),
you should be able to run the cryptpad-cli command from anywhere.


## Development

### Quick Start

The shell environment for development can be prepared using the Nix Package Manager.
It includes Python, development / testing tools and dependencies for the project itself.
The following instructions assume that the Nix package manager is already installed, `nix-shell` is available in PATH.

1. Clone the repository with:
    ~~~Shell
    git clone https://github.com/dpausp/pycryptpad
    ~~~
2. Enter nix shell in the project root folder to open a shell which is your dev environment:
    ~~~Shell
    cd pycryptpad-tools
    nix-shell
    ~~~

## License

AGPLv3, see LICENSE

## Authors

* Tobias 'dpausp'

