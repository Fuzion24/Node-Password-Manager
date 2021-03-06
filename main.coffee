crypto = require 'crypto'
md5 = require 'MD5'
sqlite3 = require 'sqlite3'

encrypt = (plaintext, password) ->
	aes = crypto.createCipher 'aes-256-cbc', md5(password), md5(md5(password))
	crypted = aes.update plaintext, 'utf8', 'hex'
	crypted += aes.final 'hex'

decrypt = (ciphertext, password) ->
	decrypter = crypto.createDecipher 'aes-256-cbc', md5(password), md5(md5(password))
	res = decrypter.update ciphertext, 'hex', 'utf8'
	res += decrypter.final 'hex'

class sqlitedb
	constructor: (filename, @secret) ->
		@db = new sqlite3.Database(filename)
	
	serialize: (func) => 
			@db.serialize.call(@db, func)
	
	initTable: () ->
		@db.run 'CREATE TABLE IF NOT EXISTS logins (username TEXT, password TEXT, description TEXT);'
	
	insertLogin: (username, password, description) ->
		enc_password = encrypt password, @secret
		@db.run 'INSERT INTO logins VALUES (\'' + username + '\', \'' + enc_password + '\', \'' + description + '\')'
	
	listLogins: (cb) ->
		@db.all 'SELECT username, password, description FROM logins', cb
	
	decryptLogin: (description, cb) ->
		#lol SQL injection
		@db.get "SELECT * FROM logins WHERE description = \"description\"", (err, user) =>
			if err? then cb err
			else
				user.password = decrypt user.password, @secret
				cb null, user



db = new sqlitedb( './db.test', 'testing' )

db.serialize () ->
	db.initTable()
	db.insertLogin 'ryan', 'p@ssword', 'google.com'
	db.insertLogin 'loginB', 'guess1234', 'amazon.com'
	db.listLogins (err, logins) ->
		console.log logins
	db.decryptLogin 'google.com', (err, user) ->
		console.log user




#Test Encryption

plaintext = "This is text to test the encryption and decryption algos"
password = "testing"

c_text = encrypt plaintext, password
p_text = decrypt c_text, password

if p_text == plaintext && p_text != c_text
	console.log "Encryption and decryption -> great success"