--ASCII:
Z=string.byte('Z',1)
X=string.byte('X',1)
VK_DOWN=0x28
VK_RIGHT=0x27

sleep(1000)
t=100
sleep(t)
sendKey(Z,true)
sleep(t)
sendKey(Z,false)
sleep(t)
sendKey(VK_DOWN,true)
sleep(t)
sendKey(VK_DOWN,false)
sleep(t)
sendKey(VK_DOWN,true)
sleep(t)
sendKey(VK_DOWN,false)
sleep(t)
sendKey(Z,true)
sleep(t)
sendKey(Z,false)
sleep(t)
sendKey(X,true)
sleep(t)
sendKey(X,false)
sleep(t)
sendKey(Z,true)
sleep(t)
sendKey(Z,false)
sleep(t)
sendKey(Z,true)
sleep(t)
sendKey(Z,false)