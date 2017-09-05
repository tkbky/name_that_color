# frozen_string_literal: true
require 'color_diff'
require 'thor'
require 'name_that_color/util/string'
require 'name_that_color/util/color'
require 'name_that_color/color/hex'
require 'name_that_color/colors'

require 'byebug'

module NameThatColor
  class Cli < Thor
    using NameThatColor::Util
    include NameThatColor::Util::Color

    HEX_COLOR_REGEX = /#([0-9a-fA-F]{3,6}).*;$/
    RGB_COLOR_REGEX = /rgba?\((\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3}),?\s*(\d*\.?\d+)?\).*;$/i # TODO: split into rgb & rgba maybe

    desc 'replace <input> <output>', 'replace colors in <input> and write the color name into <output>'
    def replace(infile, outfile)
      existing_colors = {}
      similar_colors = {}
      File.readlines(outfile).map(&:strip).reject(&:empty?).each do |c|
        k, v = c.split(':').map(&:strip)
        if v =~ HEX_COLOR_REGEX
          existing_colors[k] = Regexp.last_match(1).upcase
          similar_colors[Regexp.last_match(1).upcase] = Set.new([Regexp.last_match(1).upcase])
        elsif v =~ RGB_COLOR_REGEX
          # TODO: sanitize `v` to avoid duplication
          existing_colors[k] = to_rgba_css(Regexp.last_match(1), Regexp.last_match(2), Regexp.last_match(3), Regexp.last_match(4))
          similar_colors[to_rgba_css(Regexp.last_match(1), Regexp.last_match(2), Regexp.last_match(3), Regexp.last_match(4))] = Set.new([to_rgba_css(Regexp.last_match(1), Regexp.last_match(2), Regexp.last_match(3), Regexp.last_match(4))])
        else
          existing_colors[k] = v
        end
      end

      # pp existing_colors
      # pp similar_colors

      input = File.readlines(infile)

      input.each do |line|
        next if line.strip.empty?
        if line =~ HEX_COLOR_REGEX
          hex_str = Regexp.last_match(1).upcase
          c1 = Color::Hex.new(hex_str).to_rgb
          r1 = ColorDiff::Color::RGB.new(c1.r, c1.g, c1.b)
          color_diffs = COLORS.map do |color|
            c2 = Color::Hex.new(color[:hex].upcase).to_rgb
            r2 = ColorDiff::Color::RGB.new(c2.r, c2.g, c2.b)
            {
              name: color[:name],
              distance: ColorDiff.between(r1, r2),
              hex: color[:hex]
            }
          end
          closest_color = color_diffs.sort { |x, y| x[:distance] <=> y[:distance] }.first
          # puts "closest color: #{closest_color[:name]}"
          existing_colors["$#{closest_color[:name].dasherize}"] = (closest_color[:hex]).to_s
          similar_colors[(closest_color[:hex]).to_s] ||= Set.new
          similar_colors[(closest_color[:hex]).to_s] << hex_str
          similar_colors[(closest_color[:hex]).to_s] << closest_color[:hex]
        elsif line =~ RGB_COLOR_REGEX
          r = Regexp.last_match(1)
          g = Regexp.last_match(2)
          b = Regexp.last_match(3)
          a = Regexp.last_match(4)
          rgba_css = to_rgba_css(r, g, b, a)
          r1 = ColorDiff::Color::RGB.new(r.to_i, g.to_i, b.to_i)
          color_diffs = COLORS.map do |color|
            c2 = Color::Hex.new(color[:hex].upcase).to_rgb
            r2 = ColorDiff::Color::RGB.new(c2.r, c2.g, c2.b)
            {
              name: color[:name],
              distance: ColorDiff.between(r1, r2),
              hex: color[:hex]
            }
          end
          closest_color = color_diffs.sort { |x, y| x[:distance] <=> y[:distance] }.first
          # puts "closest color: #{closest_color[:name]}"
          closest_c = Color::Hex.new(closest_color[:hex].upcase).to_rgb
          closest_rgba_css = to_rgba_css(closest_c.r, closest_c.g, closest_c.b, a) # closest color has no `a`, so we use `a` from the input
          if a.nil?
            existing_colors["$#{closest_color[:name].dasherize}"] = closest_rgba_css.to_s
          else
            existing_colors["$transparent-#{closest_color[:name].dasherize}-#{a.dasherize}"] = closest_rgba_css.to_s
          end
          similar_colors[closest_rgba_css.to_s] ||= Set.new
          similar_colors[closest_rgba_css.to_s] << rgba_css
          similar_colors[closest_rgba_css.to_s] << closest_rgba_css
        end
      end

      dirname = File.dirname(outfile)
      extname = File.extname(outfile)
      filename = File.basename(outfile, extname)

      doc = input.join('')

      File.open(File.join(dirname, "#{filename}-copy.#{extname}"), 'w') do |f|
        existing_colors.each do |k, v|
          if "#{v}\;".match?(RGB_COLOR_REGEX)
            f.puts "#{k}: #{v};"
          else
            f.puts "#{k}: ##{v};"
          end
        end

        similar_colors.each do |base, similars|
          next if existing_colors.invert[base].nil?
          similars_escaped_str = similars.to_a.map { |s| s.gsub(/\(/, '\\(').gsub(/\)/, '\\)') }.join('|')
          # puts "gsub /#?#{similars_escaped_str}/i with #{existing_colors.invert[base]}"
          doc.gsub!(/#?(#{similars_escaped_str})/i, existing_colors.invert[base])
        end
      end

      dirname = File.dirname(infile)
      extname = File.extname(infile)
      filename = File.basename(infile, extname)

      File.open(File.join(dirname, "#{filename}-copy.#{extname}"), 'w') do |f|
        f.write(doc)
      end
    end
  end
end
