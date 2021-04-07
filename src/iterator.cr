require "./flat_tree"

class FlatTree::Iterator
  property index : UInt64 = 0_u64
  property offset : UInt64 = 0_u64
  property factor : UInt64 = 0_u64

  def initialize(@index = 0_u64, @offset = 0_u64, @factor = 0_u64)
    self.seek(@index)
    self
  end

  def seek(_index : UInt64)
    @index = _index
    @offset, @factor = if (@index & 1_u64)
                         {::FlatTree.offset(_index), two_pow(::FlatTree.depth(_index) + 1_u64)}
                       else
                         {(@index/2_u64).to_u64, 2_u64}
                       end
  end

  def is_left
    @offset.even?
  end

  def is_right
    @offset.odd?
  end

  def contains(_index : UInt64)
    condition = _index > @index ? _index < (@index + @factor / 2_u64) : _index < @index
    condition ? _index > (@index - @factor / 2_u64) : true
  end

  def prev
    return @index if @offset == 0
    @offset -= 1_u64
    @index -= @factor
    @index
  end

  def next
    @offset += 1_u64
    @index += @factor
    @index
  end

  def sibling
    @is_left ? self.next : self.prev
  end

  def parent
    if @offset.odd?
      @index -= (@factor/2_u64).to_u64
      @offset = ((@offset - 1_u64)/2_u64).to_u64
    else
      @index += (@factor/2_u64).to_u64
      @offset = (@offset/2_u64).to_u64
    end
    @factor *= 2_u64
    @index
  end

  def left_span
    @index = @index - (@factor/2_u64).to_u64 + 1_u64
    @offset = (@index/2_u64).to_u64
    @factor = 2_u64
    @index
  end

  def right_span
    @index += @factor/2_u64 - 1_u64
    @offset = (@index/2_u64).to_u64
    @factor = 2_u64
    @index
  end

  def left_child
    return @index if @factor == 2_u64
    @factor = (@factor/2_u64).to_u64
    @index = (@index - @factor/2_u64).to_u64
    @offset *= 2_u64
    @index
  end

  def right_child
    return @index if @factor == 2_u64
    @factor = (@factor/2_u64).to_u64
    @index = (@index + @factor/2_u64).to_u64
    @offset = 2_u64 * @offset + 1_u64
    @index
  end

  def next_tree
    @index += (@factor/2_u64).to_u64 + 1_u64
    @offset = (@index/2_u64).to_u64
    @factor = 2_u64
    @index
  end

  def prev_tree
    unless @offset
      @index = 0_u64
      @factor = 2_u64
    else
      @index -= (@factor/2_u64).to_u64 - 1_u64
      @offset = (@index/2_u64).to_u64
      @factor = 2_u64
    end

    @index
  end

  def full_root(_index : UInt64)
    return false if _index <= @index || (@index & 1_u64) > 0_u64
    while _index > @index + @factor + @factor/2_u64
      @index += (@factor/2_u64).to_u64
      @factor *= 2_u64
      @offset = (@offset/2_u64).to_u64
    end
    true
  end

  protected def two_pow(n : UInt64) : UInt64
    if n < 31
      1 << n
    else
      ((1 << 30) * (1 << (n - 30)))
    end.to_u64
  end
end
