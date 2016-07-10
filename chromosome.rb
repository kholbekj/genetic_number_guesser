class Chromosome
  def initialize(bitstring)
    raise "HOLY SHIT" if bitstring.length.odd?
    @bits = BitString.new(bitstring)
  end

  def to_s
    @bits.to_s
  end

  def human_readable
    @bits.tokenize.join(" ")
  end

  def correct?(target)
    @bits.evaluate == target
  end

  def fitness(target)
    value = @bits.evaluate
    return 0 if value.nil?
    return 1 if target-value == 0
    1.0/(target-value)
  end
end
