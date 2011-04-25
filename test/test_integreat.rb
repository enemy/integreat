require 'helper'

class TestIntegreat < Test::Unit::TestCase


  should "Test with one megatest" do

    Integreat "setups" do
      
      Setup "lolcat" do
        @cat = "lol"
      end
      
    end
    
    Integreat "Kissat koiria asdsfkokfdfdl" do
      
      Use "lolcat"
      
      Test "Cat is lol" do
        
        Step "lol is to be found" do
          assert(@cat, "lol")
        end
      end
      
    end
    
    Integreat "Different context" do
    
      Test "Cat is not lol" do
        
        Step "not lol" do
          assert(nil, @cat)
        end
      end
    end
    
    assert(true)
  end
end
