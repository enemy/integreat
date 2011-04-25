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

  module Runner
    @all_messages = []

    def self.init
      @messages = []
      @failures = 0
      @steps_run = 0
      @assertions = 0
    end
    
    def self.messages
      @messages 
    end
    
    def self.all_messages
      @all_messages
    end

    def self.fail(message)
      @messages << message
      @all_messages << message
      
      @failures += 1
    end

    def self.failures
      @failures
    end

    def self.run_step(name)
      @current_step = name
      @steps_run += 1
    end  

    def self.steps_run
      @steps_run
    end
    
    def self.assert
      @assertions += 1
    end
    
    def self.assertions
      @assertions
    end
    
    def self.current_step
      @current_step
    end
  end  
  
  class Context
    def assert(expected, actual)
      Integreat::Runner.assert
      
      success = expected == actual
      
      unless success
        Integreat::Runner.fail "Assertation FAILED in #{caller[0]}, step #{Integreat::Runner.current_step} -- expected: #{expected.to_s} actual: #{actual.to_s}"
      end
    end

  end
end

def Integreat(description = nil, &block)  
  @description = description
  @context = nil
  
  def ensure_context
    unless @context
      puts "\n\nContext for #{@description}"
      @context = Integreat::Context.new
      puts "-"*80
    end   
  end
  
  def Setup(name, &block)
    Integreat::Setups.store(name, &block)
  end
  
  def Test(name)
    ensure_context

    puts "\nRunning test: #{name}"
        
    def Step(name, &block)
      puts " Step: #{name}"
      Integreat::Runner.run_step(name)
      @context.instance_eval(&block)
    end

    yield
    
  end
  
  def Use(*names)
    setup_names = Array(names)
    ensure_context

    puts ""
    print "Using setups: #{names.join(',')}"
    setup_names.each do |name|
      @context.instance_eval(&Integreat::Setups.get(name))
    end
    puts ""
  end
  
  Integreat::Runner.init
  
  yield

  
  if @context
    puts
    puts "-- Summary for #{@description} context --"
    puts "   Steps: #{Integreat::Runner.steps_run}, Assertions: #{Integreat::Runner.assertions}, Failed: #{Integreat::Runner.messages.size}"
    puts ""
    Integreat::Runner.messages.each do |message|
      puts message
    end
    
    puts ""
    puts "All failures"
    puts "-"*80
    Integreat::Runner.all_messages.each do |message|
      puts message
    end
    
  end
    
end