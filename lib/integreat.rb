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
    @messages = []
    @failures = 0
    @steps_run = 0

    def self.messages
      @messages 
    end

    def self.fail(message)
      @messages << message
      @failures += 1
    end

    def self.failures
      @failures
    end

    def self.step_run
      @steps_run += 1
    end  

    def self.steps_run
      @steps_run
    end
  end  
  
  class Context
    def assert(expected, actual)
      success = expected == actual
      
      unless success
        Integreat::Runner.fail "FAIL in #{caller[0]}: #{expected.to_s} is not #{actual.to_s}"
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
      Integreat::Runner.step_run
      @context.instance_eval(&block)
    end

    yield
    
  end
  
  def Use(*names)
    setup_names = Array(names)
    ensure_context

    print "Using setups: #{names.join(',')}"
    setup_names.each do |name|
      @context.instance_eval(&Integreat::Setups.get(name))
    end
    puts ""
  end
  
  
  yield

  
  if @context
    puts
    puts "-- Summary for #{@description} context --"
    puts "   Steps: #{Integreat::Runner.steps_run}, Failed: #{Integreat::Runner.messages.size}"
    puts ""
    Integreat::Runner.messages.each do |message|
      puts message
    end
  end
    
end