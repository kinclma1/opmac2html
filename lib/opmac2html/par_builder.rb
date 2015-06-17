module Opmac2html
  # Paragraph builder
  class ParBuilder
    ELEM = -> (name, text) { "<#{name}>#{text}</#{name}>" }
    ELEM_WITH_ATT = lambda do |name, attname, attval, text|
      "<#{name} #{attname}=\"#{attval}\">#{text}</#{name}>"
    end
    LINK_SUBS = { '\\%' => '%', '\\#' => '#' }

    def initialize
      @par = []
    end

    def add_word(word)
      @par << word
    end

    def add_code(code)
      @par << ELEM.call('code', code)
    end

    def add_quote(quote)
      @par << "&bdquo;#{quote}&ldquo;"
    end

    def add_em(text)
      @par << ELEM.call('em', text)
    end

    def add_strong(text)
      @par << ELEM.call('strong', text)
    end

    def add_link(address, text = nil)
      address.gsub!(/\\[%#]/) { |c| LINK_SUBS[c] }
      @par << ELEM_WITH_ATT.call('a', 'href', address, text ? text : address)
    end

    def add_verbatim(text)
      @par << ELEM.call('pre', text)
    end

    def to_s
      @par.join
    end
  end
end
