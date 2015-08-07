require "benchmark"
require "../src/cuckoofilter"

Benchmark.ips(warmup: 5, calculation: 10) do |b|
  f = Cuckoofilter::Filter.new(1000, 0.1)
  r = Random.new
  b.report("add") do
    begin
      f << r.next_int.to_s.bytes
    rescue Cuckoofilter::FilterFull
      f.reset
      f << r.next_int.to_s.bytes
    end
  end
  b.report("test") do
    f.includes? r.next_int.to_s.bytes
  end
end