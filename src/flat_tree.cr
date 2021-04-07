# https://github.com/datrs/flat-tree/blob/master/src/lib.rs
# https://github.com/mafintosh/flat-tree/blob/master/index.js

# _variable : argument declared in method
# variable_ : variable declared in method body

require "big"

module FlatTree
  extend self

  struct None
  end

  def full_roots(_index : UInt64, _nodes : Array(UInt64) = [] of UInt64)
    raise ArgumentError.new("You can only look up roots for depth 0 blocks, got index #{_index}") unless _index.even?

    tmp = _index >> 1
    offset_ = 0_u64
    factor_ = 1_u64

    while tmp != 0_u64
      while (factor_ * 2_u64) <= tmp
        factor_ *= 2_u64
      end

      _nodes.push(offset_ + factor_ - 1_u64)
      offset_ += 2_u64 * factor_
      tmp -= factor_
      factor_ = 1_u64
    end

    _nodes
  end

  def depth(_index : UInt64?) : UInt64
    return 0_u64 if _index.nil?
    (~BigInt.new(_index)).trailing_zeros_count.to_u64
  end

  def sibling(_index : UInt64, _depth : UInt64? = nil)
    _depth = self.depth(_index) if _depth.nil?
    self.index(_depth, self.offset(_index, _depth) ^ 1)
  end

  def parent(_index : UInt64, _depth : UInt64? = nil) : UInt64
    _depth = self.depth(_index) if _depth.nil?
    self.index(_depth + 1_u64, self.offset(_index, _depth) >> 1_u64)
  end

  def left_child(_index : UInt64 | None.class, _depth : UInt64? = nil) : UInt64 | None.class
    return None if _index.is_a?(UInt64) && _index.even? || _index.class == None
    _index = _index.as(UInt64)
    _depth = self.depth(_index) if _depth.nil?
    if _depth == 0
      _index
    else
      self.index(_depth - 1_u64, self.offset(_index, _depth) << 1)
    end
  end

  def right_child(_index : UInt64 | None.class, _depth : UInt64? = nil) : UInt64 | None.class
    return None if _index.even? || _index.class == None
    _depth = self.depth(_index) if _depth.nil?
    if _depth == 0_u64
      _index
    else
      self.index(_depth - 1, (1 + (self.offset(_index, _depth) << 1)).to_u64)
    end
  end

  def children(_index : UInt64, _depth : UInt64? = nil) : Array(UInt64) | None.class
    return None if _index.even?

    _depth = self.depth(_index) if _depth.nil?
    offset_ = self.offset(_index, _depth) * 2_u64

    [
      index(_depth - 1_u64, offset_),
      index(_depth - 1_u64, offset_ + 1_u64),
    ]
  end

  def left_span(_index : UInt64, _depth : UInt64? = nil)
    return _index if _index == 0
    _depth = self.depth(_index) if _depth.nil?
    offset(_index, _depth) * (2_u64 << _depth)
  end

  def right_span(_index : UInt64, _depth : UInt64? = nil)
    return _index if _index.even?
    _depth = self.depth(_index) if _depth.nil?
    (offset(_index, _depth) + 1_u64) * (2_u64 << _depth) - 2_u64
  end

  def count(_index : UInt64, _depth : UInt64? = nil)
    _depth = self.depth(_index) if _depth.nil?
    (2 << _depth) - 1_u64
  end

  def spans(_index : UInt64, _depth : UInt64? = nil)
    return [_index, _index] if _index.even?
    _depth = self.depth(_index) if _depth.nil?
    offset_ = offset(_index, _depth)
    width_ = (2 << _depth)

    [offset_ * width_, (offset_ + 1_u64) * width_ - 2_u64]
  end

  def index(_depth : UInt64, _offset : UInt64) : UInt64
    pp! _offset
    ((1 + 2 * _offset) * two_pow(_depth) - 1).to_u64
    # (_offset << (_depth + 1_u64)) | ((1 << _depth) - 1_u64)
  end

  def offset(_index : UInt64, _depth : UInt64? = nil) : UInt64
    return (_index/2_u64).to_u64 if _index.even?
    _depth = self.depth(_index) if _depth.nil?
    _index >> (_depth + 1)
  end

  def iterator(_index : UInt64 = 0_u64)
    iterator_ = Iterator.new
    iterator_.seek(_index)
    iterator
  end

  def two_pow(n : UInt64) : UInt64
    output = n < 31_u64 ? 1_u64 << n : ((1_u64 << 30_u64) * (1_u64 << (n - 30_u64)))
    output.to_u64
  end
end
