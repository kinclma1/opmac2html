module Opmac2html
  # Mixin providing parsing of macro calls
  module MacroParser
    TITLES = %w(\\tit \\chap \\sec \\secc)
    IN_PAR_MACROS = %w(\\TeX \\LaTeX \\csplain \\url \\ulink)

    def parse_macro
      title_index = TITLES.index { |t| @input.start_with? t }
      if title_index
        parse_title title_index
      elsif @input.start_with? '\\begtt'
        parse_verbatim
      elsif @input.start_with? '\\verbinput'
        verbinput
      elsif @input.start_with? '\\begitems'
        parse_list
      elsif @input.start_with? '\\activettchar'
        parse_ttchar
      elsif IN_PAR_MACROS.any? { |m| @input.start_with? m }
        parse_par
      else
        parse_other
      end
    end

    def parse_title(index)
      @min_index ||= index
      title_text = @preproc.process_text(cut_at("\n\n").partition(' ')[2])
      @builder.add_title([title_level(index), title_text])
    end

    def title_level(index)
      index + 1 - @min_index
    end

    def parse_verbatim
      cut_at "\n"
      @builder.add_verbatim cut_at '\\endtt'
    end

    def verbinput
      beg_line, end_line = *verbinput_range
      file = File.open(cut_at("\n").strip, 'r') { |input| input.readlines }
      @builder.add_verbatim(file[beg_line - 1..end_line - 1].join)
    end

    def verbinput_range
      cut_at '('
      beg_line = cut_at('-').to_i
      end_line = cut_at(')').to_i
      end_line = -1 if end_line == 0
      [beg_line, end_line]
    end

    def parse_list
      list = parse_list_items
      builder = ListBuilder.new(list[0].partition('\style ')[2][0])
      list[1..-1].each do |line|
        process_list_item line, builder
      end
      @builder.add_list builder.to_s
    end

    def parse_list_items
      list, @input = *(cut_at_matching(@input, '\\begitems', '\\enditems'))
      list.split("\n").reduce([]) do |a, e|
        if /\*|\\begitems|\\enditems/.match(e) || a.empty?
          a << e
        else
          a[-1].concat "\n" + e
          a
        end
      end
    end

    def process_list_item(line, builder)
      if line.include? '\\begitems'
        builder.begitems line.partition('\style ')[2][0]
      elsif line.include? '\\enditems'
        builder.enditems
      else
        builder.add_item parse_par_macros(line.partition(/\*\s/)[2])
      end
    end

    def parse_ttchar
      cut_at 'r'
      @preproc.ttchar = @ttchar = @input[0]
      @input = @input[1..-1]
    end

    def parse_other
      part_line = @input.partition("\n")
      if %w(\\table \\caption/t).any? { |s| part_line[0].include? s }
        parse_table
      elsif part_line[0].include?('\\inspic')
        parse_image
      elsif part_line[0].include?('\\def')
        part = cut_at_match_with_start(@input, '{', '}')
        err part[0] + part[1]
        @input = part[2]
      elsif part_line[0].start_with?('\\noindent')
        err cut_at(/\s/)
      elsif part_line[0].start_with? '\\label'
        parse_label
      elsif part_line[0].start_with? '\\centerline'
        text = cut_at_matching(part_line[0], '{', '}')[0]
        @builder.add_par parse_par_macros text
        @input = part_line[2]
      else
        err part_line[0]
        @input = part_line[2]
      end
    end

    def parse_table
      tb = TableBuilder.new
      parse_table_caption(@input.partition("\n")[0], tb)

      build_table tb

      parse_table_caption(cut_at("\n\n"), tb)

      @builder.add_table tb.to_s
    end

    def parse_table_caption(line, tb)
      return unless line.include? '\\caption/t'
      caption = line.partition('\\caption/t ')[2].partition("\n")[0]
      tb.add_caption(parse_par_macros(caption))
    end

    def parse_table_cells
      text = @input.partition(/\\table\s*\{[^\{]*/)[2]
      part = cut_at_matching(text, '{', '}')
      @input = part[1]

      part[0].split(/\\cr.*/).map { |r| r.split(/\s&amp;\s/).map(&:strip) }
        .reject(&:empty?)
    end

    def build_table(tb)
      parse_table_cells.each do |row|
        tb.add_row(row.map do |cell|
                     if cell.start_with? '\\multispan'
                       cellpart = cell.partition(/\d+/)
                       cellpart[0] + cellpart[1] + parse_par_macros(cellpart[2])
                     else
                       parse_par_macros cell
                     end
                   end)
      end
    end

    def parse_image
      img = cut_at_matching(@input, '\\inspic ', "\n")[0]
            .partition(/ [\n\}]/)[0]
      part = cut_at("\n\n")
      if part.include? '\\label'
        @builder.add_anchor(cut_at_matching(part, '\\label[', ']')[0])
      end
      if part.include? '\\caption/f'
        @builder.add_figure img, cut_at_matching(
          part, '\\caption/f ', "\n\n")[0]
      else
        @builder.add_img img
      end
    end

    def parse_label
      part = cut_at_matching @input, '[', ']'
      @builder.add_anchor part[0]
      @input = part[1]
    end
  end
end
