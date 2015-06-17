module Opmac2html
  # Mixin providing text partitioning
  module TextCutter
    def cut_at(separator)
      part = @input.partition separator
      @input = part[2]
      part[0]
    end

    def cut_at_with_sep(separator)
      part = @input.partition separator
      @input = part[1] + part[2]
      part[0]
    end

    def cut_at_match_with_start(text, beg_sep, end_sep)
      return ['', '', ''] if text.empty?
      index = matching_separator_index text, beg_sep, end_sep
      el = end_sep.length
      [text[0...index], text[index, el] || '', text[index + el..-1] || '']
    end

    def cut_at_matching(text, beg_sep, end_sep)
      return ['', ''] if text.empty?
      index = matching_separator_index text, beg_sep, end_sep
      bi, bl, el = text.index(beg_sep), beg_sep.length, end_sep.length
      [text[bi + bl...index], text[index + el..-1] || '']
    end

    protected

    def matching_separator_start(text, beg_sep)
      index = text.index beg_sep
      if index
        index + beg_sep.length
      else
        0
      end
    end

    def matching_separator_index(text, beg_sep, end_sep)
      level = 1
      (matching_separator_start(text, beg_sep)...text.length).each do |i|
        if text[i, beg_sep.length] == beg_sep
          level += 1
        elsif text[i, end_sep.length] == end_sep
          level -= 1
        end
        return i if level == 0
      end
      text.length
    end
  end
end
