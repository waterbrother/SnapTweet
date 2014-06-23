require 'date'
require 'mysql'
require 'oauth'
require 'json'

begin
	db = Mysql.real_connect('localhost','ruby','ruby','twitter')

	db.query("DELETE FROM posts WHERE deleted=1")


rescue Mysql::Error => e
	puts e.errno
	puts e.error

ensure
	db.close if db

end
