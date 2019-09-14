require 'parser/current'

class CodeUpdater
  def initialize(source_dir, executed_line, meta: {})
    @source_dir = source_dir
    result = /(.*?):(\d+)/.match(executed_line)
    @filename, @lineno = result[1], result[2].to_i
    @meta = meta

    @code = File.read("#{@source_dir}/#{@filename}")
  end

  def execute
    ast = Parser::CurrentRuby.parse(@code)
    buffer = Parser::Source::Buffer.new('(code_updater)')
    buffer.source = @code
    rewriter = MakeRewriter.new(@lineno, meta: @meta)
    # Rewrite the AST, returns a String with the new form.
    puts rewriter.rewrite(buffer, ast)
  end

  class MakeRewriter < Parser::TreeRewriter
    def initialize(lineno, meta:)
      @lineno = lineno
      @meta = meta
    end

    def on_send(node)
      return if node.children[1] != :make
      return if node.loc.selector.line != @lineno
      replace_make(node)
    end

    def replace_make(node)
      new_code = "FactoryBot.build(:#{@meta[:name]})"
      replace(node.location.selector, new_code)
    end
  end
end
