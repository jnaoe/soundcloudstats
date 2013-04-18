class Logger
	LEVELS = {
    "DEBUG" => 0, 
    "INFO" => 1,
    "WARNING" => 2,
    "ERROR" => 3,
    "FATAL" => 4
  }

  
	def self.log(level, message)
	  if(LEVELS[level]>=LEVELS[MyConfig::DEFAULT[:debug]].to_i)
	    puts message
	  end
	end
end