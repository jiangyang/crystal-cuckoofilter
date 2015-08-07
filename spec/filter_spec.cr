require "./spec_helper"

describe Cuckoofilter::Filter do

  it "init" do
    f = Cuckoofilter::Filter.new(100, 0.1)
    f.length.should eq(1024)
  end

  it "ops" do
    f = Cuckoofilter::Filter.new(100, 0.1)
    (f.includes?("def".bytes)).should eq(false)
    f << "abc".bytes
    (f.includes?("def".bytes)).should eq(false)
    f.add "a".bytes
    (f.includes?("def".bytes)).should eq(false)
    (f.includes?("abc".bytes)).should eq(true)
    (f.includes? ("a".bytes)).should eq(true)
    (f.includes? ("def".bytes)).should eq(false)
    f.delete "a".bytes
    (f.includes? ("a".bytes)).should eq(false)
    f.delete "abc".bytes
    (f.includes?("abc".bytes)).should eq(false)

    f.reset

    (f.includes?("def".bytes)).should eq(false)
    f << "abc".bytes
    (f.includes?("def".bytes)).should eq(false)
    f.add "a".bytes
    (f.includes?("def".bytes)).should eq(false)
    (f.includes?("abc".bytes)).should eq(true)
    (f.includes? ("a".bytes)).should eq(true)
    (f.includes? ("def".bytes)).should eq(false)
    f.delete "a".bytes
    (f.includes? ("a".bytes)).should eq(false)
    f.delete "abc".bytes
    (f.includes?("abc".bytes)).should eq(false)
  end

  it "full" do
    f = Cuckoofilter::Filter.new(100, 0.1)
    expect_raises(Cuckoofilter::FilterFull) do
      c = 10000
      while c > 0
        f << c.to_s.bytes
        c -= 1
      end
    end
  end

end