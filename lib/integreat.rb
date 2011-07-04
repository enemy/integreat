
module Integreat
     
  module Setups
    @setups = {}
    
    def self.store(name, &block)
      @setups[name] = block
    end
  
    def self.get(name)
      if @setups[name]
        @setups[name]
      else
        raise "No setup stored with #{name}"
      end
    end
  end

  class Runner
    require 'term/ansicolor'
    include Term::ANSIColor
    
    attr_reader :assertions, :current_step, :steps_run
    
    
    def initialize
      @steps_run = 0
      @assertions = 0
      @@runner = self
    end

    
    def fail!(message)
      puts red(bold("Assertation failed"))
      puts message

      exit 1
    end

    def run_step(name)
      @current_step = name
      @steps_run += 1
    end  
    
    def assert
      @assertions += 1
    end
    
    def self.assert
      @@runner.assert
    end
    
    def self.current_step
      @@runner.current_step
    end
    
    def self.fail!(message)
      @@runner.fail!(message)
    end
    
  end  

  
  class Context
    def assert(expected, actual)
      Integreat::Runner.assert
      
      success = expected == actual

      unless success
        Integreat::Runner.fail! "Assertation FAILED in #{caller[0]}, step #{Integreat::Runner.current_step} -- expected: #{expected.to_s} actual: #{actual.to_s}"
      end
    end

  end
end



def Integreat(description = "unnamed", &block)  
  require 'term/ansicolor'
  extend Term::ANSIColor
  
  def horizontal_line(length = 80)
    puts "-"*length
  end
  
  @description = description
  
  
  puts blue(bold("\n\nIntegreat '#{@description}' started"))
  horizontal_line
  
  
  @runner = Integreat::Runner.new
  
  

  def ensure_context
    return if @context

    @context = Integreat::Context.new
    puts " + Created context for #{@description}"
  end
  
    
   def Step(name, &block)
     ensure_context
     
     puts " Step: #{name}"
     @runner.run_step(name)
     @context.instance_eval(&block)
   end
  
  def Store(name, &block)
    Integreat::Setups.store(name, &block)
    puts yellow("Stored setup: #{bold(name)}")
  end
  
  def Test(name)
    puts "\nRunning test: #{name}"
    horizontal_line

    yield
    
  end
  
  def Perform(*names)
    setup_names = Array(names)

    puts "\nUsing setups: #{names.join(',')}"

    setup_names.each do |name|
      stored_setup = Integreat::Setups.get(name)
      stored_setup.call
    end
    puts ""
  end
  
  
  yield

  if @context
    puts
    puts "-- Summary for #{@description} context --"
    puts "   Steps: #{@runner.steps_run}, Assertions: #{@runner.assertions}"
    puts ""
  end
    
end