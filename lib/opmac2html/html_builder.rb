module Opmac2html
  # Builder for the resulting document
  class HtmlBuilder
    attr_reader :anchors

    MATH_JAX = '<meta charset="UTF-8">
  <script type="text/x-mathjax-config">
  MathJax.Hub.Config({tex2jax: {inlineMath: [[\'$\',\'$\']]}});
  </script>
  <script type="text/javascript"
  src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?' \
    'config=TeX-AMS-MML_HTMLorMML">
  </script>'

    TAIL = "</body>\n</html>\n"

    def initialize
      @document = []
      @fnotes = ListBuilder.new 'n'
      @fnote_count = 0
      @anchors = []
    end

    def head(title)
      "<!DOCTYPE html>\n<head>\n<title>#{title}</title>\n" \
        "#{MATH_JAX}\n</head>\n<body>\n"
    end

    def elem(name, text)
      "<#{name}>#{text}</#{name.partition(' ')[0]}>\n\n"
    end

    def header(number, title)
      elem "h#{number}", title
    end

    def add_title(title)
      @title ||= title[1]
      @document << [title[0], title[1]]
    end

    def add_par(text)
      @document << ['p', text]
    end

    def add_verbatim(text)
      @document << ['pre', text]
    end

    def add_table(text)
      @document << ['table', text]
    end

    def add_list(text)
      @document << [nil, text]
    end

    def add_fnote(text)
      @fnote_count += 1
      @fnotes.add_item(text, @fnote_count.to_s)
      @fnote_count
    end

    def add_img(filename)
      elem = "<img src=\"#{filename}\" " \
           "alt=\"#{filename[0...filename.rindex('.')]}\">\n"
      @document << [nil, elem]
    end

    def add_figure(filename, caption)
      img = "<img src=\"#{filename}\" " \
          "alt=\"#{caption}\">"
      cap = "<figcaption>#{caption}</figcaption>"
      @document << ['figure', img + "\n" + cap]
    end

    def add_anchor(id)
      @anchors << id
      @document << ["span id=\"#{id}\"", '']
    end

    def header?(element)
      element[0].is_a? Numeric
    end

    def doc_to_s
      @document.map do |e|
        if header?(e)
          header(*e)
        elsif !e[0]
          e[1]
        else
          elem(*e)
        end
      end.join + "<hr>\n" + @fnotes.to_s
    end

    def to_s
      head(@title) + doc_to_s + TAIL
    end
  end
end
