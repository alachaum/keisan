module Keisan
  module AST
    class Exponent < ArithmeticOperator
      def arity
        (2..2)
      end

      def associativity
        :right
      end

      def self.symbol
        :**
      end

      def blank_value
        1
      end

      def simplify(context = nil)
        super

        if children[1].is_a?(AST::Number) && children[1].value(context) == 1
          return children[0]
        end

        if children.all? {|child| child.is_a?(ConstantLiteral)}
          return (children[0] ** children[1]).simplify(context)
        end

        case children[0]
        when AST::Exponent
          return AST::Exponent.new([
            children[0].children[0],
            AST::Times.new([children[0].children[1], children[1]])
          ]).simplify(context)
        when AST::Times
          return AST::Times.new(children[0].children.map do |term|
            AST::Exponent.new([term, children[1]])
          end).simplify(context)
        else
          case children[1]
          when AST::Plus
            return AST::Times.new(children[1].children.map do |exponent|
              AST::Exponent.new([children[0],exponent])
            end).simplify(context)
          end
        end

        self
      end
    end
  end
end
