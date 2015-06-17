module Opmac2html
  # Mixin providing parsing of paragraphs and other text elements
  module ParagraphParser
    def parse_par
      slice = cut_at_with_sep(/\n\n|\n\\begtt|\n\\.*skip|\\par[\\ ]/)
      @builder.add_par(parse_par_macros(slice.gsub(/^%.*/, '')))
    end

    def parse_par_macros(text)
      par_builder = ParBuilder.new
      until text.empty?
        index = text.index(/#{@ttchar}|\\\w|\{|\$/) || text.length
        par_builder.add_word @preproc.process_text text[0...index]
        text = par_special text[index..-1], par_builder
      end
      par_builder.to_s
    end

    def par_special(text, par_builder)
      case text[0]
      when @ttchar
        parse_code text, par_builder
      when '$'
        parse_math text, par_builder
      else
        par_macro text, par_builder
      end
    end

    def dump_all(text)
      err text unless text.empty?
      ''
    end

    def dump_to_space(text)
      part = text.partition(/\s/)
      err part[0]
      part[2]
    end

    def parse_code(text, par_builder)
      part = text[1..-1].partition(@ttchar)
      par_builder.add_code part[0]
      part[2]
    end

    def parse_math(text, par_builder)
      separator = text.start_with?('$$') ? '$$' : '$'
      part = text[separator.length..-1].partition(separator)
      par_builder.add_word separator + part[0] + part[1]
      part[2]
    end

    def par_macro(text, par_builder)
      if %w(\\url \\ulink \\fnote \\ref \\pgref).any? { |p| text.start_with? p }
        parse_clickable text, par_builder
      elsif text.start_with? '\\begtt'
        par_verbatim text, par_builder
      elsif text.start_with? '\\dots'
        par_builder.add_word '&hellip;'
        text.partition('s')[2]
      elsif text.index(/(\\\w+)?\{/) == 0
        part = cut_at_match_with_start(text, '{', '}')
        if %w(\\TeX \\LaTeX \\csplain).any? { |p| text.start_with? p }
          par_builder.add_word(@preproc.process_text(part[0] + part[1]))
        else
          parse_format_block part[0], par_builder
        end
        part[2]
      elsif %w(\\it \\em \\bf \\tt).any? { |p| text.start_with? p }
        parse_format_block text, par_builder
        ''
      elsif text.index(/\\\w*\s/) == 0
        dump_to_space text
      else
        dump_all text
      end
    end

    def parse_clickable(text, par_builder)
      if %w(\\url \\ulink).any? { |p| text.start_with? p }
        parse_link text, par_builder
      elsif text.start_with? '\\fnote'
        parse_fnote text, par_builder
      elsif %w(\\ref \\pgref).any? { |p| text.start_with? p }
        part = cut_at_matching(text, '[', ']')
        par_builder.add_link("##{part[0]}", part[0])
        part[1]
      end
    end

    def par_verbatim(text, par_builder)
      part = cut_at_matching(text, '\\begtt', '\\endtt')
      par_builder.add_verbatim(part[0])
      part[1]
    end

    def parse_link(text, par_builder)
      part = text.partition('}')
      if text.start_with? '\\url'
        parse_url part[0], par_builder
      else
        parse_ulink part[0], par_builder
      end
      part[2]
    end

    def parse_url(text, par_builder)
      par_builder.add_link(text.partition('{')[2])
    end

    def parse_ulink(text, par_builder)
      add = text[text.index('[') + 1...text.index(']')]
      txt = text[text.index('{') + 1..-1]
      par_builder.add_link(add, txt)
    end

    def parse_format_block(text, par_builder)
      t = parse_par_macros(text[4..-1]).lstrip if text[4]
      if text.start_with? '\\uv{'
        par_builder.add_quote t
      else
        parse_format text, par_builder, t
      end
    end

    def parse_format(text, par_builder, t)
      case text[0..3]
      when '\\it ', '\\em ', '{\\it', '{\\em'
        par_builder.add_em t
      when '\\bf ', '{\\bf'
        par_builder.add_strong t
      when '\\tt ', '{\\tt'
        par_builder.add_code t
      else
        extract_from_braces text, par_builder
      end
    end

    def extract_from_braces(text, par_builder)
      if text.index(/\{\\\w/) == 0
        par_special dump_to_space(text), par_builder
      elsif text.start_with? '{'
        par_special cut_at_matching(text, '{', '}')[0], par_builder
      else
        dump_all text
      end
    end

    def parse_fnote(text, par_builder)
      part = cut_at_match_with_start(text, '{', '}')
      fnote = parse_par_macros(part[0][part[0].index('{') + 1..-1])
      num = @builder.add_fnote(fnote)
      par_builder.add_link("##{num}", "<sup>#{num}</sup>")
      part[2]
    end
  end
end
