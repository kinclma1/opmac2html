module Opmac2html
  # Builder for lists (items)
  class ListBuilder
    def initialize(style)
      @list = []
      @list_stack = []
      begitems style
    end

    def get_type(style)
      case style
      when 'n', 'N'
        'ol type="1"'
      when 'i', 'I', 'a', 'A'
        "ol type=\"#{style}\""
      else
        'ul'
      end
    end

    def start_tag(text)
      @list << "<#{text}>\n"
      @list_stack << text.partition(' ')[0]
    end

    def end_tag
      @list << "</#{@list_stack.pop}>\n"
    end

    def begitems(style)
      start_tag get_type style
      @first = true
    end

    def enditems
      2.times { end_tag }
    end

    def add_item(text, id = nil)
      if @first
        @first = false
      else
        end_tag
      end
      start_tag(id ? "li id=\"#{id}\"" : 'li')
      @list << text
    end

    def to_s
      enditems until @list_stack.empty?
      @list.join
    end
  end
end
