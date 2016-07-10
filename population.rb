class Population


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

  def initialize(target, n, opts = {}, populations = [])
    raise ArgumentError if populations.length > 0 && populations.length != n
    raise ArgumentError if n.odd?
    @opts = opts
    @crossover_rate = @opts[:crossover_rate] || 0.7
    @mutation_rate = @opts[:mutation_rate] || 0.01
    @bitlength = @opts[:bitlength] || 80
    @target = target
    @population = populations
    @n = n
    unless @population.length > 0
      n.times do
        @population << Chromosome.new("%0#{@bitlength}b" % (rand * 2**@bitlength).to_i)
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
    Population.new(@target, @n, @opts, @new_population.flatten)
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

    if rand < @crossover_rate
      index = rand(@bitlength-1)
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
      if rand > @mutation_rate
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
