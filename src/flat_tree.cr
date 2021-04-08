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

  def depth(i : UInt64?) : UInt64
    return 0_u64 if i.nil?
    (~BigInt.new(i)).trailing_zeros_count.to_u64
  end

  def sibling(i : UInt64, d : UInt64? = nil)
    d = self.depth(i) if d.nil?
    self.index(d, self.offset(i, d) ^ 1)
  end

  def parent(i : UInt64, d : UInt64? = nil) : UInt64
    d = self.depth(i) if d.nil?
    self.index(d + 1_u64, self.offset(i, d) >> 1_u64)
  end

  def left_child(i : UInt64 | Nil, d : UInt64? = nil) : UInt64 | Nil
    return nil if i.nil? || i.as(UInt64).even?
    i = i.as(UInt64)
    d = self.depth(i) if d.nil?
    if d == 0
      i
    else
      self.index(d - 1_u64, self.offset(i, d) << 1)
    end
  end

  def right_child(i : UInt64 | Nil, d : UInt64? = nil) : UInt64 | Nil
    return nil if i.nil? || i.as(UInt64).even?
    d = self.depth(i) if d.nil?
    if d == 0_u64
      i
    else
      self.index(d - 1, (1 + (self.offset(i, d) << 1)).to_u64)
    end
  end

  def children(i : UInt64, d : UInt64? = nil) : Array(UInt64) | Nil
    return nil if i.even?

    d = self.depth(i) if d.nil?
    o = self.offset(i, d) * 2_u64

    [
      index(d - 1_u64, o),
      index(d - 1_u64, o + 1_u64),
    ]
  end

  def left_span(i : UInt64, d : UInt64? = nil)
    return i if i == 0
    d = self.depth(i) if d.nil?
    offset(i, d) * (2_u64 << d)
  end

  def right_span(i : UInt64, d : UInt64? = nil)
    return i if i.even?
    d = self.depth(i) if d.nil?
    (offset(i, d) + 1_u64) * (2_u64 << d) - 2_u64
  end

  def count(i : UInt64, d : UInt64? = nil)
    d = self.depth(i) if d.nil?
    (2 << d) - 1_u64
  end

  def spans(i : UInt64, d : UInt64? = nil)
    return [i, i] if i.even?
    d = self.depth(i) if d.nil?
    o = offset(i, d)
    width = (2 << d)

    [o * width, (o + 1_u64) * width - 2_u64]
  end

  def index(d : UInt64, o : UInt64) : UInt64
    ((1_u64 + 2_u64 * o) * two_pow(d) - 1_u64).to_u64
  end

  def offset(i : UInt64, d : UInt64? = nil) : UInt64
    return (i/2_u64).to_u64 if i.even?
    d = self.depth(i) if d.nil?
    i >> (d + 1)
  end

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
