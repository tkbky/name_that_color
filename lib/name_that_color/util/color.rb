# frozen_string_literal: true
module NameThatColor
  module Util
    module Color
      def to_rgba_css(r, g, b, a = nil)
        a ? "RGBA(#{r}, #{g}, #{b}, #{a})" : "RGB(#{r}, #{g}, #{b})"
      end
    end
  end
end
