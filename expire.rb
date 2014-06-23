#!/usr/bin/ruby -w

require 'mysql'

begin
	db = Mysql.new('localhost','ruby','ruby','twitter')
	expiry_time="3 minute" # set this in correct format to hand off to mysql
	# set all entries older than three/thirty minutes to expired=true
	posts_query = db.query("UPDATE posts SET expired=1 WHERE tweet_post_time < ( NOW() -INTERVAL #{expiry_time})")

rescue Mysql::Error => e
	puts e.errno
	puts e.error

ensure
	db.close if db

end
