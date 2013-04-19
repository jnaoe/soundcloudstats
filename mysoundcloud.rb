require 'soundcloud'
require './myconfig'
require './logger'

#!/usr/bin/env ruby
class MySoundcloud
  attr_accessor :client # object wich comunicate with sdk
  attr_accessor :innerFollowings # list of followings
  attr_accessor :me # current logged user
	
  def initialize()
    # to intialize log system
    @logger = Logger.new({:level => MyConfig::DEFAULT[:debug_level]})
    @logger.log(@logger.LEVELS[:debug], 'info()')
    @innerFollowings = Array.new
  end

  # Connection to soundcloud
  def connect()
    @logger.log('DEBUG', 'connect()')
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

  # Get information to loggin the user to soundcloud if needed
  def getLogInfo(username = nil, password = nil)
    @logger.log(@logger.LEVELS[:debug], 'getLofInfo()')
    if(username == nil) # if the username is neither from the config or the consol
      print "username : "
      @username = STDIN.gets
      @username.chop!
    else
      @username = username
    end

    if(password == nil) # if the password is neither from the config or the consol
      print "password : "
      @password = STDIN.gets
      @password.chop!
    else
      @password = password
    end
  end

  # Puts an array of following into @innerFollowing 
  # Params:
  # +followings+:: array of followings to put into @innerFollowings
  def putFollowings(followings)
    if(followings.respond_to?("each"))
      followings.each do |following|
        putFollowing(following)
      end
    end
  end

  # Puts a following into @innerFollowings
  # Params:
  # +following+:: single following to add to @innerFollowings
  def putFollowing(following)
  #   Logger::log('DEBUG', 'putFollowing()')
    index = @innerFollowings.find_index {|h| h[:id] == following.id}
    if(index != nil)
      @innerFollowings[index][:counter] += 1
      # Logger::log("DEBUG", @innerFollowings[innerFollowing.id]['username']+"+1")
    else
      @innerFollowings.push({:id=>following.id, :username => following.username, :counter => 1})
      # Logger::log('DEBUG', "####"+hash_to_s(@innerFollowings))
      # Logger::log('DEBUG', @innerFollowings[innerFollowing.id])
    end
  end

  # Get the followings from a user
  # Params:
  # +user_id+:: Id of the user to get following from (default to the current user id)
  def getFollowings(user_id = @me.id)
    # Logger::log('DEBUG', 'getFollowings()')
    followings = @client.get("/users/#{user_id}/followings")
    putFollowings(followings)
  end

  # Get information about the current user
  def getMe()
    @logger.log('DEBUG', 'getMe()')
    @me = @client.get('/me')
    puts "Your id is #{@me.id}"
  end

  # Order @innerFollowings by counter
  def orderInners()
    @logger.log(@logger.LEVELS[:debug], 'orderInners()')
    @innerFollowings.sort_by! { |v| v[:counter] }
  end

  def displayArrayOld(hashs = @innerFollowings, order = false, style = {:column_length => "auto"})

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

  # Display an array well outputing
  def displayArray(hashs = @innerFollowings, order = false, style = {:column_length => "auto"})
    lengths = {}
    space_string = "                                                                              "
    hashs[0].keys.each do |k|
      if(style[:column_length] == "auto")
        lengths[k.to_sym] = hashs.max_by{|hash| hash[k.to_sym].to_s.length}[k.to_sym].to_s.length
        lengths[k.to_sym] = (lengths[k.to_sym] < k.to_s.length) ? k.to_s.length : lengths[k.to_sym]
      else
        lengths[k.to_sym] = style[:column_length]
      end
    end

    is_first = true

    hashs.each do |h|
      raw = ""
      h.keys.each do |k|
        if(is_first)
          n = lengths[k.to_sym] - k.to_s.length
          raw += k.to_s+space_string[0..n]+" | "
        else
          n = lengths[k.to_sym] - h[k.to_sym].to_s.length
          raw += h[k.to_sym].to_s+space_string[0..n]+" | "
        end
      end
      puts raw
      if(is_first)
        delimitor = ""
        is_first = false
        (0..raw.length).each {delimitor += "-"  }
        puts delimitor
        redo
      end
    end
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
  sd = MySoundcloud.new
  username = (MyConfig::DEFAULT[:username] != nil) ? MyConfig::DEFAULT[:username] : nil
  password = (MyConfig::DEFAULT[:password] != nil) ? MyConfig::DEFAULT[:password] : nil
  sd.getLogInfo((ARGV[0] != nil) ? ARGV[0] : username, (ARGV[1] != nil) ? ARGV[1] : password)
  sd.connect
  sd.getMe
  puts sd.me
  puts "Welcome #{sd.me.username}, please be patient while we are getting information :D"
  sd.getFollowings

  sd.displayArray(sd.innerFollowings)
  abort('Test')
 
  copyInnerFollowing = sd.innerFollowings.clone

  count = copyInnerFollowing.length
  iterator = 0
  step = 5
  current_step = 0


  copyInnerFollowing.each do |h|
    percent = iterator * 100 / count
    if(percent > current_step)
      current_step += step
      print("#{current_step}%... ")
    end
    iterator += 1
    sd.putFollowings(sd.getFollowings(h[:id]))
  end
  sd.orderInners
  sd.displayArray(sd.innerFollowings.reverse)

  while lol=STDIN.gets
  end
end
