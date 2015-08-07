require "./spec_helper"

describe Cuckoofilter::Bucket do
  it "init" do
    expect_raises(ArgumentError) do
      Cuckoofilter::Bucket.new(4,0)
    end
    expect_raises(ArgumentError) do
      Cuckoofilter::Bucket.new(0,1)
    end

    b = Cuckoofilter::Bucket.new(4, 1)
    b.length().should eq(4)
    b[0].should eq(nil)
    b[1].should eq(nil)
    b[2].should eq(nil)
    b[3].should eq(nil)
    expect_raises(IndexError) do
      b[4]
    end
  end

  it "getter/setter" do
    b = Cuckoofilter::Bucket.new(4, 1)
    expect_raises(ArgumentError) do
      b[0] = Array(UInt8).new(4)
    end
    expect_raises(ArgumentError) do
      b[0] = Array(UInt8).new(5)
    end
    expect_raises(ArgumentError) do
      b[0] = [1_u8, 2_u8]
    end
    b[3].should eq(nil)
    b[3] = [1_u8]
    b[3].should eq([1])
    b[3] = nil
    b[3].should eq(nil)

    b[0] = [42_u8]
    b[0].should eq([42])
    b[0] = nil
    b[0].should eq(nil)
  end

  it "membership" do
    b = Cuckoofilter::Bucket.new(4,1)
    b[2] = [42_u8]
    b.indexOf([42_u8]).should eq(2)
    b.indexOf(Array(UInt8).new(4)).should eq(-1)
    b.indexOf(Array(UInt8).new(1)).should eq(-1)
    b.indexOf(Array(UInt8).new(1, 10_u8)).should eq(-1)
    b[1] = [99_u8]
    b[3] = nil
    b.indexOf([99_u8]).should eq(1)
    b.contains?([99_u8]).should be_true
    b.contains?([42_u8]).should be_true

    b = Cuckoofilter::Bucket.new(4,2)
    b[2] = [42_u8, 43_u8]
    b.indexOf([42_u8, 43_u8]).should eq(2)
    b.indexOf(Array(UInt8).new(4)).should eq(-1)
    b.indexOf(Array(UInt8).new(2)).should eq(-1)
    b.indexOf(Array(UInt8).new(2, 10_u8)).should eq(-1)
    b[1] = [99_u8, 98_u8]
    b[3] = nil
    b.indexOf([99_u8, 98u8]).should eq(1)
    b.contains?([99_u8, 98u8]).should be_true
    b.contains?([42_u8, 43u8]).should be_true
  end

  it "get empty slot index" do
    b = Cuckoofilter::Bucket.new(4,1)
    b.emptySlot.should eq(0)
    b[0] = [1u8]
    b.emptySlot.should eq(1)
    b[1] = [2u8]
    b.emptySlot.should eq(2)
    b[0] = nil
    b.emptySlot.should eq(0)
    b[0] = [1u8]
    b[2] = [3u8]
    b[3] = [4u8]
    b.emptySlot.should eq(-1)
  end

end
