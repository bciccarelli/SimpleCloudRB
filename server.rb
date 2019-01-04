require 'socket'
require 'hex_string'
require 'openssl'
require "base64"

password = "banana"
salt = "salt"

cipher = OpenSSL::Cipher.new('aes128')
cipher.encrypt

def padRight(str)
	m = str
	for i in 2..(16-(str.length%16))
		m += " "
	end
	puts m + "."
	return m
end

server = TCPServer.new 3000

while session = server.accept
	request = session.gets
	session.print "HTTP/1.1 200\r\n" # 1
	session.print "Access-Control-Allow-Origin: *\r\n"
	session.print "Content-Type: text/plain\r\n" # 2
	session.print "\r\n" # 3
	key  = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, 100, cipher.key_len, "SHA256")
	cipher.key = key
	iv  = cipher.random_iv
	method, full_path = request.split(' ')
	full_path = full_path[1..full_path.length]
	encrypted = cipher.update(Base64.encode64(File.open(full_path+".jpg", "rb").read)) + cipher.final
	session.print (iv).to_hex_string.delete(' ')+":"+(encrypted).to_hex_string.delete(' ') # 4
	session.close
end