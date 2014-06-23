#!/usr/bin/ruby

require 'date'
require 'mysql'
require 'oauth'
require 'json'

begin
	db = Mysql.new('localhost','ruby','ruby','twitter')
		
	# get list of tweets that are expired 
	exp_query = db.query("SELECT * from  posts WHERE expired=1")
	
	# create list of tweets to delete by id
	exp_list =Array.new

	exp_query.each_hash { |row| exp_list << row['tweet_id'] }

	# for each item in our array:
	#   get the autheticating info from the users table,
	#   delete the tweet using that info,
	#   and record its deletion in posts.
	exp_list.each do |tweet_id|
		uid_result =db.query("SELECT posting_user_id FROM posts WHERE tweet_id ='#{tweet_id}'")

		# this is hardly an elegant way to get the info out, but it will work
		# might be more condensed like this: 
		# 	user_id =user_query.fetch_row[0]
		# not sure if that syntax will work.
		jump =uid_result.fetch_row
		user_id = jump[0]

		# now that we have the user_id of the posting user, let's get the auth info
		user_query =db.query("SELECT * FROM users WHERE user_id ='#{user_id}'")

		user_info =user_query.fetch_hash
		
		api_key = OAuth::Consumer.new(
			"#{user_info['API_key']}",
			"#{user_info['API_secret']}")
		access_token = OAuth::Token.new(
			"#{user_info['access_token']}",
			"#{user_info['access_token_secret']}")

		# set the path of the API call
		api_path =URI("https://api.twitter.com/1.1/statuses/destroy/#{tweet_id}.json")
		
		# set up the connection
		http =Net::HTTP.new(api_path.host, api_path.port)
		http.use_ssl =true
		http.verify_mode =OpenSSL::SSL::VERIFY_PEER
		
		# make the request
		request =Net::HTTP::Post.new(api_path.request_uri)
		request.oauth!(http, api_key, access_token)

		http.start
		response =http.request(request)

		# if all is well, acknowledge deletion and mark the tweet as deleted in the DB
		if response.code =='200'
			#puts "tweet #{tweet_id} deleted"
			db.query("UPDATE posts SET deleted=1 WHERE tweet_id ='#{tweet_id}'")
		else
			#puts "could not delete tweet #{tweet_id}"
			#puts response.code
		end
	end

rescue Mysql::Error => e
	puts e.errno
	puts e.error

ensure
	db.close if db

end
