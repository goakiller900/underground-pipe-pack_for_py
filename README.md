# Advanced Fluid Handling Continued for PyMods

**Advanced Fluid Handling Continued for PyMods** is the Factorio 2.1 continuation of the PyMods compatibility addon for Advanced Fluid Handling.

It adapts [Advanced Fluid Handling Continued](https://github.com/goakiller900/pipemod) for Pyanodon's mod suite by adjusting the underground pipe tiers, recipes, technology progression, graphics options and underground distances to better match PyMods.

The original PyMods addon was created by **Sopel** and later updated by **Dremon**. The original mod page is available here:

https://mods.factorio.com/mod/advanced_fluid_handling_for_py

## Requirements

This continuation requires:

* Factorio 2.1
* Advanced Fluid Handling Continued
* Py HighTech
* Py Industry

It also contains optional compatibility for:

* Py Alien Life
* Py HighTech Pipes Reskin
* Configurable Valves

The old `underground-pipe-pack_for_py` mod and this continuation cannot be enabled at the same time.

## What this addon changes

Compared with standard Advanced Fluid Handling Continued, the PyMods addon:

* Adds support for Pyanodon's braided pipe progression.
* Renames the three underground pipe tiers to Iron, Niobium and Multipurpose.
* Adjusts underground distances to match Pyanodon pipes.
* Adjusts recipes and technology progression for PyMods.
* Adjusts locale text to match Pyanodon terminology.
* Matches underground pump behavior more closely with the intended PyMods balance.
* Removes the 4-to-4 pipe configuration.
* Includes an optional setting to extend Iron underground pipes to the standard AFHC distance.
* Includes an optional setting to use the standard AFHC graphics.

## Why this continued version exists

The original PyMods addon depends on the original `underground-pipe-pack` mod and targets an older Factorio version.

This continuation gives the addon its own unique mod identity, updates it for Factorio 2.1 and changes its dependency to **Advanced Fluid Handling Continued**.

The goal is to keep the existing PyMods integration available without pretending that this is an official update from the original authors.

## Mod identity

Internal mod name:

`advanced-fluid-handling-continued-for-py`

Current version:

`0.0.1`

Required AFHC dependency:

`advanced-fluid-handling-continued >= 0.0.1`

## Builds and releases

Releases are built automatically by GitHub Actions.

Each push to `main` is validated and packaged as a Factorio-ready ZIP archive using the version from `info.json`.

For version `0.0.1`, the release archive is:

`advanced-fluid-handling-continued-for-py_0.0.1.zip`

The release workflow also creates a SHA-256 checksum and, when a release for the current version does not already exist, creates the Git tag:

`afhc-py-v0.0.1`

and publishes a GitHub release named:

`Advanced Fluid Handling Continued for PyMods version 0.0.1`

To build the archive locally:

```text
python scripts/build_afhc_py.py
```

The generated files are written to the `dist/` directory.

## Credits

Original Advanced Fluid Handling for PyMods addon by **Sopel**.

Later Factorio 2.0 and PyMods compatibility work by **Dremon**.

Factorio 2.1 continuation and AFHC dependency migration by **goakiller900**.

This project remains based on the work of its original authors and contributors.

## Source and issues

Source code and issue tracking:

https://github.com/goakiller900/underground-pipe-pack_for_py

Main Advanced Fluid Handling Continued project:

https://github.com/goakiller900/pipemod
