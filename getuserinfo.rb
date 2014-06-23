#!/usr/bin/ruby -w

require 'mysql'

begin
	name ="" 
	
	list=[]
	
	db =Mysql.new('localhost', 'ruby', 'ruby', 'twitter')
	
	user_info =db.query("SELECT * FROM users WHERE username = '#{name}'")
	user_info.each {|info| list << info}

	if list.empty?
		puts "no user found"
	else
		list.each {|info| puts info}
	end


rescue Mysql::Error => e
	puts e.errno
	puts e.error

ensure
	db.close if db
end
