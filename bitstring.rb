class BitString
  BITMAP = {
    '0000' => 0,
    '0001' => 1,
    '0010' => 2,
    '0011' => 3,
    '0100' => 4,
    '0101' => 5,
    '0110' => 6,
    '0111' => 7,
    '1000' => 8,
    '1001' => 9,
    '1010' => "+",
    '1011' => "-",
    '1100' => "*",
    '1101' => "/",
    '1110' => "",
    '1111' => "",
  }

  def initialize(bits)
    @bits = bits.freeze
    @stream = @bits.dup
  end

  def to_s
    tokenize.join(" ")
  end

  def to_s
    @bits
  end

  def evaluate
    tokens = tokenize
    if tokens.length > 2 && tokens.length.odd?
      sum = eval(tokens.shift(3).join)
      while tokens.length > 1
        sum = eval(sum.to_s + tokens.shift(2).join)
      end
      sum
    end
  rescue ZeroDivisionError
    0
  end

  def tokenize
    tokens = []
    until @stream.empty?
      token = decode(pop)
      if token.is_a?(Fixnum) && (tokens.empty? || operator?(tokens.last))
        token = token.to_s
        tokens << token
      elsif operator?(token) && !operator?(tokens.last)
        tokens << token
      end
    end
    @stream = @bits.dup
    operator_trim(tokens)
  end

  def pop
    @stream.slice!(0..3)
  end

  def push(str)
    @stream = str + @stream
  end

  def peek
    c = pop
    push c
    c
  end

  def decode(bits)
    BITMAP[bits]
  end

  def operator?(token)
    %w(+ - / % *).include? token
  end

  def empty?
    @stream = ""
  end

  def operator_trim(orig_tokens)
    tokens = orig_tokens.dup
    while operator?(tokens.first)
      tokens.shift
    end
    while operator?(tokens.last)
      tokens.pop
    end
    tokens
  end
end
