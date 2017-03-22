require "spec_helper"

RSpec.describe SymbolicMath::Parser do
  describe "components" do
    context "simple operations" do
      it "has correct components" do
        parser = described_class.new(string: "1 + 2 - 3 * 4 / x")

        expect(parser.components.map(&:class)).to match_array([
          SymbolicMath::Parsing::Number,
          SymbolicMath::Parsing::Plus,
          SymbolicMath::Parsing::Number,
          SymbolicMath::Parsing::Minus,
          SymbolicMath::Parsing::Number,
          SymbolicMath::Parsing::Times,
          SymbolicMath::Parsing::Number,
          SymbolicMath::Parsing::Divide,
          SymbolicMath::Parsing::Variable
        ])

        expect(parser.components[0].value).to eq 1
        expect(parser.components[2].value).to eq 2
        expect(parser.components[4].value).to eq 3
        expect(parser.components[6].value).to eq 4
        expect(parser.components[8].name).to eq "x"
      end
    end

    context "has brackets" do
      it "uses Parsing::Group to contain the element" do
        parser = described_class.new(string: "2 * (3 + 5)")

        expect(parser.components.map(&:class)).to match_array([
          SymbolicMath::Parsing::Number,
          SymbolicMath::Parsing::Times,
          SymbolicMath::Parsing::Group
        ])

        expect(parser.components[0].value).to eq 2

        group = parser.components[2]
        expect(group.components.map(&:class)).to match_array([
          SymbolicMath::Parsing::Number,
          SymbolicMath::Parsing::Plus,
          SymbolicMath::Parsing::Number
        ])

        expect(group.components[0].value).to eq 3
        expect(group.components[2].value).to eq 5
      end
    end

    context "has nested brackets" do
      it "uses Parsing::Group to contain the element" do
        parser = described_class.new(string: "x ** (y * (1 + z))")

        expect(parser.components.map(&:class)).to match_array([
          SymbolicMath::Parsing::Variable,
          SymbolicMath::Parsing::Exponent,
          SymbolicMath::Parsing::Group
        ])

        expect(parser.components[0].name).to eq "x"

        group = parser.components[2]
        expect(group.components.map(&:class)).to match_array([
          SymbolicMath::Parsing::Variable,
          SymbolicMath::Parsing::Times,
          SymbolicMath::Parsing::Group
        ])

        expect(group.components[0].name).to eq "y"

        group = group.components[2]
        expect(group.components.map(&:class)).to match_array([
          SymbolicMath::Parsing::Number,
          SymbolicMath::Parsing::Plus,
          SymbolicMath::Parsing::Variable
        ])

        expect(group.components[0].value).to eq 1
        expect(group.components[2].name).to eq "z"
      end
    end
  end

  context "has function call" do
    it "contains the correct arguments" do
      parser = described_class.new(string: "1 + atan2(x + 1, y - 1)")

      expect(parser.components.map(&:class)).to match_array([
        SymbolicMath::Parsing::Number,
        SymbolicMath::Parsing::Plus,
        SymbolicMath::Parsing::Function
      ])

      expect(parser.components[0].value).to eq 1
      expect(parser.components[2].name).to eq "atan2"

      arguments = parser.components[2].arguments
      expect(arguments.count).to eq 2

      expect(arguments.all? {|argument| argument.is_a?(SymbolicMath::Parsing::Argument)}).to be true

      expect(arguments.first.components.map(&:class)).to match_array([
        SymbolicMath::Parsing::Variable,
        SymbolicMath::Parsing::Plus,
        SymbolicMath::Parsing::Number
      ])
      expect(arguments.first.components[0].name).to eq "x"
      expect(arguments.first.components[2].value).to eq 1

      expect(arguments.last.components.map(&:class)).to match_array([
        SymbolicMath::Parsing::Variable,
        SymbolicMath::Parsing::Minus,
        SymbolicMath::Parsing::Number
      ])
      expect(arguments.last.components[0].name).to eq "y"
      expect(arguments.last.components[2].value).to eq 1
    end
  end
end