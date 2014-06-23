#!/usr/bin/ruby

require 'mysql'

username = ""
user_id = ""
api_key =""
api_secret =""
access_token =""
access_secret =""

begin
	db =Mysql.new('localhost','ruby','ruby','twitter')

	# need to make this conditional so as to prevent redundant data
	db.query( "INSERT INTO users VALUES('#{username}', '#{user_id}', '#{api_key}', '#{api_secret}', '#{access_token}', '#{access_secret}')" )

rescue Mysql::Error => e
	puts e.errno
	puts e.error

ensure 
	db.close if db
end
