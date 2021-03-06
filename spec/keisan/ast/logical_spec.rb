require "spec_helper"

RSpec.describe Keisan::AST::LogicalOperator do
  let(:calculator) { Keisan::Calculator.new }

  describe "evaluate" do
    it "raises error on base class" do
      expect{described_class.new(1).evaluate}.to raise_error(Keisan::Exceptions::NotImplementedError)
      expect{described_class.new(1).value}.to raise_error(Keisan::Exceptions::NotImplementedError)
    end

    it "leaves as logical comparison when cannot fully evaluate operands" do
      expect(Keisan::AST.parse("1 == x").evaluate).to be_a(Keisan::AST::LogicalEqual)
    end

    it "evaluates to a boolean for complex operands" do
      calculator.evaluate("a = [1, 2, 3]")
      calculator.evaluate("i = 1")
      calculator.evaluate("x = 2")
      expect(calculator.evaluate("a[i] == x")).to be true
      expect(calculator.evaluate("a[i] != x")).to be false
      expect(calculator.evaluate("a[i] < 0")).to be false
      expect(calculator.evaluate("a[i] <= 0")).to be false
      expect(calculator.evaluate("a[i] > 0")).to be true
      expect(calculator.evaluate("a[i] >= 0")).to be true
    end
  end

  describe "simplify" do
    it "short-circuits if possible" do
      expect(calculator.simplify("true || (x = 1)").value).to be true
      expect(calculator.simplify("x")).to be_a(Keisan::AST::Variable)

      expect(calculator.simplify("false && (x = 1)").value).to be false
      expect(calculator.simplify("x")).to be_a(Keisan::AST::Variable)

      expect(calculator.simplify("false || (x = 1)").value).to be 1
      expect(calculator.simplify("x").value).to eq 1
    end
  end
end
