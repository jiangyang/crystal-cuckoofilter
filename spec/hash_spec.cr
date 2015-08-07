require "./spec_helper"

describe Cuckoofilter::Hash do
  it "fnv1a 32 bit hash" do
    {
      "" => 0x811c9dc5, 
      "a" => 0xe40c292c, 
      "ab"=> 0x4d2505ca, 
      "abc" => 0x1a47e90b
    }.each do |k,v|
      Cuckoofilter::Hash.fnv1a32(k).should eq(v)
    end
  end
end
