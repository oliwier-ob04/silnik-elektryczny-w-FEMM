-- parametry pracy: prad, liczba zwojow, kat wirnika
current = 7
turns = 100
rotor_angle = 0
pi = 3.14159265358979

-- grupa wirnika (czesc obracana)
ROTOR = 1

-- promienie kolejnych warstw silnika [mm] (od otworu po obszar zewnetrzny)
R1 = 20
R2 = 30
R3 = 50
R4 = 55
R5 = 58
R6 = 63
R7 = 66
R8 = 78

-- liczba zlobkow i magnesow oraz ich ustawienie katowe
Ns = 12
Nr = 14
theta0_s = 15
theta0_r = 90

-- ksztalt (szerokosci katowe) zlobkow stojana i magnesow
delta_inner = 4 * pi / 180
delta_outer = 7.5 * pi / 180
delta_mid   = 3 * pi / 180
delta_pink_inner = 2 * pi / 180
delta_pink_outer = 3.5 * pi / 180

-- funkcja pomocnicza: okrag
function draw_circle(R)
    mi_addnode(R,0)
    mi_addnode(-R,0)
    mi_addarc(R,0,-R,0,180,1)
    mi_addarc(-R,0,R,0,180,1)
end

-- definicja zadania symulacji (pole magnetyczne 2D, mm, glebokosc 50 mm)
newdocument(0)
mi_probdef(0,"millimeters","planar",1e-8,50,30)

-- okregi rozdzielajace warstwy silnika
draw_circle(R1)
draw_circle(R2)
draw_circle(R3)
draw_circle(R4)
draw_circle(R5)
draw_circle(R6)
draw_circle(R7)
draw_circle(R8)

-- zlobki stojana - linie promieniowe
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

-- zlobki stojana - scianki i wejscia
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

-- magnesy wirnika - scianki (podzial wienca)
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

-- formowanie zlobkow i rozdzielenie magnesow
for n = 0, Ns-1 do
    local theta = (theta0_s + (n + 0.5)*(360/Ns)) * pi / 180
    mi_selectarcsegment(R2 * cos(theta), R2 * sin(theta))
end
mi_deleteselected()

for n = 0, Ns-1 do
    local theta = (theta0_s + (n + 0.5)*(360/Ns)) * pi / 180
    mi_selectarcsegment(R3 * cos(theta), R3 * sin(theta))
end
mi_deleteselected()

for n = 0, Ns-1 do
    local theta = (theta0_s + n*(360/Ns)) * pi / 180
    mi_selectarcsegment(R4 * cos(theta), R4 * sin(theta))
end
mi_deleteselected()

for n = 0, Nr-1 do
    local theta = (theta0_r + n*(360/Nr)) * pi / 180
    mi_selectarcsegment(R5 * cos(theta), R5 * sin(theta))
end
mi_deleteselected()

mi_selectnode(R2,0)
mi_selectnode(-R2,0)
mi_deleteselected()
mi_selectnode(R3,0)
mi_selectnode(-R3,0)
mi_deleteselected()

-- materialy silnika z biblioteki
mi_getmaterial("Air")
mi_getmaterial("M-19 Steel")
mi_getmaterial("N40")
mi_getmaterial("20 AWG")

-- obwody trzech faz uzwojen
mi_addcircprop("A", current, 1)
mi_addcircprop("B", current, 1)
mi_addcircprop("C", current, 1)

-- warunek brzegowy na zewnetrznej krawedzi
mi_addboundprop("Dirichlet", 0, 0, 0, 0, 0, 0, 0, 0, 0)
mi_selectarcsegment(0, R8)
mi_setarcsegmentprop(5, "Dirichlet", 0, 0)
mi_clearselected()

-- otwor srodkowy (wal) - powietrze
mi_addblocklabel(0, R1 * 0.5)
mi_selectlabel(0, R1 * 0.5)
mi_setblockprop("Air", 1, 1, "", 0, 0, 0)
mi_clearselected()

-- jarzmo i zeby stojana - stal
mi_addblocklabel((R1 + R2) * 0.5, 0)
mi_selectlabel((R1 + R2) * 0.5, 0)
mi_setblockprop("M-19 Steel", 1, 1, "", 0, 0, 0)
mi_clearselected()

-- szczelina powietrzna
mi_addblocklabel((R4 + R5) * 0.5, 0)
mi_selectlabel((R4 + R5) * 0.5, 0)
mi_setblockprop("Air", 1, 0.5, "", 0, 0, 0)
mi_clearselected()

-- jarzmo wirnika - stal (obraca sie z magnesami)
mi_addblocklabel((R6 + R7) * 0.5, 0)
mi_selectlabel((R6 + R7) * 0.5, 0)
mi_setblockprop("M-19 Steel", 1, 0.5, "", 0, 0, 0)
mi_clearselected()

-- obszar zewnetrzny - powietrze
mi_addblocklabel((R7 + R8) * 0.5, 0)
mi_selectlabel((R7 + R8) * 0.5, 0)
mi_setblockprop("Air", 1, 1, "", 0, 0, 0)
mi_clearselected()

-- przypisanie faz (A/B/C) i kierunkow pradu do zlobkow
phase_A = {"A","A","B","B","C","C","A","A","B","B","C","C",
           "A","A","B","B","C","C","A","A","B","B","C","C"}
dir_A   = { 1,  1,  1,  1,  1,  1, -1, -1, -1, -1, -1, -1,
             1,  1,  1,  1,  1,  1, -1, -1, -1, -1, -1, -1}

-- uzwojenia w zlobkach stojana
r_winding = (R2 + R3) * 0.5
slot_mid = (delta_inner + delta_outer) * 0.5
idx = 1
for n = 0, Ns-1 do
    local theta_c = (theta0_s + n*(360/Ns)) * pi / 180
    for s = -1, 1, 2 do
        local theta = theta_c + s * slot_mid
        local px = r_winding * cos(theta)
        local py = r_winding * sin(theta)
        mi_addblocklabel(px, py)
        mi_selectlabel(px, py)
        mi_setblockprop("20 AWG", 0, 0.5, phase_A[idx], 0, 0, dir_A[idx] * turns)
        mi_clearselected()
        idx = idx + 1
    end
end

-- magnesy trwale wirnika (namagnesowanie naprzemienne N-S)
r_magnet = (R5 + R6) * 0.5
for i = 0, Nr-1 do
    local base_deg = theta0_r + i * (360 / Nr)
    local angle_rad = (base_deg + 8) * pi / 180
    local px = r_magnet * cos(angle_rad)
    local py = r_magnet * sin(angle_rad)
    local mag_angle
    if (i - 2 * floor(i / 2)) == 0 then
        mag_angle = base_deg
    else
        mag_angle = base_deg + 180
    end
    mi_addblocklabel(px, py)
    mi_selectlabel(px, py)
    mi_setblockprop("N40", 1, 1, "", mag_angle, 0, 0)
    mi_clearselected()
end

-- wirnik jako grupa (magnesy + jarzmo) do obracania
mi_clearselected()
mi_selectcircle(0, 0, R7 + 1, 4)
mi_setgroup(ROTOR)
mi_clearselected()
mi_selectcircle(0, 0, R5 - 0.5, 4)
mi_setgroup(0)
mi_clearselected()

-- widok
mi_zoomnatural()

-- zapis modelu obok skryptu (nazwa wzgledna - bez podawania sciezki)
mi_saveas("silnik_wariant5.FEM")

-- zakres badania: kat polozenia wirnika
angle_start = 0
angle_stop  = 60
angle_step  = 2     -- krok katowy (mniejszy = wiecej punktow)

-- punkty odczytu indukcji w szczelinie
R_probe = (R4 + R5) / 2
n_probe = 180

-- plik wynikowy obok skryptu (nazwa wzgledna)
fp = openfile("wyniki.csv", "w")
write(fp, "kat_deg,moment_Nm,Bmax_szczelina_T,Bsr_szczelina_T\n")

-- ustawienie wirnika na kat poczatkowy
if angle_start ~= 0 then
    mi_selectgroup(ROTOR)
    mi_moverotate(0, 0, angle_start, 4)
    mi_clearselected()
end

-- petla: kolejne polozenia wirnika
a = angle_start
while a < angle_stop + 0.0001 do

    -- symulacja pola magnetycznego dla biezacego kata
    mi_analyze(1)
    mi_loadsolution()

    -- moment na wirniku
    mo_groupselectblock(ROTOR)
    T = mo_blockintegral(22)
    mo_clearblock()

    -- indukcja w szczelinie (max i srednia po obwodzie)
    Bmax = 0
    Bsum = 0
    k = 0
    while k < n_probe do
        ang = k * (360 / n_probe) * pi / 180
        A_pt, bx, by = mo_getpointvalues(R_probe * cos(ang), R_probe * sin(ang))
        Bmag = sqrt(bx*bx + by*by)
        if Bmag > Bmax then Bmax = Bmag end
        Bsum = Bsum + Bmag
        k = k + 1
    end
    Bavg = Bsum / n_probe

    mo_close()

    -- zapis wyniku do tabeli
    write(fp, a .. "," .. T .. "," .. Bmax .. "," .. Bavg .. "\n")

    -- obrot wirnika o krok
    mi_selectgroup(ROTOR)
    mi_moverotate(0, 0, angle_step, 4)
    mi_clearselected()
    a = a + angle_step
end

-- zakonczenie i komunikat
closefile(fp)
messagebox("Gotowe. Pliki silnik_wariant5.FEM i wyniki.csv zapisano w tym folderze.")
