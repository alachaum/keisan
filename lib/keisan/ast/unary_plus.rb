module Keisan
  module AST
    class UnaryPlus < UnaryIdentity
      def self.symbol
        :"+"
      end
    end
  end
end
