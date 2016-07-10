require 'pry'
class Population
  CROSSOVER_RATE = 0.7
  MUTATION_RATE = 0.01
  BITLENGTH = 80

  def self.iterate(population, n)
    n.times.each do |i|
      puts "Iteration no. #{i}"
      puts "Average fitness: #{population.average_fitness}"
      puts "Solution: not found" unless population.solution
      puts "Solution found : #{population.solution.human_readable}" if population.solution
      if population.solution
        break
      end
      population = population.evolve
    end
  end

  def initialize(target, n, populations = [])
    raise ArgumentError if populations.length > 0 && populations.length != n
    raise ArgumentError if n.odd?
    @target = target
    @population = populations
    @n = n
    unless @population.length > 0
      n.times do
        @population << Chromosome.new("%0#{BITLENGTH}b" % (rand * 2**BITLENGTH).to_i)
      end
    end
  end

  def solution
    @population.each do |c|
      return c if c.correct?(@target)
    end
    nil
  end

  def evolve
    @new_population = []
    (@n/2).times do
      @new_population << create_new_chromosomes
    end
    Population.new(@target, @n, @new_population.flatten)
  end

  def create_new_chromosomes
    c1, c2 = pick_two_chromosomes
    breed(c1,c2)
  end

  def pick_two_chromosomes
    [pick_chromosome, pick_chromosome]
  end

  def pick_chromosome
    selection = rand * total_fitness

    total = 0
    @population.each_with_index do |c, i|
      total += c.fitness(@target)
      return c if total > selection || i == @population.length - 1
    end
  end

  def fitness_values
    @fitness_values ||= @population.map { |c| c.fitness(@target) }
  end

  def total_fitness
    fitness_values.reduce {|sum, v| sum + v }
  end

  def max_fitness
    fitness_values.max
  end

  def average_fitness
    total_fitness.to_f / @population.length.to_f
  end

  def breed(c1, c2)
    # Apply crossover

    if rand < CROSSOVER_RATE
      index = rand(BITLENGTH-1)
      c1_genes = c1.to_s.slice(0..index) + c2.to_s.slice(index+1..-1)
      c2_genes = c2.to_s.slice(0..index) + c1.to_s.slice(index+1..-1)
    end

    c1_genes ||= c1.to_s
    c2_genes ||= c2.to_s

    # mutate
    c1_genes = flip(c1_genes)
    c2_genes = flip(c2_genes)

    [Chromosome.new(c1_genes), Chromosome.new(c2_genes)]
  end

  def flip(genes)
    new_genes = genes.chars.map do |c|
      if rand > MUTATION_RATE
        if c == "1"
          "0"
        else
          "1"
        end
      else
        c
      end
    end
    new_genes.join
  end
end

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

# User interaction

puts "Welcome to the genetic number guesser!"
print "Input target: "
x = gets.chomp.to_i
p = Population.new(x, 100)
Population.iterate(p, 400)
puts "Done"
