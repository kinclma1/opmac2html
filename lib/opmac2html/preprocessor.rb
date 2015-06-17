module Opmac2html
  # A preprocessor for HTML and TeX special characters
  class Preprocessor
    attr_accessor :ttchar
    G_SUBST = { '<' => '&lt;', '>' => '&gt;', '&' => '&amp;' }

    TEXT_SUBST = { '~' => '&nbsp;', '--' => '&ndash;', '---' => '&mdash',
                   '\\,' => '&#8239;', '\\-' => '', '\\TeX{}' => 'TeX',
                   '\\LaTeX{}' => 'LaTeX', '\\csplain{}' => 'CSplain' }

    TS_REG = Regexp.new('~|---?|([^\\\\][%].*)|^%.*|\s%.*|\\\\[,-]|' \
                      '\\\\(La)?TeX\{\}|\\\\csplain\{\}|^\{|\s\{|^\}|\s\}')

    def initialize
      @ttchar = '"'
    end

    def run(text)
      text.gsub(/[<>&]/) { |c| G_SUBST[c] }
    end

    def process_text(text)
      text.gsub(TS_REG) { |c| TEXT_SUBST[c] }
    end
  end
end
