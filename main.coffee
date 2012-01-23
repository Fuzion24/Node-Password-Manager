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

createDBStructure = (db) ->
	db.run 'CREATE TABLE IF NOT EXISTS logins (username TEXT, password TEXT, description TEXT);'

insertLogin = (db, username, password, description) ->
	db.run 'INSERT INTO logins VALUES (\'' + username + '\', \'' + password + '\', \'' + description + '\')'

listLogins = (db) ->
	db.each 'SELECT username, password, description FROM logins' , (err, row) ->
		console.log row.description + ' ' + row.username + ' ' + row.password + ' '


db = new sqlite3.Database 'db.test'

db.serialize () ->
	createDBStructure db
	insertLogin db, 'ryan', 'p@ssword', 'google.com'
	insertLogin db, 'loginB', 'guess1234', 'amazon.com'
	listLogins db

db.close

#Test Encryption

plaintext = "This is text to test the encryption and decryption algos"
password = "testing"

c_text = encrypt plaintext, password
p_text = decrypt c_text, password

if p_text == plaintext && p_text != c_text
	console.log "Encryption and decryption -> great success"