local flag = ...
local t = turtle
local s = 1
local rfunc = read
local rn = rednet
local sides = redstone.getSides()

if flag == "rn" then
  --reserve this for reading files
end

local function help()
  print("BuilderOS v5 @",os.getComputerID())
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
end

local function refuel()
  if t.getFuelLevel() <= 10 then
    write("refuel ")
    for i=13,16 do
      t.select(i)
      if t.refuel(1) then break
      else if i == 16 then error("Out of fuel") end
      end
    end
    t.select(s)
  end
end

local function fuel()
  write(t.getFuelLevel().." ")
end

local function parse(a, i)
  local x, y, z
  local broken = false
  local f = {w=t.forward, s=t.back,
    a=t.turnLeft, d=t.turnRight,
    q=t.up, e=t.down, p=t.place,
    i=t.placeUp, o=t.placeDown, f=fuel,
    j=t.dig, k=t.digUp, l=t.digDown}
  for x=1,i do
    for y=1,string.len(a) do
      for si,sv in pairs(sides) do
        if redstone.getInput(sv) then
          broken = true
          break
        end
      end
      if broken then break end
      refuel()
      z = string.sub(a,y,y)
      if tonumber(z) ~= nil then
        write(z..",")
        s = z+1
        t.select(s)
      elseif f[z] ~= nil then
        write(z..",")
        f[z]()
      else write("err('"..z.."'),") end
    end
  end
  if broken then print("Redstone Termination") end
end

function splitter(s)
  local q = {}
  local t = ""
  local pc = 0
  for i in string.gmatch(s,"[%s%S]") do
    if pc == 0 then
      if i == " " then
        if t ~= "" then q[#q+1] = t end
        t = ""
      else
        if i == "(" then pc = 1 end
        t = t .. i
      end
    else
      if i == "(" then pc = pc + 1
      else if i == ")" then pc = pc - 1 end end
      t = t .. i
    end
  end
  if t ~= "" then q[#q+1] = t end
  --hello world   (today how) are  you
  --["hello", "world", "(today how)", "are", "you"]
  return q
end

function separate(s,a,b)
  local q = splitter(s)
  local i = 1
  local v = nil
  while i <= #q do
    a[#a+1] = q[i]
    i = i + 1
    v = tonumber(q[i])
    if v ~= nil then
      b[#a] = v
      i = i + 1
    else b[#a] = 1 end
  end
  --wwas 7 asdf 2 hello 1 2 3 moo
  --wwas asdf hello 2 moo
  --7    2    1     3 1
end

function runcode(s)
  local a = {}
  local b = {}
  separate(s,a,b)
  for i=1,#a do
    if string.sub(a[i],1,1) == "(" and string.sub(a[i],-1,-1) == ")" then
      for j=1,b[i] do
        runcode(string.sub(a[i],2,-2))
      end
    else parse(a[i],b[i]) end
  end
end

local function cmdline()
  term.clear()
  term.setCursorPos(1,1)
  help()
  local a
  local hist = {}
  while true do
    print()
    write(">> ")
    a = rfunc(nil, hist)
    hist[#hist+1] = a
    if a == "exit" then
      print("Are you sure? y/N ")
      a = rfunc()
      if a == "y" then break
      else a = "" end
    end
    if a == "help" then help()
    else runcode(a) end
  end
end

cmdline()
