# cuckoofilter

a cuckoo filter, largely based on [this go library](https://github.com/tylertreat/BoomFilters/blob/master/cuckoo.go)

## Installation

Add it to `Projectfile`

```crystal
deps do
  github "jiangyang/cuckoofilter"
end
```

## Usage

```crystal
require "cuckoofilter"
# new(capacity, desired false positive rate)
f = Cuckoofilter::Filter.new(100, 0.1)
# add item 
f << "abc".bytes
f.includes?("abc".bytes) # true
f.includes?("def".bytes) # false
f.reset
```

## Development


## Contributing

1. Fork it ( https://github.com/jiangyang/cuckoofilter/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [Yang](https://github.com/jiangyang) Yang - creator, maintainer
