# frozen_string_literal: true
require 'name_that_color/color/hex'

module NameThatColor
  module Color
    class RGB
      attr_reader :r, :g, :b

      def initialize(r, g, b)
        @r = r
        @g = g
        @b = b
      end

      def to_hex
        Hex.new("#{r.to_s(16)}#{g.to_s(16)}#{b.to_s(16)}")
      end
    end
  end
end
