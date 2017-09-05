# frozen_string_literal: true
module NameThatColor
  module Util
    refine String do
      def dasherize
        gsub(/\s+|\./, '-').downcase
      end
    end
  end
end
