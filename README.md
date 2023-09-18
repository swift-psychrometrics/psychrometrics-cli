[![CI](https://github.com/swift-psychrometrics/psychrometrics-cli/actions/workflows/ci.yml/badge.svg)](https://github.com/swift-psychrometrics/psychrometrics-cli/actions/workflows/ci.yml)
 
# psychrometrics-cli

A command line tool for calculating psychrometric properties.

## Installation

You can install the command line utility using homebrew.

### Installing via Homebrew

Use the psychrometrics tap.

```bash
brew tap swift-psychrometrics/formula
```

Then install the command line utility.

```bash
brew install psychrometrics
```

### Using Docker Image

Pull the image

```bash
docker pull ghcr.io/swift-psychrometrics/psychrometrics-cli:latest
```

Run commands
```bash
docker run --rm ghcr.io/swift-psychrometrics/psychrometrics-cli <command>
```

## Calculations

There are several calculations included for calculating psychrometric properties of
air streams.
 
These are under the root command.

```bash
psychrometrics <command>
```

| Command | Description |
| ------- | ----------- |
| properties(default) | Calculates and displays lots of properties of an air sample. |
| dew-point | Calculate the dew point temperature |
| enthalpy | Calculate the enthalpy |
| grains | Calculate the grains of moisture |
| wet-bulb | Calculate the wet bulb temperature |

There are also several calculations for calculating dehumidifer / dehumidification
properties. 

These are under the `dh` sub-command.

```bash
psychrometrics dh <command>
```

| Command | Description |
| ------- | ----------- |
| pounds-removed | Calculate the pounds of water removed |
| size | Calculate the size / pints per day and hour given the latent load |

### Help

Use `--help` to display help information.

```bash
psychrometrics --help
```
 
```bash
pyschrometrics <command> --help
```
