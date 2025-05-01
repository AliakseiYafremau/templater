# temlpater

A command-line tool written in Haskell for managing and reusing file templates.

## Features

- Store files as reusable templates
- Load templates into your current workspace
- List all available templates
- Simple and intuitive command-line interface

## Installation

### Prerequisites

- GHC (Glasgow Haskell Compiler)
- Cabal or Stack

### Building from source

```bash
cabal build
cabal install
```

## Usage

The tool provides three main commands:

### Store a template

Save a file as a template:

```bash
temlpater store -t path/to/file
```

### Load a template

Load a template to your current directory:

```bash
temlpater load template-name
```

You can also specify a custom output path:

```bash
temlpater load template-name -o path/to/output
```

### List templates

View all available templates:

```bash
temlpater list
```

## Template Storage

Templates are stored in `~/.temlpater/` directory. Each template is stored as a separate file with its original name.

## License

This project is licensed under the MIT License - see the [`LICENSE`](LICENSE) file for details.