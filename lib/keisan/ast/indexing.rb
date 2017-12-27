module Keisan
  module AST
    class Indexing < UnaryOperator
      attr_reader :indexes

      def initialize(child, indexes = [])
        @children = [child]
        @indexes = indexes
      end

      def value(context = nil)
        return child.value(context).send(:[], *indexes.map {|index| index.value(context)})
      end

      def to_s
        "(#{child.to_s})[#{indexes.map(&:to_s).join(',')}]"
      end

      def evaluate_assignments(context = nil)
        self
      end

      def evaluate(context = nil)
        context ||= Context.new
        @children = children.map {|child| child.evaluate(context)}
        @indexes = indexes.map {|index| index.evaluate(context)}

        if list = extract_list
          element = list.children[@indexes.first.value(context)]
          element.nil? ? null_cell : element
        elsif hash = extract_hash
          element = hash[@indexes.first.value(context)]
          element.nil? ? null_cell : element
        else
          self
        end
      end

      def simplify(context = nil)
        evaluate(context)
      end

      def replace(variable, replacement)
        super
        @indexes = indexes.map {|index| index.replace(variable, replacement)}
      end

      private

      def null_cell
        AST::Cell.new(AST::Null.new)
      end

      def extract_list
        if child.is_a?(List)
          child
        elsif child.is_a?(Cell) && child.node.is_a?(List)
          child.node
        else
          nil
        end
      end

      def extract_hash
        if child.is_a?(AST::Hash)
          child
        elsif child.is_a?(Cell) && child.node.is_a?(AST::Hash)
          child.node
        else
          nil
        end
      end
    end
  end
end
