#!/usr/bin/ruby

# require 'rubygems'
require 'oauth'
require 'json'
require 'mysql'
require 'date'

begin
	# this line defines the rest of this entire script. 
	# perhaps 'user id' would be better than 'username'?
	#  i dunno.
	name =""
	user_id = ""
	
	
	db =Mysql.new('localhost', 'ruby', 'ruby', 'twitter')
	user_query =db.query("SELECT * FROM users WHERE username = '#{name}'")
	# user_query =db.query("SELECT * FROM users WHERE user_id = '#{user_id}'")
	
	user_info = user_query.fetch_row
	
	api_key = OAuth::Consumer.new(
		"#{user_info[2]}",
		"#{user_info[3]}")
	access_token = OAuth::Token.new(
		"#{user_info[4]}",
		"#{user_info[5]}")

	def get_tweet
	  #puts "Enter tweet:"
	  now =DateTime.now
	  return "#{now} this tweet will self destruct in 3 minutes."
	end

	baseurl = "https://api.twitter.com"
	path    = "/1.1/statuses/update.json"

	address = URI("#{baseurl}#{path}")
	request = Net::HTTP::Post.new(address.request_uri)
	request.set_form_data( "status" => get_tweet )

	# Set up HTTP.
	twitter          = Net::HTTP.new(address.host, address.port)
	twitter.use_ssl     = true
	twitter.verify_mode = OpenSSL::SSL::VERIFY_PEER

	# Issue the request.
	request.oauth!(twitter, api_key, access_token)
	twitter.start
	response = twitter.request(request)

	# Parse and print the Tweet if the response code was 200
	# and then record its posting in the DB
	tweet = nil
	if response.code == '200' then
	  tweet = JSON.parse(response.body)
	  #puts "Successfully posted: #{tweet["text"]}"
	  tweet_id =tweet["id"]
	  # we don't really need to get the time when the tweet was created;
	  # it's better to use mysql's internal functions
	  tweet_post_time =tweet["created_at"]
	  posting_user_id =tweet["user"]["id"]
	  expired = 0
	  deleted = 0
	  db.query("INSERT INTO posts VALUES('#{tweet_id}', now(), '#{posting_user_id}', '#{expired}', '#{deleted}')")

	else
	  # puts "Could not send the Tweet! " + "Code:#{response.code} Body:#{response.body}"
	end


rescue Mysql::Error => e
	puts e.errno
	puts e.error

ensure
	db.close if db
end
