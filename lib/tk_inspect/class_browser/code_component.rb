require 'active_support/all'
require 'rouge'

module TkInspect
  module ClassBrowser
    TOKEN_TAGS = {
      'Rouge::Token::Tokens::Comment::Single' => :comment,
      'Rouge::Token::Tokens::Keyword' => :keyword,
      'Rouge::Token::Tokens::Name::Class' => :constant,
      'Rouge::Token::Tokens::Name::Constant' => :constant,
      'Rouge::Token::Tokens::Name::Function' => :method,
      'Rouge::Token::Tokens::Str::Double' => :string,
      'Rouge::Token::Tokens::Str::Single' => :string,
      'Rouge::Token::Tokens::Str::Interpol' => :string,
      'Rouge::Token::Tokens::Str::Symbol' => :symbol,
      'Rouge::Token::Tokens::Str::Heredoc' => :string,
      'Rouge::Token::Tokens::Name::Variable::Instance' => :ivar
    }

    TAG_STYLES = {
      string: { foreground: 'red' },
      comment: { foreground: 'gray' },
      keyword: { foreground: 'blue' },
      constant: { foreground: 'green' },
      symbol: { foreground: 'purple' },
      method: { foreground: 'brown' },
      ivar: { foreground: 'brown' }
    }

    class CodeComponent < TkComponent::Base
      attr_accessor :code
      attr_accessor :filename
      attr_accessor :method_name
      attr_accessor :method_line

      def render(p, parent_component)
        p.vframe(padding: "0 0 0 0", sticky: 'nsew', x_flex: 1, y_flex: 1) do |vf|
          @filename_label = vf.label(font: 'TkSmallCaptionFont', sticky: 'ewn', x_flex: 1, y_flex: 0)
          @code_text = vf.text(sticky: 'nswe', x_flex: 1, y_flex: 1, wrap: 'none', scrollers: 'xy')
        end
      end

      def component_did_build
        TAG_STYLES.each do |k,v|
          @code_text.native_item.tag_configure(k.to_s, v)
        end
      end

      def update
        if @code && @method_line
          highlight_code(@code_text.native_item, @code, @filename)
          @code_text.tk_item.select_range("#{@method_line}.0", "#{@method_line}.end")
          @code_text.native_item.see("#{@method_line}.0")
          @filename_label.native_item.text(@filename)
        else
          @filename_label.native_item.text('')
          @code_text.tk_item.value = "Source code not available for #{@method_name}"
        end
      end

      @@lexers = {}

      def highlight_code(native_item, code, filename)
        lexer = (@@lexers[filename] ||= Rouge::Lexers::Ruby.lex(code))
        native_item.replace('1.0', 'end', '')
        lexer.each do |token, chunk|
          tag = TOKEN_TAGS[token.to_s]
          native_item.insert('end', chunk, tag.to_s)
        end
      end
    end
  end
end
