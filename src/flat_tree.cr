# # Reference implementation
# https://github.com/datrs/flat-tree/blob/master/src/lib.rs
# https://github.com/mafintosh/flat-tree/blob/master/index.js

# Variable notation
# i -> index
# o -> offset
# d -> depth

require "big"
require "./iterator"

module FlatTree
  extend self

  # Returns a list of all the full roots (subtrees where all nodes have either 2 or 0 children) < index.
  # For example full_roots(8) returns [3] since the subtree rooted at 3 spans 0 -> 6 and the tree rooted
  # at 7 has a child located at 9 which is >= 8.
  def full_roots(i : UInt64, nodes : Array(UInt64) = [] of UInt64)
    raise ArgumentError.new("You can only look up roots for depth 0 blocks, got index #{i}") unless i.even?

    tmp = i >> 1
    o = 0_u64
    factor = 1_u64

    while tmp != 0_u64
      while (factor * 2_u64) <= tmp
        factor *= 2_u64
      end

      nodes.push(o + factor - 1_u64)
      o += 2_u64 * factor
      tmp -= factor
      factor = 1_u64
    end

    nodes
  end

  # Returns the depth of an element
  def depth(i : UInt64?) : UInt64
    return 0_u64 if i.nil?
    (~BigInt.new(i)).trailing_zeros_count.to_u64
  end

  # Returns the index of this elements sibling
  def sibling(i : UInt64, d : UInt64? = self.depth(i))
    self.index(d, self.offset(i, d) ^ 1)
  end

  # Returns the index of the parent element in tree
  def parent(i : UInt64, d : UInt64? = self.depth(i)) : UInt64
    self.index(d + 1_u64, self.offset(i, d) >> 1_u64)
  end

  # Returns only the left child of a node.
  def left_child(i : UInt64 | Nil, d : UInt64? = self.depth(i)) : UInt64 | Nil
    return nil if i.nil? || i.as(UInt64).even?
    i = i.as(UInt64)

    return i if d == 0
    self.index(d - 1_u64, self.offset(i, d) << 1)
  end

  # Returns only the right child of a node.
  def right_child(i : UInt64 | Nil, d : UInt64? = self.depth(i)) : UInt64 | Nil
    return nil if i.nil? || i.as(UInt64).even?
    i = i.as(UInt64)

    return i if d == 0_u64
    self.index(d - 1, (1 + (self.offset(i, d) << 1)).to_u64)
  end

  # Returns an array [left_child, right_child] with the indexes of this elements children.
  # If this element does not have any children it returns null
  def children(i : UInt64, d : UInt64? = self.depth(i)) : Array(UInt64) | Nil
    return nil if i.even?

    o = self.offset(i, d) * 2_u64

    [
      index(d - 1_u64, o),
      index(d - 1_u64, o + 1_u64),
    ]
  end

  # Returns the left spanning in index in the tree index spans.
  def left_span(i : UInt64, d : UInt64? = self.depth(i))
    return i if i == 0
    offset(i, d) * (2_u64 << d)
  end

  # Returns the right spanning in index in the tree index spans.
  def right_span(i : UInt64, d : UInt64? = self.depth(i))
    return i if i.even?
    (offset(i, d) + 1_u64) * (2_u64 << d) - 2_u64
  end

  # Returns how many nodes (including parent nodes) a tree contains
  def count(i : UInt64, d : UInt64? = self.depth(i))
    (2 << d) - 1_u64
  end

  # Returns the range (inclusive) the tree root at index spans.
  # For example FlatTree.spans(3) would return [0, 6] (see the usage example).
  def spans(i : UInt64, d : UInt64? = self.depth(i))
    return [i, i] if i.even?
    o = offset(i, d)
    width = (2 << d)

    [o * width, (o + 1_u64) * width - 2_u64]
  end

  # Returns an array index for the tree element at the given depth and offset
  def index(d : UInt64, o : UInt64) : UInt64
    ((1_u64 + 2_u64 * o) * two_pow(d) - 1_u64).to_u64
  end

  # Returns the relative offset of an element
  def offset(i : UInt64, d : UInt64? = self.depth(i)) : UInt64
    return (i/2_u64).to_u64 if i.even?
    i >> (d + 1)
  end

  # Create a stateful tree iterator starting at a given index. The iterator exposes the following methods.
  def iterator(i : UInt64 = 0u64)
    Iterator.new(i)
  end

  protected def two_pow(n : UInt64) : UInt64
    if n < 31_u64
      1_u64 << n
    else
      ((1_u64 << 30_u64) * (1_u64 << (n - 30_u64)))
    end.to_u64
  end
end
