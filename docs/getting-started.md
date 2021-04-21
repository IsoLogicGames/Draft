# Getting Started

Draft is designed to be easy to use. You shouldn't have to worry about what
goes on in the background. It does, however, require some setup before you can
start using it.

## Installation

Draft is packaged to easily use the filesystem alongside
[Roblox](https://www.roblox.com/) or
[Lemur](https://github.com/LPGhatguy/lemur), however it isn't required.
Using [Rojo](https://rojo.space/) to sync is the easiest method and will get
you started quickly.

### Using the Filesystem

When using the filesystem the first step is to download Draft.

The [latest release](https://github.com/IsoLogicGames/Draft/releases) can be
downloaded via [GitHub](https://github.com/IsoLogicGames/Draft).
Alternatively, if you'd like the latest developement changes or wish to
contribute you can clone or create a submodule of the repository with git.

```
git clone https://github.com/IsoLogicGames/Draft.git
```

#### Rojo

[Rojo](https://rojo.space/) is the easiest and simplest way to install
Draft. Start by [installing Rojo](https://rojo.space/docs/installation/). We
recommend using [Foreman](https://github.com/Roblox/foreman) or the
[Visual Studio Code extension](https://marketplace.visualstudio.com/items?itemName=evaera.vscode-rojo).

Once Rojo is installed just sync or build your project with Draft. Draft
includes a `default.project.json` that you can use. It includes all
of Draft, as well as its dependencies and tests.

A more basic `.project.json` can also be used to sync Draft.

```json
{
	"name": "Draft",
	"tree": {
		"$className": "DataModel",
		"ReplicatedStorage": {
			"$className": "ReplicatedStorage",
			"Draft": {
				"$path": "lib"
			}
		}
	}
}
```

#### Lemur

Draft is fully compatibile with [Lemur](https://github.com/LPGhatguy/lemur).
Draft uses Lemur for testing and this [testing script](https://github.com/IsoLogicGames/Draft/blob/master/tests/Lemur.server.lua)
can be used as an example.

Lemur and Draft can both be loaded from a Lua script:

```lua
package.path = package.path .. ";?/init.lua" -- Lua installations may need this

local Lemur = require("lemur")
local Habitat = Lemur.Habitat.new()
local ReplicatedStorage = Habitat.game:GetService("ReplicatedStorage")

local Draft = Habitat:loadFromFs("lib") -- lib is the root of Draft
Draft.Parent = ReplicatedStorage
```

!!! tip
	Lemur can't load from `.project.json` files, but can still load `.lua`
	files from the filesystem just like Rojo with `Habitat:loadFromFs()`.

#### Alternatives

Other syncing tools can be used for Draft provided they can build or sync
`*.lua` files into a Roblox place or model file or directly with Roblox Studio.

!!! important
	All `.lua` files in Draft are meant to be synced as a `ModuleScript`.

### Using Roblox

Creating the scripts manually in Roblox Studio can replicate the work done by a
sync tool such as Rojo without the need for any additional tooling or the use
of the filesystem.

!!! note
	In the future, Draft will release pre-built model packages that can be
	used with Roblox without any additional tooling or setup.

In order to recreate the structure of the project manually within Roblox:

1. Create a `ModuleScript` for the root Draft module wherever you'd like to
	use it from. Typically `ReplicatedStorage` is a good place for it.
2. Name it `Draft` (or use whatever name you'd like, it doesn't matter!) and
	copy the contents of `lib/init.lua` into it. This will be what you require
	when you use Draft.
3. Inside your root `ModuleScript` repeat each of th following steps for every
	script in Draft's `lib/` directory (we already did `lib/init.lua`, so you
	can skip it):
	1. Create a new `ModuleScript` inside of the root `ModuleScript`.
	2. Name it whatever the file is named in Draft excluding the `.lua` file
		extension. E.g. for `Example.lua` simply call it `Example`. Draft looks for
		these names, so they do matter this time.
	3. Copy the contents of the file in Draft into the new `ModuleScript`.

When you're done, the structure should look something like this, and you should
be able to require Draft without any errors.

```
|-- ReplicatedStorage
|	|-- Draft
|	|	|-- Example
|	|	|-- Example
|	|	|-- Example
|	|	|-- Example
|	|	|-- ...
```

!!! caution
	Using this method is very error prone at the moment. We recommend using a
	sync tool such as Rojo to avoid human error in the process.

	A sync tool can be used to sync with a blank project, then saved as a model,
	or copied into another project for cases where the rest of the project
	doesn't use the filesystem and it would be preferable to avoid syncing
	regularly.

## Usage

Once Draft is installed, assuming its named `Draft` and is located in
`ReplicatedStorage`, you can simply require it to start using it.

```lua
local Draft = require(game:GetService("ReplicatedStorage").Draft)
```

!!! note
	We'll assume from here on that `Draft` has already been required.
