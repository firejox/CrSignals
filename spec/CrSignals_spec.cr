require "./spec_helper"

private class TestedObject
  include CrSignals::Generator

  property value : Int32 = 0
  property value2 : Float64 = 0.0

  cr_signal value_change(Int32)

  cr_signal value_change(Float64)

  cr_signal clear

  def set_value(y : Int32)
    if @value != y
      @value = y
      value_change(y)
    end
  end

  def set_value(y : Float64)
    if @value2 != y
      @value2 = y
      value_change(y)
    end
  end

  def reset_all
    @value = 0
    @value2 = 0.0
  end
end

describe CrSignals do
  it "can propagate value when connecting" do
    a = TestedObject.new
    b = TestedObject.new

    a.connect_value_change(->b.value=(Int32))

    a.set_value(2)
    a.value.should eq(2)
    b.value.should eq(2)
  end

  it "will not change value after disconnect" do
    a = TestedObject.new
    b = TestedObject.new

    a.connect_value_change(->b.value=(Int32))

    a.set_value(2)

    a.disconnect_value_change(->b.value=(Int32))

    a.set_value(3)
    a.value.should eq(3)
    b.value.should eq(2)
  end

  it "support overloading" do
    a = TestedObject.new
    b = TestedObject.new

    a.connect_value_change(->b.set_value(Int32))
    a.connect_value_change(->b.set_value(Float64))

    a.set_value(2)
    a.set_value(3.0)

    b.value2.should eq(3.0)
    b.value.should eq(2)
  end

  it "support zero argument" do
    a = TestedObject.new
    b = TestedObject.new

    a.connect_value_change(->b.set_value(Int32))
    a.connect_clear(->b.reset_all)

    a.set_value 2

    b.value.should eq(2)
    a.clear
    b.value.should eq(0)
  end
end
