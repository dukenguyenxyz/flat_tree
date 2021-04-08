# flat_tree

[![Build Status](https://travis-ci.com/dukeraphaelng/flat_tree.svg?branch=master)](https://travis-ci.com/dukeraphaelng/flat_tree) [![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://dukeraphaelng.github.io/flat_tree/) [![GitHub release (latest by date)](https://img.shields.io/github/v/release/dukeraphaelng/flat_tree)](https://img.shields.io/github/v/release/dukeraphaelng/flat_tree?style=flat-square)

Map a binary tree to a vector. Port of [mafintosh/flat-tree](https://github.com/mafintosh/flat-tree)

- [Documentation](https://dukeraphaelng.github.io/flat_tree/)

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     flat_tree:
       github: dukeraphaelng/flat_tree
   ```

2. Run `shards install`

## Usage

You can represent a binary tree in a simple flat list using the following structure

```
      3
  1       5
0   2   4   6  ...
```

This module exposes a series of functions to help you build and maintain this data structure

```crystal
require "flat_tree"

list = [] of String

i = FlatTree.index(0_u64, 0_u64) # get array index for depth: 0, offset: 0
j = FlatTree.index(1_u64, 0_u64) # get array index for depth: 1, offset: 0

# use these indexes to store some data

list[i] = 'a'
list[j] = 'b'
list[FlatTree.parent(i)] = 'parent of a and b'
```

## Contributing

1. Fork it (<https://github.com/dukeraphaelng/flat_tree/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
  - This repository follows [Conventional Commits](http://conventionalcommits.org)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Duke Nguyen](https://github.com/dukeraphaelng) - creator and maintainer

## License

- [MIT](LICENSE)