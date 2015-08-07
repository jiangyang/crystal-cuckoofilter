module Cuckoofilter
  class Hash
    OFFSET32 = 2166136261
    PRIME32 = 16777619

    def self.fnv1a32(data : String)
      fnv1a32 data.bytes
    end

    def self.fnv1a32(data : Array(UInt8))
      o = OFFSET32
      data.each do |b|
        o = o ^ b
        o = o * PRIME32
      end
      o.to_u32
    end
  end
end