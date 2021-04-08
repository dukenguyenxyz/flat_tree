class FlatTree::Iterator
  property index : UInt64 = 0_u64
  property offset : UInt64 = 0_u64
  property factor : UInt64 = 0_u64

  def initialize(@index = 0_u64, @offset = 0_u64, @factor = 0_u64)
    self.seek(@index)
    self
  end

  # Move the iterator the this specific tree index.
  def seek(i : UInt64)
    @index = i
    @offset, @factor = if (@index & 1_u64)
                         {::FlatTree.offset(i), ::FlatTree.two_pow(::FlatTree.depth(i) + 1_u64)}
                       else
                         {(@index/2_u64).to_u64, 2_u64}
                       end
  end

  # Is the iterator at a left sibling?
  def is_left
    @offset.even?
  end

  # Is the iterator at a right sibling?
  def is_right
    @offset.odd?
  end

  def contains(i : UInt64)
    condition = i > @index ? i < (@index + @factor / 2_u64) : i < @index
    condition ? i > (@index - @factor / 2_u64) : true
  end

  # Move the iterator the prev item in the tree.
  def prev
    return @index if @offset == 0
    @offset -= 1_u64
    @index -= @factor
    @index
  end

  # Move the iterator the next item in the tree.
  def next
    @offset += 1_u64
    @index += @factor
    @index
  end

  # Move the iterator to the current sibling
  def sibling
    @is_left ? self.next : self.prev
  end

  # Move the iterator to the current parent index
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

  # Move the iterator to the current left span index.
  def left_span
    @index = @index - (@factor/2_u64).to_u64 + 1_u64
    @offset = (@index/2_u64).to_u64
    @factor = 2_u64
    @index
  end

  # Move the iterator to the current right span index.
  def right_span
    @index += @factor/2_u64 - 1_u64
    @offset = (@index/2_u64).to_u64
    @factor = 2_u64
    @index
  end

  # Move the iterator to the current left child index.
  def left_child
    return @index if @factor == 2_u64
    @factor = (@factor/2_u64).to_u64
    @index = (@index - @factor/2_u64).to_u64
    @offset *= 2_u64
    @index
  end

  # Move the iterator to the current right child index.
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

  def full_root(i : UInt64)
    return false if i <= @index || (@index & 1_u64) > 0_u64
    while i > @index + @factor + @factor/2_u64
      @index += (@factor/2_u64).to_u64
      @factor *= 2_u64
      @offset = (@offset/2_u64).to_u64
    end
    true
  end
end
