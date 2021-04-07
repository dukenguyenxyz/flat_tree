require "./spec_helper"

describe FlatTree do
  it "#index" do
    FlatTree.index(0, 0).should eq(0)
    FlatTree.index(0, 1).should eq(2)
    FlatTree.index(0, 2).should eq(4)
  end

  it "#parent" do
    FlatTree.index(1, 0).should eq(1)
    FlatTree.index(1, 1).should eq(5)
    FlatTree.index(2, 0).should eq(3)

    FlatTree.parent(0).should eq(1)
    FlatTree.parent(2).should eq(1)
    FlatTree.parent(1).should eq(3)
  end

  it "#children" do
    FlatTree.children(0).should eq(FlatTree::None)
    FlatTree.children(1).should eq([0, 2])
    FlatTree.children(3).should eq([1, 5])
    FlatTree.children(9).should eq([8, 10])
  end

  it "#left_child" do
    FlatTree.left_child(0).should eq(FlatTree::None)
    FlatTree.left_child(1).should eq(0)
    FlatTree.left_child(3).should eq(1)
  end

  it "#right_child" do
    FlatTree.right_child(0).should eq(FlatTree::None)
    FlatTree.right_child(1).should eq(2)
    FlatTree.right_child(3).should eq(5)
  end

  it "#sibling" do
    FlatTree.sibling(0).should eq(2)
    FlatTree.sibling(2).should eq(0)
    FlatTree.sibling(1).should eq(5)
    FlatTree.sibling(5).should eq(1)
  end

  it "#full_roots" do
    FlatTree.full_roots(0).should eq([] of Int32)
    FlatTree.full_roots(2).should eq([0])
    FlatTree.full_roots(8).should eq([3])
    FlatTree.full_roots(20).should eq([7, 17])
    FlatTree.full_roots(18).should eq([7, 16])
    FlatTree.full_roots(16).should eq([7])
  end

  it "#depth" do
    FlatTree.depth(0).should eq(0)
    FlatTree.depth(1).should eq(1)
    FlatTree.depth(2).should eq(0)
    FlatTree.depth(3).should eq(2)
    FlatTree.depth(4).should eq(0)
  end

  it "#offset" do
    FlatTree.offset(0).should eq(0)
    FlatTree.offset(1).should eq(0)
    FlatTree.offset(2).should eq(1)
    FlatTree.offset(3).should eq(0)
    FlatTree.offset(4).should eq(2)
  end

  it "#spans" do
    FlatTree.spans(0).should eq([0, 0])
    FlatTree.spans(1).should eq([0, 2])
    FlatTree.spans(3).should eq([0, 6])
    FlatTree.spans(23).should eq([16, 30])
    FlatTree.spans(27).should eq([24, 30])
  end

  it "#left_span" do
    FlatTree.left_span(0).should eq(0)
    FlatTree.left_span(1).should eq(0)
    FlatTree.left_span(3).should eq(0)
    FlatTree.left_span(23).should eq(16)
    FlatTree.left_span(27).should eq(24)
  end

  it "#right_span" do
    FlatTree.right_span(0).should eq(0)
    FlatTree.right_span(1).should eq(2)
    FlatTree.right_span(3).should eq(6)
    FlatTree.right_span(23).should eq(30)
    FlatTree.right_span(27).should eq(30)
  end

  it "#count" do
    FlatTree.count(0).should eq(1)
    FlatTree.count(1).should eq(3)
    FlatTree.count(3).should eq(7)
    FlatTree.count(5).should eq(3)
    FlatTree.count(23).should eq(15)
    FlatTree.count(27).should eq(7)
  end

  it "parent > int32" do
    FlatTree.parent(10000000000).should eq(10000000001)
  end

  it "child to parent to child" do
    child = 0_u64
    50.times.each { |_| child = FlatTree.parent(child) }
    child.should eq(1125899906842623)
    50.times.each { |_| child = FlatTree.left_child(child) }
    child.should eq(0)
  end

  describe FlatTree::Iterator do
    it "iterates" do
      iterator = FlatTree::Iterator.new

      iterator.index.should eq(0)
      iterator.parent.should eq(1)
      iterator.parent.should eq(3)
      iterator.parent.should eq(7)
      iterator.right_child.should eq(11)
      iterator.left_child.should eq(9)
      iterator.next.should eq(13)
      iterator.left_span.should eq(12)
    end

    it "non-leaft start" do
      iterator = FlatTree::Iterator.new(1_u64)

      iterator.index.should eq(1)
      iterator.parent.should eq(3)
      iterator.parent.should eq(7)
      iterator.right_child.should eq(11)
      iterator.left_child.should eq(9)
      iterator.next.should eq(13)
      iterator.left_span.should eq(12)
    end

    it "#full_root" do
      iterator = FlatTree::Iterator.new(0_u64)

      iterator.full_root(0).should eq(false)
      iterator.full_root(22).should eq(true)
      iterator.index.should eq(7)
      iterator.next_tree.should eq(16)
      iterator.full_root(22).should eq(true)
      iterator.index.should eq(17)
      iterator.next_tree.should eq(20)
      iterator.full_root(22).should eq(true)
      iterator.index.should eq(20)
      iterator.next_tree.should eq(22)
      iterator.full_root(22).should eq(false)
    end

    it "#full_root, 10 big random trees" do
      10.times.each do |_|
        iterator = FlatTree::Iterator.new(0_u64)
        # Current limitation: cannot use big numbers
        tree = Random.rand.to_u64 * 2_u64
        expected = FlatTree.full_roots(tree)
        actual = [] of UInt64

        while iterator.full_root(tree)
          iterator.next_tree
          actual.push(iterator.index)
        end

        actual.sort.should eq(expected.sort)
        iterator.full_root(tree).should eq(false)
      end
    end
  end
end
