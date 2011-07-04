
module Integreat
     
  module Stored
    @storeds = {}
    
    def self.store(name, &block)
      @storeds[name] = block
    end
  
    def self.get(name)
      if @storeds[name]
        @storeds[name]
      else
        raise "Nothing stored with #{name}"
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
      puts red(bold("\nAssertation failed"))
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
        Integreat::Runner.fail! "In #{caller[0]}\nStep: #{Integreat::Runner.current_step}\nExpected: #{expected.to_s}\n  Actual: #{actual.to_s}"
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
  end
  
    
   def Step(name, &block)
     ensure_context
     
     puts " Step: #{name}"
     @runner.run_step(name)
     @context.instance_eval(&block)
   end
  
  def Store(name, &block)
    Integreat::Stored.store(name, &block)
    puts yellow("Stored block with name: #{bold(name)}")
  end
  
  def Test(name)
    puts "\nTest: #{bold(name)}"

    yield
  end
  
  def Perform(*names)
    Array(names).each do |name|
      stored_step = Integreat::Stored.get(name)
      stored_step.call
    end
  end
  
  
  yield

  if @context
    puts green("\n\nIntegreat '#{@description}' ended")
    puts green(horizontal_line)
    puts green("  Steps: #{@runner.steps_run}, Assertions: #{@runner.assertions}")
  end
    
end