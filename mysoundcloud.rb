require 'soundcloud'
require './myconfig'

#!/usr/bin/env ruby
class MySoundcloud
  attr_accessor :client
  attr_accessor :innerFollowings
  attr_accessor :me
	
  # Create 
  def initialize()
    log('DEBUG', 'info()')
    @innerFollowings = Array.new
  end

  def getLogInfo()
    log('DEBUG', 'getLofInfo()')
    print "username : "
    @username = STDIN.gets
    @username.chop!
    print "password : "
    @password = STDIN.gets
    @password.chop!
  end

  def connect()
    log('DEBUG', 'connect()')
    begin
      @client = Soundcloud.new({
        :client_id => MyConfig::DEFAULT[:client_id],
        :client_secret => MyConfig::DEFAULT[:client_secret],
        :username => @username,
        :password => @password
        })
    rescue
      puts "Something went wrong please enter your log info again"
      getLogInfo
      retry
    end
  end

  def putFollowings(followings)
    if(followings.respond_to?("each"))
      followings.each do |following|
        putFollowing(following)
      end
    end
  end

  def putFollowing(following)
  #   log('DEBUG', 'putFollowing()')
    index = @innerFollowings.find_index {|h| h[:id] == following.id}
    if(index != nil)
      @innerFollowings[index][:counter] += 1
      # log("DEBUG", @innerFollowings[innerFollowing.id]['username']+"+1")
    else
      @innerFollowings.push({:id=>following.id, :username => following.username, :counter => 1})
      # log('DEBUG', "####"+hash_to_s(@innerFollowings))
      # log('DEBUG', @innerFollowings[innerFollowing.id])
    end
  end

  def getFollowings(user_id = @me.id)
    # log('DEBUG', 'getFollowings()')
    followings = @client.get("/users/#{user_id}/followings")
    putFollowings(followings)
  end

  def getMe()
    log('DEBUG', 'getMe()')
    @me = @client.get('/me')
    puts "Your id is #{@me.id}"
  end

  def orderInners()
    log('DEBUG', 'orderInners()')
    @innerFollowings.sort_by! { |v| v[:counter] }
  end

  def displayArray(hashs = @innerFollowings, order = false)
    is_first = true
    hashs.each do |h|
      raw = ""
      if(is_first)
        raw = h.keys.join("\t|\t")
      else
        raw = h.values.join("\t|\t")
      end
      puts raw
      if(is_first)
        is_first = false
        redo
      end
    end
  end
end



	
def log(level, message)
  levels = {
    "DEBUG" => 0, 
    "INFO" => 1,
    "WARNING" => 2,
    "ERROR" => 3,
    "FATAL" => 4
  }
  if(levels[level]>=levels[MyConfig::DEFAULT[:debug]].to_i)
    puts message
  end
end

def hash_to_s(hashs)
  output = ""
  if(hashs.respond_to?("each_key"))
    hashs.each_key do |hash_key|
      output += hash_key.to_s + " : " + hashs[hash_key].to_s + " || "
    end
  end
  output
end

if __FILE__ == $0
  puts MyConfig::DEFAULT[:client_secret]
  sd = MySoundcloud.new
  sd.getLogInfo
  sd.connect
  sd.getMe
  puts sd.me
  puts "Welcome #{sd.me.username}, please be patient while we are getting information :D"
  sd.getFollowings

  copyInnerFollowing = sd.innerFollowings.clone

  copyInnerFollowing.each do |h|
    sd.putFollowings(sd.getFollowings(h[:id]))
  end
  sd.orderInners
  sd.displayArray(sd.innerFollowings.reverse)

  while lol=STDIN.gets
  end
end
