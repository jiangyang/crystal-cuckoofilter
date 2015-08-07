require "./hash"
require "./bucket"

MAX_BOUNCES = 500
BUCKET_SIZE = 4

private def calc_finger_print_size(b, falsePosRate)
  bytes = Math.log(2 * b / falsePosRate).ceil().to_u() / 8
  bytes <= 0 ? 1 : bytes
end

private def next_power_of_two(x)
  x -= 1
  x |= x >> 1
  x |= x >> 2
  x |= x >> 4
  x |= x >> 8
  x |= x >> 16
  x |= x >> 32
  x += 1
  x.to_i32
end

private def do_hashing(d : Array(UInt8), fpb)
  h1 = Cuckoofilter::Hash.fnv1a32 d
  fp = Array(UInt8).new(fpb as Int32, 0u8)
  fp.each_index do |idx|
    shift = (3 - idx) * 8
    fp[idx] = ((h1 & (0xff << shift)) >> shift).to_u8
  end

  h2 = h1 ^ Cuckoofilter::Hash.fnv1a32 fp
  {h1, h2, fp}
end

module Cuckoofilter
  class FilterFull < Exception 
  end

  struct Filter

    def initialize(cap : Int, falsePosRate : Float)
      raise ArgumentError.new if cap < 1 || falsePosRate <=0 || falsePosRate >= 1
      @finger_print_bytes = calc_finger_print_size BUCKET_SIZE, falsePosRate
      @num_buckets = next_power_of_two(cap / @finger_print_bytes * 8)
      @buckets = Array(Bucket).new(@num_buckets) do
        Bucket.new(BUCKET_SIZE, @finger_print_bytes)
      end
    end

    def length
      @buckets.length 
    end

    def <<(data : Array(UInt8))
      h1, h2, fp = do_hashing data, @finger_print_bytes
      i1, i2 = (h1 % @num_buckets).to_i, (h2 % @num_buckets).to_i
      # try first location
      b = @buckets[i1]
      bIdx = b.emptySlot
      if bIdx >  -1
        b[bIdx] = fp
        return self
      end
      # try alt location
      b = @buckets[i2]
      bIdx = b.emptySlot
      if bIdx > -1
        b[bIdx] = fp
        return self
      end
      # move stuff
      r = Random.new
      i, h = r.next_bool ? {i1, h1} : {i2, h2}
      #i,h,fp,bc
      bc = 0
      while bc < MAX_BOUNCES
        b = @buckets[i]
        bIdx = r.rand(0...BUCKET_SIZE).floor
        b[bIdx], fp = fp, b[bIdx]
        if fp
          h = h ^ Cuckoofilter::Hash.fnv1a32 fp
          i = (h % @num_buckets).to_i
          b = @buckets[i]
          bIdx = b.emptySlot
          if bIdx > -1
            b[bIdx] = fp
            return self
          end
        else
          return self
        end
        bc += 1
      end
      raise FilterFull.new
    end

    def add(data : Array(UInt8))
      self << data
    end

    def includes?(data : Array(UInt8))
      h1, h2, fp = do_hashing data, @finger_print_bytes
      i1, i2 = (h1 % @num_buckets).to_i, (h2 % @num_buckets).to_i
      @buckets[i1].contains?(fp) || @buckets[i2].contains?(fp)
    end

    def delete(data: Array(UInt8))
      h1, h2, fp = do_hashing data, @finger_print_bytes
      i1, i2 = (h1 % @num_buckets).to_i, (h2 % @num_buckets).to_i
      bIdx = @buckets[i1].indexOf(fp)
      if bIdx > -1
        @buckets[i1][bIdx] = nil
        return
      end
      bIdx = @buckets[i2].indexOf(fp)
      if bIdx > -1
        @buckets[i2][bIdx] = nil
        return
      end
    end

    def reset
      @buckets = Array(Bucket).new(@num_buckets) do
        Bucket.new(BUCKET_SIZE, @finger_print_bytes)
      end
    end

  end
end