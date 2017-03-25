module Keisan
  module AST
    class UnaryOperator < Parent
      def initialize(children = [])
        children = Array.wrap(children)
        super
        if children.count != 1
          raise Keisan::Exceptions::ASTError.new("Unary operator takes has a single child")
        end
      end

      def child
        children.first
      end

      def symbol
        self.class.symbol
      end
    end
  end
end
