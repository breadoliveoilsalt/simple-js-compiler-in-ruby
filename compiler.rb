#!/usr/bin/env ruby

# Demo'd in src file
# def f ()
#  1
# end

# def f(x,y) g(x) end
# def f(x,y) g(x,y,1) end
# def f(x, y) add(x, y) end
# def f(x, y) add(100, add(10, add(x, y))) end

class Tokenizer
  # Remember: ordering is important
  TOKEN_TYPES = [
    [:def, /\bdef\b/],
    [:end, /\bend\b/],
    [:identifier, /\b[a-zA-Z]+\b/],
    [:integer, /\b[0-9]+\b/],
    [:oparen, /\(/],
    [:cparen, /\)/],
    [:comma, /,/]
  ]

  def initialize(code)
    @code = code
  end

  def tokenize
    tokens = []
    until @code.empty?
      tokens << tokenize_one_token
      @code = @code.strip
    end
    tokens
  end

  def tokenize_one_token
    TOKEN_TYPES.each do |type, regex|
      regex = /\A(#{regex})/
      next unless @code =~ regex

      # 1 is whatever is in the first capture group
      value = ::Regexp.last_match(1)
      @code = @code[value.length..-1]
      return Token.new(type, value)
    end
    raise "Couldn't match token on #{@code.inspect}"
  end
end

class Parser
  def initialize(tokens)
    @tokens = tokens
  end

  def parse
    parse_def
  end

  def parse_def
    consume(:def)
    name = consume(:identifier).value
    arg_names = parse_arg_names
    body = parse_expr
    consume(:end)
    DefNode.new(name, arg_names, body)
  end

  def parse_arg_names
    consume(:oparen)

    arg_names = []

    if peek(:identifier)
      arg_names << consume(:identifier).value
      while peek(:comma)
        consume(:comma)
        arg_names << consume(:identifier).value
      end
    end
    consume(:cparen)

    arg_names
  end

  def parse_expr
    if peek(:integer)
      parse_integer
    elsif peek(:identifier) && peek(:oparen, 1)
      parse_call
    else
      parse_val_ref
    end
  end

  def parse_integer
    IntegerNode.new(consume(:integer).value.to_i)
  end

  def parse_call
    name = consume(:identifier).value
    arg_exprs = parse_arg_exprs
    CallNode.new(name, arg_exprs)
  end

  def parse_arg_exprs
    arg_exprs = []

    consume(:oparen)

    unless peek(:cparen)
      arg_exprs << parse_expr
      while peek(:comma)
        consume(:comma)
        arg_exprs << parse_expr
      end
    end

    consume(:cparen)

    arg_exprs
  end

  def parse_val_ref
    VarRefNode.new(consume(:identifier).value)
  end

  def consume(expected_type)
    token = @tokens.shift
    if token.type == expected_type
      token
    else
      raise "Expected token type #{expected_type.inspect} but got #{token.type.inspect}"
    end
  end

  def peek(expected_type, offset = 0)
    @tokens.fetch(offset).type == expected_type
  end
end

Token = Struct.new(:type, :value)

DefNode = Struct.new(:name, :arg_names, :body)
IntegerNode = Struct.new(:value)
CallNode = Struct.new(:name, :arg_exprs)
VarRefNode = Struct.new(:value)

# Pay attention to the directory from which you are executing the file.
# This will affect the relative pathing below.
tokens = Tokenizer.new(File.read('./compiler-test-file.src')).tokenize

# Uncomment to see the tokens
# p tokens.map(&:inspect).join("\n")

tree = Parser.new(tokens).parse

# Uncomment to see the tree
# p tree

class Generator
  def generate(node)
    case node
      # with ruby, it's ok to `when` on the class even though we are `case`-ing on the
    when DefNode
      format('function %s(%s) { return %s };', node.name, node.arg_names.join(','), generate(node.body))
    when CallNode
      format('%s(%s)', node.name, node.arg_exprs.map { |expr| generate(expr) }.join(','))
    when VarRefNode
      node.value
    when IntegerNode
      node.value
    else
      raise "Unexpected node type: #{node.class}"
    end
  end
end

generated = Generator.new.generate(tree)

RUNTIME = 'function add(x, y) { return x + y };'

TEST = 'console.log(f(1,2));'
puts [RUNTIME, generated, TEST].join("\n")

