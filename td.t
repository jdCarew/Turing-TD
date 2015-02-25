drawfillbox (0, 0, maxx, maxy, blue)
drawfillbox (201, 20, maxx - 39, maxy - 19, white)     %200-600, 20-380
for i : 1 .. 20
    drawline (200 + 20 * i, 20, 200 + 20 * i, maxy - 19, black)
end for
for i : 1 .. 18
    drawline (200, 20 * (i + 1), maxx - 39, 20 * (i + 1), black)
end for
drawfillbox (200, 181, 219, 199, green)
drawfillbox (581, 181, 599, 199, green)
%variables
class square
    export x, y, setx, sety
    var x, y : int
    procedure setx (k : int)
	x := k
    end setx
    procedure sety (k : int)
	y := k
    end sety
end square
var node : array 1 .. 20, 1 .. 18 of int %0=none, 1=basic
var thestartx := 1
var thestarty := 9
var theExit : ^square
new theExit
theExit -> setx (20)
theExit -> sety (9)
var endx := 20
var endy := 9
for x : 1 .. 20
    for y : 1 .. 18
	node (x, y) := 0
    end for
end for
var mousex, mousey, button : int
var fontOne : int := Font.New ("Ariel:18")

function inmap (x : int, y : int) : boolean
    result (x > 200) and (x < 600) and (y > 20) and (y < 380)
end inmap

function rounddown (x : real) : int
    if round (x) > x then
	result round (x) - 1
    end if
    result round (x)
end rounddown

procedure drawnodes
    for x : 1 .. 20
	for y : 1 .. 18
	    if node (x, y) = 1 then
		drawfillbox (x * 20 + 181, y * 20 + 1, x * 20 + 199, y * 20 + 19, red)
	    end if
	end for
    end for
end drawnodes

procedure drawnode (x : int, y : int, c : int)
    drawfillbox (x * 20 + 181, y * 20 + 1, x * 20 + 199, y * 20 + 19, c)
end drawnode

class Enemy
    import square, thestartx, thestarty, endx, endy, node, drawnode, rounddown
    export x, y, speed, speedx, speedy, hp, move, initialize, draw, alive
    var x, y : int
    var relx, rely : int
    var pos : ^square
    var speed, speedx, speedy : int
    var hp : int
    var alive : boolean

    procedure initialize
	new pos
	x := 205
	y := 190
	speed := 3
	relx := thestartx
	rely := thestarty
	pos -> setx (relx)
	pos -> sety (rely)
	alive := true
    end initialize

    procedure draw
	drawfilloval (x, y, 5, 5, black)
    end draw

    procedure die
	alive := false
    end die

    function h (hx : int, hy : int) : real
	result sqrt ((endx - hx) * (endx - hx) + (endy - hy) * (endy - hy))
    end h

    procedure A (startx : int, starty : int)
	var closedset : array 1 .. 20, 1 .. 18 of boolean
	var openset : array 1 .. 20, 1 .. 18 of boolean
	var camefromx : array 1 .. 20, 1 .. 18 of int
	var camefromy : array 1 .. 20, 1 .. 18 of int
	var g : array 1 .. 20, 1 .. 18 of int
	var f : array 1 .. 20, 1 .. 18 of real
	for i : 1 .. 20
	    for j : 1 .. 18
		closedset (i, j) := false
		openset (i, j) := false
		g (i, j) := 10000
		f (i, j) := 10000
	    end for
	end for
	camefromx (startx, starty) := -1
	openset (startx, starty) := true
	g (startx, starty) := 0
	f (startx, starty) := g (startx, starty) + h (startx, starty)
	var currentx, currenty : int
	currentx := startx
	currenty := starty
	loop % while openset is not empty
	    for i : 1 .. 20
		for j : 1 .. 18
		    if openset (i, j) then
			if currentx = 0 or f (i, j) < f (currentx, currenty) then
			    currentx := i
			    currenty := j
			end if
		    end if
		end for
	    end for
	    if currentx = endx and currenty = endy then
		var px, py : int
		loop
		    drawnode (currentx, currenty, 51)
		    if camefromx (currentx, currenty) = -1 then
			if px > currentx then
			    speedx := speed
			    speedy := 0
			end if
			if py > currenty then
			    speedx := 0
			    speedy := speed
			end if
			if px < currentx then
			    speedx := -1 * speed
			    speedy := 0
			end if
			if py < currenty then
			    speedx := 0
			    speedy := -1 * speed
			end if
			exit
		    end if
		    px := currentx
		    py := currenty
		    currentx := camefromx (px, py)
		    currenty := camefromy (px, py)
		end loop
		exit
	    end if
	    if currentx = -1 then
		put "cheater"
		exit
	    end if
	    openset (currentx, currenty) := false
	    closedset (currentx, currenty) := true
	    %left up right down
	    if currentx - 1 > 0 and node (currentx - 1, currenty) = 0 and closedset (currentx - 1, currenty) = false then
		var tent := g (currentx, currenty) + 1
		if openset (currentx - 1, currenty) = false or tent < g (currentx - 1, currenty) then
		    camefromx (currentx - 1, currenty) := currentx
		    camefromy (currentx - 1, currenty) := currenty
		    g (currentx - 1, currenty) := tent
		    f (currentx - 1, currenty) := tent + h (currentx - 1, currenty)
		    openset (currentx - 1, currenty) := true
		end if
	    end if
	    %up
	    if currenty + 1 < 19 and node (currentx, currenty + 1) = 0 and closedset (currentx, currenty + 1) = false then
		var tent := g (currentx, currenty) + 1
		if openset (currentx, currenty + 1) = false or tent < g (currentx, currenty + 1) then
		    camefromx (currentx, currenty + 1) := currentx
		    camefromy (currentx, currenty + 1) := currenty
		    g (currentx, currenty + 1) := tent
		    f (currentx, currenty + 1) := tent + h (currentx, currenty + 1)
		    openset (currentx, currenty + 1) := true
		end if
	    end if
	    %right
	    if currentx + 1 < 21 and node (currentx + 1, currenty) = 0 and closedset (currentx + 1, currenty) = false then
		var tent := g (currentx, currenty) + 1
		if openset (currentx + 1, currenty) = false or tent < g (currentx + 1, currenty) then
		    camefromx (currentx + 1, currenty) := currentx
		    camefromy (currentx + 1, currenty) := currenty
		    g (currentx + 1, currenty) := tent
		    f (currentx + 1, currenty) := tent + h (currentx + 1, currenty)
		    openset (currentx + 1, currenty) := true
		end if
	    end if
	    %down
	    if currenty - 1 > 0 and node (currentx, currenty - 1) = 0 and closedset (currentx, currenty - 1) = false then
		var tent := g (currentx, currenty) + 1
		if openset (currentx, currenty - 1) = false or tent < g (currentx, currenty - 1) then
		    camefromx (currentx, currenty - 1) := currentx
		    camefromy (currentx, currenty - 1) := currenty
		    g (currentx, currenty - 1) := tent
		    f (currentx, currenty - 1) := tent + h (currentx, currenty - 1)
		    openset (currentx, currenty - 1) := true
		end if
	    end if
	    currentx := 0
	end loop
    end A

    procedure move
	if relx = endx and rely = endy then
	    die
	end if
	A (relx, rely)
	drawfilloval (x, y, 5, 5, white)
	x += speedx
	y += speedy
	drawfilloval (x, y, 5, 5, black)
	relx := rounddown ((x - 180) / 20)
	rely := rounddown ((y) / 20)
    end move
end Enemy
var enemies : array 1 .. 10 of ^Enemy
var enemyCount : int := 1
new enemies (1)
enemies (1) -> initialize

class Bullet
    export initialize, move
    var x, y, target, speed : int
    var live :boolean

    procedure initialize (inx : int, iny : int, intarget : int)
	x := inx
	y := iny
	target := intarget
	speed := 3
	live:=true
    end initialize

    procedure draw
	drawdot (x, y, black)
    end draw

    procedure move
	drawdot (x, y, white)
	x += speed
	y += speed
	draw
    end move
end Bullet

class Tower
    import drawnode, fontOne
    export upgrade, spawn, draw, radius, highlight, unhighlight, centerx, centery, shoot

    var x, y, ttype, radius, damage : int
    var centerx, centery : int
    procedure draw
	if ttype = 1 then
	    drawnode (x, y, 19)
	end if
    end draw

    procedure highlight
	drawoval (centerx, centery, radius, radius, black)
	Font.Draw ("Tower: ", 0, 300, fontOne, black)
	Font.Draw (intstr (ttype), 100, 300, fontOne, black)
	Font.Draw ("Radius", 0, 250, fontOne, black)
	Font.Draw (intstr (radius), 100, 250, fontOne, black)
	Font.Draw ("Damage", 0, 200, fontOne, black)
	Font.Draw (intstr (damage), 100, 200, fontOne, black)
    end highlight

    procedure unhighlight
	drawoval (centerx, centery, radius, radius, white)
	Font.Draw ("Tower: ", 0, 300, fontOne, blue)
	Font.Draw (intstr (ttype), 100, 300, fontOne, blue)
	Font.Draw ("Radius", 0, 250, fontOne, blue)
	Font.Draw (intstr (radius), 100, 250, fontOne, blue)
	Font.Draw ("Damage", 0, 200, fontOne, blue)
	Font.Draw (intstr (damage), 100, 200, fontOne, blue)
    end unhighlight

    procedure spawn (inx : int, iny : int, intype : int)
	x := inx
	y := iny
	centerx := x * 20 + 190
	centery := y * 20 + 10
	ttype := intype
	if ttype = 1 then
	    radius := 30
	    damage := 5
	end if
	draw
    end spawn

    procedure upgrade

    end upgrade

    procedure shoot (target : int)

    end shoot

end Tower

var towers : array 1 .. 250 of ^Tower
var towercount : int := 0
var bullets : array 1 .. 200 of ^Bullet
var bulletcount : int := 0
var currenttype : int := 1
var selected : int := 0
var start, now : int
start := Time.Elapsed
loop
    button := 0
    Mouse.Where (mousex, mousey, button)
    if button = 1 and inmap (mousex, mousey) then     %if onmap click
	if node (rounddown ((mousex - 180) / 20), rounddown ((mousey) / 20)) = 0 then %attempt purchase if none there
	    towercount += 1
	    node (rounddown ((mousex - 180) / 20), rounddown ((mousey) / 20)) := towercount
	    new towers (towercount)
	    towers (towercount) -> spawn (rounddown ((mousex - 180) / 20), rounddown ((mousey) / 20), currenttype)
	else
	    %select tower there
	    if selected > 0 then
		towers (selected) -> unhighlight
	    end if
	    selected := node (rounddown ((mousex - 180) / 20), rounddown ((mousey) / 20))
	    towers (selected) -> highlight
	end if
    end if
    for i : 1 .. towercount
	if abs (enemies (1) -> x - towers (i) -> centerx) < towers (i) -> radius and abs (enemies (1) -> y - towers (i) -> centery) < towers (i) -> radius and enemies (1) -> alive then
	    bulletcount += 1
	    new bullets (bulletcount)
	    bullets (bulletcount) -> initialize (towers (i) -> centerx, towers (i) -> centery, 1)
	end if
    end for
    %if 20 seconds have passed, enemy starts
    if (Time.Elapsed - start > 20000) then
	enemies (1) -> draw
	enemies (1) -> move
    else
	drawfillbox (20, 20, 50, 50, blue)
	Font.Draw (intstr (round ((Time.Elapsed - start) / 1000)), 20, 20, fontOne, red)
    end if
    %redraw
    for i : 1 .. bulletcount
	bullets (i) -> move
    end for
    for i : 1 .. 20
	drawline (200 + 20 * i, 20, 200 + 20 * i, maxy - 19, black)
    end for
    for i : 1 .. 18
	drawline (200, 20 * (i + 1), maxx - 39, 20 * (i + 1), black)
    end for
    drawfillbox (200, 181, 219, 199, green)
    delay (1)
end loop
