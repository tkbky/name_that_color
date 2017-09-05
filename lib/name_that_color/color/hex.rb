# frozen_string_literal: true
require 'name_that_color/color/rgb'

module NameThatColor
  module Color
    class Hex
      attr_reader :v

      def initialize(v)
        @v = v
      end

      def to_rgb
        raise unless v.match?(/([0-9a-fA-F]{3,6})/)
        case v.length
        when 3 then RGB.new("#{v[0]}#{v[0]}".to_i(16), "#{v[1]}#{v[1]}".to_i(16), "#{v[2]}#{v[2]}".to_i(16))
        when 6 then RGB.new(v[0..1].to_i(16), v[2..3].to_i(16), v[4..5].to_i(16))
        else
          raise "Invalid color hex: #{v}"
        end
      end
    end
  end
end
