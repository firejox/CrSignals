# CrSignals [![Build Status](https://github.com/firejox/CrSignals/workflows/Crystal%20CI/badge.svg?branch=master)](https://github.com/firejox/CrSignals/actions) [![Release](https://img.shields.io/github/v/release/firejox/CrSignals)](https://github.com/firejox/CrSignals/releases)

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

class Foo
  include CrSignals::Generator
  
  property x : Int32 = 0

  cr_signal value_change(Int32)

  def set_x(v : Int32)
    if @x != v
      @x = v
      value_change(v)
    end
  end
end

a = Foo.new
b = Foo.new

a.connect_value_change(->b.set_x(Int32))

a.set_x(3)
puts b.x # => 3

a.disconnect_value_change(->b.set_x(Int32))

a.set_x(4)
puts b.x # => 3
```

* If you operate with incorrect type, it will report a compile error.

```crystal
require "CrSignals"

class Foo
  include CrSignals::Generator

  property x : Int32 = 0

  cr_signal value_change(Int32)

  def set_x(v : Float64); end
end

a = Foo.new
b = Foo.new

a.connect_value_change(->b.set_x(Float64)) # compile error
```

## Contributing

1. Fork it (<https://github.com/firejox/CrSignals/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Firejox](https://github.com/firejox) - creator and maintainer
