require './bitstring'
require './chromosome'
require './population'

# Parameters. Tweak ahead.
OPTIONS = {
  bitlength: 80, # how many bits per chromosome. Must be divisable with 4.
  crossover_rate: 0.7, # how often chromosomes will swap part of genes
  mutation_rate: 0.001 # how big chance each bit has to flip in each new chromosome
}


# User interaction

puts "Welcome to the genetic number guesser!"
print "Input target: "
x = gets.chomp.to_i
p = Population.new(x, 100, OPTIONS)
Population.iterate(p, 400)
puts "Done"
