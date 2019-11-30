require "./spec_helper"

include CrSignals::Tool

private class TestedObject
  property value : Int32 = 0
  property value2 : Float64 = 0.0

  cr_signal value_change(Int32)

  cr_signal value_change(Float64)

  cr_slot set_value(y : Int32) do
    if @value != y
      @value = y
      cr_sig_emit(self, TestedObject, value_change, y)
    end
  end

  cr_slot set_value(y : Float64) do
    if @value2 != y
      @value2 = y
      cr_sig_emit(self, TestedObject, value_change, y)
    end
  end
end

describe CrSignals do
  it "can propagate value when connecting" do
    a = TestedObject.new
    b = TestedObject.new

    cr_sig_connect(a, TestedObject, value_change, ->b.value=(Int32))

    a.set_value(2)
    a.value.should eq(2)
    b.value.should eq(2)
  end

  it "will not change value after disconnect" do
    a = TestedObject.new
    b = TestedObject.new

    cr_sig_connect(a, TestedObject, value_change, ->b.value=(Int32))

    a.set_value(2)

    cr_sig_disconnect(a, TestedObject, value_change, ->b.value=(Int32))

    a.set_value(3)
    a.value.should eq(3)
    b.value.should eq(2)
  end

  it "support overloading" do
    a = TestedObject.new
    b = TestedObject.new

    cr_sig_connect(a, TestedObject, value_change, b.set_value(Int32))
    cr_sig_connect(a, TestedObject, value_change, b.set_value(Float64))

    a.set_value(2)
    a.set_value(3.0)

    b.value2.should eq(3.0)
    b.value.should eq(2)
  end
end
