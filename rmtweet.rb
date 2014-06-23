#!/usr/bin/ruby

require 'rubygems'
require 'oauth'
require 'json'
require 'mysql'

begin
	db =Mysql.new('localhost', 'ruby', 'ruby', 'twitter')
	# search for all tweet_id results marked for deletion and 
	# then delete each tweet and remove its entry from the data base 
	tweet_id =""
	name ="" 
	
	db_result =db.query("SELECT * FROM users WHERE  = '#{}'")
	user_info = db_result.fetch_row
	
	api_key = OAuth::Consumer.new(
		"#{user_info[2]}",
		"#{user_info[3]}")
	access_token = OAuth::Token.new(
		"#{user_info[4]}",
		"#{user_info[5]}")


	baseurl ="https://api.twitter.com"
	path ="/1.1/statuses/destroy" # >> takes param "id"
	address =URI("#{baseurl}#{path}/#{tweet_id}.json")

	#setup and init HTTP connection
	http = Net::HTTP.new(address.host, address.port)
	http.use_ssl =true
	http.verify_mode =OpenSSL::SSL::VERIFY_PEER

	# define request
	request =Net::HTTP::Post.new(address.request_uri)
	request.oauth!(http, api_key, access_token)

	#start http connection, make request, get response
	http.start
	response =http.request(request)

	if response.code == '200'
		puts "tweet #{tweet_id} deleted."
	else
		puts "error:"
		puts response.code
	end


rescue Mysql::Error => e
	puts e.errno
	puts e.error

ensure
	db.close if db
end
