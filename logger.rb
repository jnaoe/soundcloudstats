class Logger

	attr_accessor :LEVELS

	# @LEVELS = {
 #    :debug => 0, 
 #    :info => 1,
 #    :warning => 2,
 #    :error => 3,
 #    :fatal => 4,
 #  }

  def initialize(p = {:level => "DEBUG"})
  	@current_level = p[:level]
    @LEVELS = {
    :debug => 0, 
    :info => 1,
    :warning => 2,
    :error => 3,
    :fatal => 4,
  }
  end

  # Log what is asked
  # Params:
  # +level+:: if level >= config log message
  # +message+:: message to be logged
	def log(level, message)
	  if(level.to_i>=@LEVELS[@current_level].to_i)
	    puts message
	  end
	end
end