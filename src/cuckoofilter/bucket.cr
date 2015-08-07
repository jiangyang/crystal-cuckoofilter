module Cuckoofilter

  struct Bucket
    def initialize(bucketSize : Int, fingerPrintSizeByte : Int)
      raise ArgumentError.new if bucketSize < 1 || fingerPrintSizeByte < 1
      @fp_size = fingerPrintSizeByte
      @slots = Array(Array(UInt8) | Nil).new(bucketSize, nil)
    end

    def length
      @slots.length
    end

    def [](index: Int)
      @slots[index]
    end

    def []=(index : Int, value : Array(UInt8))
      raise ArgumentError.new if value.length != @fp_size
      @slots[index] = value
    end

    def []=(index : Int, n : Nil)
      @slots[index] = nil
    end

    def indexOf(that: Array(UInt8))
      @slots.each_index do |idx|
        if @slots[idx] == that
          return idx
        end
      end
      -1
    end

    def contains?(that: Array(UInt8))
      indexOf(that) > -1
    end

    def emptySlot
      @slots.each_index do |idx|
        return idx if @slots[idx] == nil
      end
      -1
    end
  end
end
