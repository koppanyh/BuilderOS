local flag = ...
local t = turtle
local s = 1
local rfunc = read
local rn = rednet

if flag == "rn" then
  print("ID: "..os.getComputerID())
  rn.open("right")
  os.loadAPI("/rnterm")
  local i
  i,_,_ = rn.receive()
  rnterm.setcid(i)
  rfunc = rnterm.read
  term.redirect(rnterm)
end

local function help()
  print("Auto Builder v3 @",os.getComputerID())
  print(" w - forward    | p - place")
  print(" a - turn left  | i - place up")
  print(" s - backward   | o - place down")
  print(" d - turn right | j - dig")
  print(" q - up         | k - dig up")
  print(" e - down       | l - dig down")
  print(" 0-9 - select   | f - fuel stat")
  print()
  print(" exit - exit")
  print(" help - this page")
  print()
end

local function refuel()
  local i
  if t.getFuelLevel() < 10 then
    write("fuel ")
    t.select(13)
    t.refuel()
    t.transferTo(12)
    for i=14,16 do
      t.select(i)
      t.transferTo(i-1)
    end
    t.select(12)
    t.transferTo(16)
    t.select(s)
  end
end

local function fuel()
  write(t.getFuelLevel().." ")
end

local function parse(a, i)
  local x, y, z
  local f = {w=t.forward, s=t.back,
    a=t.turnLeft, d=t.turnRight,
    q=t.up, e=t.down, p=t.place,
    i=t.placeUp, o=t.placeDown, f=fuel,
    j=t.dig, k=t.digUp, l=t.digDown}
  for x=1,i do
    for y=1,string.len(a) do
      refuel()
      z = string.sub(a,y,y)
      if tonumber(z) ~= nil then
        write(z.." ")
        s = z+1
        t.select(s)
      elseif f[z] ~= nil then
        write(z.." ")
        f[z]()
      else write("err("..z..") ") end
    end
    write(", ")
  end
  print()
end

local function separate(s,a,b)
  local i
  local q = {}
  for i in string.gmatch(s,"%w+") do q[#q+1] = i end
  i = 1
  while i<=#q do
    a[#a+1] = q[i]
    if q[i+1] == nil then
      b[#b+1] = 1
      break
    end
    if tonumber(q[i+1]) ~= nil then
      b[#b+1] = q[i+1] + 0
      i = i + 1
    else b[#b+1] = 1 end
    i = i + 1
  end
end

local function cmdline()
  term.clear()
  term.setCursorPos(1,1)
  help()
  local a, i
  local b={}
  local c={}
  local hist = {}
  while true do
    write(">> ")
    a = rfunc(nil, hist)
    hist[#hist+1] = a
    if a == "exit" then
      print("Are you sure? y/n ")
      a = rfunc()
      if a == "y" then
        if flag == "rn" then
          rnterm.exit()
          term.restore()
        end
        break
      else a = "" end
    end
    if a == "help" then help()
    else
      b = {}
      c = {}
      separate(a,b,c)
      for i=1,#b do
        parse(b[i],c[i])
      end
    end
  end
end

cmdline()
