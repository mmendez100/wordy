# This ruby demo class translates an integer, from 0 to 999 to to a string
# i.e. 712 will be output as 'seven hundred twelve'
# Usage: Instantiate class Wordy, call .translate() to_s is supported as echoing
# the last string generated with .translate()
#
# Author: M Mendez, 11/25/2015
class Wordy

  
  #### Public Methods ####
  
  # .translate() takes an integer number, returns a string representing the number
  def translate(number)
    # boundary cases that require no work
    return "zero" if number == 0
    raise "Out of range, range is 0 to 999!" if number < 0 || number > 999 
    # otherwise, initialize
    @to_do = number
    @str = ""
    # and convert each power of ten, 10^2, 10^1, 10^0=1
    # ok to expand here for more range
    agent(2)  # 10^2, or third digit, 
    agent(1)  # 10^1, or second digit
    agent(0)  # 10^0, i.e. ones, or single digits
    
    @str # return output
  end # translate
  
  # .to_s() will return the last string translated, if any
  def to_s()
    @str
  end # to_s


  private;

  ### Instance Variables ###

  # @to_do stores the numeric value that is still pending as we convert to words.
  # i.e. for 928, when we say "one hundred twenty..." the value of @to_do should be 8.
  @to_do
  
  # @str accumulates the string representation of the number we are working on
  @str


  #### Tables (Arrays) ####

  # Basis for the strings to build are stored in arrays with the proper offsets 
  # so that each digit to translate works as *the* index to these arrays.
  @@ones = [ 'SENTINEL', 'one', 'two', 'three', 'four', 'five', 
         'six', 'seven', 'eight', 'nine' ]
     
  @@tens = [ 'SENTINEL', 'SENTINEL', 'twenty', 'thirty', 'forty', 'fifty', 
         'sixty', 'seventy', 'eighty', 'ninety' ] 
         
  @@teens = [ 'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen',
        'sixteen', 'seventeen', 'eighteen', 'nineteen' ]

  # This helper class is the 'interface' for lookups to the table below
  class Lookup # note: read/write access needed for the lambdas to work.
    attr_accessor :digit # IN: 0 to 9
    attr_accessor :ten_powered # IN: 1 for position 1, 10 for pos 2, 100 for pos.. 3 etc.
    attr_accessor :to_do # IN: remaining value to convert, still as an integer
    attr_accessor :string # OUT: once called, string representing digit
    attr_accessor :value # OUT: once called, integer representing the string
        
    def initialize (digit, ten_powered, to_do) # syntactic sugar, vs. calling 3 accessors
      @digit, @ten_powered, @to_do = digit, ten_powered, to_do
    end #initialize
  end # Lookup
       
  # @@dict is an array of functions indexed by a digit's decimal position p
  # @@dict[p] returns a function that calculates that digit's partial string & value.
  # The lambdas in this table are invoked via .call(l) where l is of class Lookup
  @@dict = [  
    # for position 0, i.e. 10^0, i.e. ones
    lambda do |l|
      l.value = l.ten_powered * l.digit 
      l.string = @@ones[l.digit]
    end,
    
    # for position 1, i.e. 10^1, i.e. tens
    lambda do |l|
      if l.digit == 1 then # 10 to 19 require special handling!
        l.value = l.to_do
        raise "error in teens!!" unless (10..19).include? l.to_do
        l.string = @@teens[l.value - 10] # an offset of 10 matches our array
      else #20 to 90 are fine!
        l.value = l.ten_powered * l.digit 
        l.string = "#{@@tens[l.digit]} "
      end
    end,
    
    # for position 2, i.e. 10^2, i.e. hundreds    
    lambda do |l|
      l.value = l.ten_powered * l.digit()
      l.string = "#{@@ones[l.digit]} hundred "
    end
    
    # Note: to add further, add lambdas up to n, for converting 10^n 
  ]    

  
  ### Private methods ###

  # .agent() converts a single digit at a position for each specified power of 10,
  # retrieves the appropriate lambda from the tables/array, and calls these
  # functions as it accumulates the result (as text) and subtracts from the
  # integer number we are working on (in @to_do) as it goes.  
  def agent(power)
  
    # each digit d, at position power, in a decimal system signifies d*10^power, 
    ten_powered = 10 ** power # value of d = 1 at this position
    return "" unless @to_do >= ten_powered # no work if this digit exceeds our number!
    
    digit = @to_do / ten_powered # find values of d for d in [2..9]
    l = Lookup.new(digit, ten_powered, @to_do) 
    @@dict[power].call(l) # <<< The magic is here >>>
    @str << l.string
    @to_do -= l.value
  end #agent  

end #class Wordy



########### Our 'main' so that we can drive this with a file ############


File.open(ARGV.first, "r") do |f|
  f.each_line do |l|

    # read each line 
    print "in:  " << l.strip!

    # now let's do the actual work
    w = Wordy.new()
    puts ", out: "  << w.translate(l.to_i)
      
  end #each_line
end #File.open


30.times { print("_") }
puts
puts " Trying exceptions:"
w = Wordy.new()
begin 
  w.translate(-12)
rescue
puts " Expected! Caught -12 as input: " + $!.to_s
end

begin 
  w.translate(1000)
rescue
puts " Expected! Caught 1000 as invalid input: " + $!.to_s
end

30.times { print("_") }
puts
