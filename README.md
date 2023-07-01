A small plugin for neovim to be able to view the changes between parts of a git conflict using [[:h diffsplit]](https://vimdoc.sourceforge.net/htmldoc/diff.html#:diffsplit)

## Requirements

- Neovim >= 0.5.0

## Install

[vim-plug](https://github.com/junegunn/vim-plug)

```sh
Plug 'ExuCounter/diff_conflict_parts.nvim'
```

[packer.nvim](https://github.com/wbthomason/packer.nvim)

```sh
use {
  'ExuCounter/diff_conflict_parts.nvim'
}
```

[lazy.nvim](https://github.com/folke/lazy.nvim)

```sh
require("lazy").setup {
  "ExuCounter/diff_conflict_parts.nvim"
}
```

## Setup:

```lua
local diff_conflict_parts = require("diff_conflict_parts")
diff_conflict_parts.setup()
```

Configuration can be passed to the setup function.
At this point you can only set up how, in which direction will open the diff.

```lua
require('diff_conflict_parts').setup({
  direction = "horizontal" -- "horizontal" or "vertical"
})
```

## Usage:

The plugin supports both styles of git conflicts - the default "merge" and "diff3".
It provides only 3 commands without any default mappings. 

```lua
:DiffHeadTheir
:DiffHeadParent
:DiffParentTheir
```

Each of the commands looks to see if our cursor is inside a conflict, and if so, opens parts of the conflict in the two splits (head and parent for example) and compares them via [[:h diffsplit]](https://vimdoc.sourceforge.net/htmldoc/diff.html#:diffsplit)

Note that DiffParentTheir and DiffHeadParent operate only in "diff3" mode [(merge-config-documentation)](https://git-scm.com/docs/merge-config)
