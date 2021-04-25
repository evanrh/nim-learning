import os
import threadpool
import asyncdispatch
import asyncnet
import protocol

proc connect(socket: AsyncSocket, serverAddr: string) {.async} =
  echo("Connecting to ", serverAddr)
  await socket.connect(serverAddr, 7687.Port)
  echo("Connected!")
  echo("Type 'quit' to exit")

  while true:
    let line = await socket.recvLine()
    let parsed = parseMessage(line)
    echo(parsed.username, " said: ", parsed.message)

if paramCount() < 2:
  quit("Please specify the server address and a username, e.g. ./client localhost user")

echo("Chat application started")
let serverAddr = paramStr(1)
let username = paramStr(2)
var
  socket = newAsyncSocket()
  messageFlowVar = spawn stdin.readLine()

asyncCheck connect(socket, serverAddr)

while true:
  if messageFlowVar.isReady():
    let message = createMessage(username, ^messageFlowVar)
    if parseMessage(message).message == "quit":
      close(socket)
      break
    asyncCheck socket.send(message)
    messageFlowVar = spawn stdin.readLine()
  
  asyncdispatch.poll()
