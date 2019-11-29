# CrSignals

CrSignals is a signals/slots library. You can define your signal/slot function, wire them and emit data.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     CrSignals:
       github: firejox/CrSignals
   ```

2. Run `shards install`

## Usage

* Here is a basic example of CrSignals library.

```crystal
require "CrSignals"

# this must be included when you use in each file
include CrSignals::Tool

class Foo
  property x : Int32 = 0

  cr_signal value_change(Int32)

  cr_slot set_x(v : Int32) do
    if @x != v
      @x = v
      cr_sig_emit(self, Foo, value_change, v)
    end
  end
end

a = Foo.new
b = Foo.new

cr_sig_connect(a, Foo, value_change, b.set_x(Int32))

a.set_x(3)
puts b.x # => 3

cr_sig_disconnect(a, Foo, value_change, b.set_x(Int32))

a.set_x(4)
puts b.x # => 3
```

* If you operate with incorrect type, it will report a compile error.

```crystal
require "CrSignals"

include CrSignals::Tool

class Foo
  property x : Int32 = 0

  cr_signal value_change(Int32)

  cr_slot set_x(v : Float64) do
  end
end

a = Foo.new
b = Foo.new

cr_sig_connect(a, Foo, value_change, b.set_x(Float64)) # compile error
```

## Contributing

1. Fork it (<https://github.com/firejox/CrSignals/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Firejox](https://github.com/firejox) - creator and maintainer
