require "socket"

class ChatServer

   def initialize(host, port) #initialize
      $version = 1.7
      @descriptors = Array.new
      @socket = TCPServer.new(host,port)
      #@socket.setsockopt( Socket::TCP_SOCKET, Socket::SO_REUSEADDR, 1)
      printf("Frozenbase Telnet Chat Server v%s started on %s:%d\n", $version, host, port)
      @descriptors.push @socket
   end
   
   def run
      while(1)
         res = select @descriptors, nil, nil, nil
         if(res != nil)
            for sock in res[0]
               if(sock == @socket)
                  acceptNewConnection
               else
                  if(sock.eof?)
                     str = sprintf("Client %s:%s left the server", sock.peeraddr[2], sock.peeraddr[1])
                     broadcast(str, sock)
                  else
                     str = sprintf("[%s|%s] %s", sock.peeraddr[1], sock.peeraddr[2], sock.gets)
                     broadcast(str, sock)
                  end
               end
            end
         end
      end
   end
   
   private
   def broadcast(string, sock)
      @descriptors.each do |sock|
         if sock != @socket && sock != sock
            sock.puts(string)
         end
      end
      puts(string)
   end
   
   def acceptNewConnection
      newSock = @socket.accept
      @descriptors.push (newSock)
      newSock.printf("welcome to Frozenbase Chat Server v%s", $version)
      nick = 0
      until(nick.size < 20 && nick.size > 4)
         newSock.printf("enter your nickname (min 4 max 20)\n\t> ")
         nick = newSock.gets.chomp
      end
      str = sprintf("\tNew client [%s] Joined - %s:%s\n",nick, newSock.peeraddr[2],newSock.peeraddr[1])
      broadcast(str, newSock)
   end
end

host = ""
port = 8080
server = ChatServer.new(host, port)
server.run
