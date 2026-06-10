R1 = 20
R2 = 30
R3 = 50
R4 = 55
R5 = 58
R6 = 63
R7 = 66
R8 = 78

function draw_circle(R)
    mi_addnode(R,0)
    mi_addnode(-R,0)
    mi_addarc(R,0,-R,0,180,1)
    mi_addarc(-R,0,R,0,180,1)
end

newdocument(0)
mi_probdef(0,"millimeters","planar",1e-8,0,30)

draw_circle(R1)
draw_circle(R2)
draw_circle(R3)
draw_circle(R4)
draw_circle(R5)
draw_circle(R6)
draw_circle(R7)
draw_circle(R8)

Ns = 12
Nr = 14

theta0_s = 15
theta0_r = 90

pi = 3.14159265358979

delta_inner = 4 * pi / 180
delta_outer = 7.5 * pi / 180
delta_mid   = 3 * pi / 180

delta_pink_inner = 2 * pi / 180
delta_pink_outer = 3.5 * pi / 180

for n = 0, Ns-1 do
    local theta = (theta0_s + n*(360/Ns)) * pi / 180

    local x1 = R2 * cos(theta)
    local y1 = R2 * sin(theta)
    local x2 = R3 * cos(theta)
    local y2 = R3 * sin(theta)

    mi_addnode(x1,y1)
    mi_addnode(x2,y2)
    mi_addsegment(x1,y1,x2,y2)
end

for n = 0, Ns-1 do
    local theta = (theta0_s + n*(360/Ns)) * pi / 180

    for side = -1, 1, 2 do

        local x1 = R2 * cos(theta + side*delta_inner)
        local y1 = R2 * sin(theta + side*delta_inner)
        local x2 = R3 * cos(theta + side*delta_outer)
        local y2 = R3 * sin(theta + side*delta_outer)

        mi_addnode(x1,y1)
        mi_addnode(x2,y2)
        mi_addsegment(x1,y1,x2,y2)

        local xm1 = R3 * cos(theta + side*delta_mid)
        local ym1 = R3 * sin(theta + side*delta_mid)
        local xm2 = R4 * cos(theta + side*delta_mid)
        local ym2 = R4 * sin(theta + side*delta_mid)

        mi_addnode(xm1,ym1)
        mi_addnode(xm2,ym2)
        mi_addsegment(xm1,ym1,xm2,ym2)
    end
end

for n = 0, Nr-1 do
    local theta = (theta0_r + n*(360/Nr)) * pi / 180

    for side = -1, 1, 2 do

        local x1 = R5 * cos(theta + side*delta_pink_inner)
        local y1 = R5 * sin(theta + side*delta_pink_inner)

        local x2 = R6 * cos(theta + side*delta_pink_outer)
        local y2 = R6 * sin(theta + side*delta_pink_outer)

        mi_addnode(x1,y1)
        mi_addnode(x2,y2)
        mi_addsegment(x1,y1,x2,y2)
    end
end

for n = 0, Ns-1 do
    local theta = (theta0_s + (n + 0.5)*(360/Ns)) * pi / 180

    local x = R2 * cos(theta)
    local y = R2 * sin(theta)

    mi_selectarcsegment(x,y)
end

mi_deleteselected()

for n = 0, Ns-1 do
    local theta = (theta0_s + (n + 0.5)*(360/Ns)) * pi / 180

    local x = R3 * cos(theta)
    local y = R3 * sin(theta)

    mi_selectarcsegment(x,y)
end

mi_deleteselected()

for n = 0, Ns-1 do
    local theta = (theta0_s + n*(360/Ns)) * pi / 180

    local x = R4 * cos(theta)
    local y = R4 * sin(theta)

    mi_selectarcsegment(x,y)
end

mi_deleteselected()

for n = 0, Nr-1 do
    local theta = (theta0_r + n*(360/Nr)) * pi / 180

    local x = R5 * cos(theta)
    local y = R5 * sin(theta)

    mi_selectarcsegment(x,y)
end

mi_deleteselected()

mi_selectnode(R2,0)
mi_selectnode(-R2,0)
mi_deleteselected()

mi_selectnode(R3,0)
mi_selectnode(-R3,0)
mi_deleteselected()

mi_zoomnatural()
