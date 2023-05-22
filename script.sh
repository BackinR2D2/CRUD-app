#!/bin/bash
PS3="Selecteaza element [1-7]: "
items=("Adauga inregistrare" "Sterge inregistrare" "Afisare situatie student" "Actualizeaza inregistrare" "Afisare studenti dupa medie" "Afisare cei mai inalti 3 studenti")
 
emailRegex="^[a-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_\`{|}~-]+)*@([a-z0-9]([a-z0-9-]*[a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"
 
red='\033[0;31m'
nc='\033[0m'
green='\033[0;32m'
 
function creareDB {
        if [ -f "./db.csv" ]
        then
                echo ""
                echo -e "${green}Exista fisier!${nc}"
                echo ""
                sleep 0.5
                echo "Initializare"
                echo ""
                sleep 1
        else
                echo ""
                echo -e "${red}Nu exista fisier!${nc}"
                echo ""
                sleep 0.5
                touch ./db.csv
                echo "ID,nume,email,medie,inaltime" > ./db.csv
                sleep 1
                echo -e "${green}A fost initializat fisierul CSV!${nc}"
                echo ""
        fi
}
 
function adaugare {
        echo "Adaugare Inregistrare"
        echo "Introduceti datele noii inregistrari: "
        echo ""
        read -p 'Nume: ' nume
        read -p 'Email: ' email
        read -p 'Medie: ' medie
        read -p 'Inaltime (in cm): ' inaltime
        echo ""
        local inregistrareValida=0
        sleep 0.3
        if [[ $nume != "" ]]
        then
                (( inregistrareValida++ ))
        else
                echo -e "${red}Inregistrare imposibila fara un nume!${nc}"
                echo ""
        fi
        sleep 0.3
        if [[ $email =~ $emailRegex ]]
        then
                (( inregistrareValida++ ))
 
        fi
 
        if [[ $email != "" ]] && ! grep -q $email "db.csv";
        then
                (( inregistrareValida++ ))
        else
                echo -e "${red}Email existent sau invalid!${nc}"
                echo ""
        fi
        sleep 0.3
        if [[ $medie -le 10 && $medie -ge 1 ]]
        then
                (( inregistrareValida++ ))
        else
                echo -e "${red}Medie gresita sau invalida!${nc}"
                echo ""
        fi
        sleep 0.3
        len=`expr length "$inaltime"`
        inaltimeRegex='^[0-9]+$'
        if [[ $len -eq 3 && $inaltime =~ $inaltimeRegex ]]
        then
                (( inregistrareValida++ ))
        else
                echo -e "${red}Inaltime gresita sau invalida!${nc}"
                echo ""
        fi
        sleep 0.3
        if [[ $inregistrareValida -eq 5 ]]
        then
                idGenerat=$(tail -n1 db.csv | cut -d',' -f1)
                (( idGenerat++ ))
                echo "$idGenerat,$nume,$email,$medie,$inaltime" >> db.csv
                echo -e "${green}Inregistrare adaugata cu succes!${nc}"
                echo ""
        else
                echo -e "${red}Inregistrare gresita!${nc}"
                echo ""
        fi
}
 
function sterge {
        echo ""
        echo "Stergere Inregistrare"
        echo ""
        read -p 'Introduceti ID pentru a sterge inregistrare: ' id
        sleep 0.5
        echo ""
        local existaInregistrare=0
        while IFS=',' read -ra arr; do
                if [[ ${arr[0]} == $id ]]
                then
                        (( existaInregistrare++ ))
                fi
        done < "./db.csv"
        if [[ $existaInregistrare -eq 1 ]]
        then
                grep -v "^$id," "./db.csv" > ./temp.csv
                mv ./temp.csv ./db.csv
                echo -e "${green}Inregistrare stearsa cu succes${nc}"
                echo ""
        else
                echo -e "${red}Inregistrarea cu ID-ul precizat nu exista in fisier${nc}"
                echo ""
        fi
}
 
function afisare {
        echo ""
        echo "Afisarea situatiei universitare si posibilitatea inscrierii in echipa de baschet"
        echo ""
        read -p 'Introduceti ID-ul: ' id
        local existaID=0
        sleep 0.5
 
        while IFS="," read -r ID nume email medie inaltime
        do
         if [[ $ID -eq $id ]]
         then
                (( existaID++ ))
         fi
        done < <(tail -n +2 "./db.csv")
 
        if  [[ $existaID -eq 0 ]]
         then
                echo ""
                echo -e "${red}ID-ul introdus este gresit sau nu exista${nc}"
                echo ""
        else
                while IFS="," read -r ID nume email medie inaltime
                do
                        if [[ $ID -eq $id && $medie -gt 5 && $inaltime -ge 185 ]]
                        then
                                echo ""
                                echo -e "${green}$nume poate intra in echipa de baschet (Media > 5 si inaltime >= 185)${nc}"
                                echo ""
                        elif [[ $ID -eq $id && $medie -gt 5 && $inaltime -lt 185 ]]
                        then
                                echo ""
                                echo -e "${green}$nume nu este restant(a) ${nc}${red}dar nu poate intra in echipa de baschet (Inaltime < 185)${nc}"
                                echo ""
                        elif [[ $ID -eq $id && !$medie -gt 5 && !$inaltime -ge 185 ]]
                        then
                                echo ""
                                echo -e "${red}$nume este restant(a) si nu poate intra in echipa de baschet${nc}"
                                echo ""
                        elif [[ $ID -eq $id && $medie -lt 5 && $inaltime -lt 185 ]]
                        then
                                echo ""
                                echo -e "${red}$nume este restant(a)${nc}"
                                echo ""
                        fi
 
                done < <(tail -n +2 "./db.csv")
        fi
}
 
function actualizare {
        echo ""
        echo "Actualizarea inregistrarii dupa ID"
        echo ""
        echo "ID,nume,email,medie,inaltime" > temp.csv
        echo ""
        read -p 'Introduceti ID-ul pentru a actualiza informatiile unui student: ' id
        echo ""
        sleep 0.5
        local existaInregistrare=0
        local esteModificat=0
        while IFS="," read -r ID nume email medie inaltime
        do
                if [[ $id -eq $ID ]]
                then
                        (( existaInregistrare++ ))
                        read -u 1 -p "Introduceti noul nume (Enter daca nu doriti sa modificati): " noulNume
                        echo ""
                        read -u 1 -p "Introduceti noua adresa de mail (Enter daca nu doriti sa modificati): " noulEmail
                        echo ""
                        read -u 1 -p "Introduceti noua medie (Enter daca nu doriti sa modificati): " nouaMedie
                        echo ""
                        read -u 1 -p "Introduceti noua inaltime (Enter daca nu doriti sa modificati): " nouaInaltime
                        echo ""
                        local noulNumeTemp=""
                        local noulEmailTemp=""
                        local nouaMedieTemp=""
                        local nouaInaltimeTemp=""
 
                        if [[ -n "$noulNume" ]]
                        then
                                noulNumeTemp=$noulNume
                                (( esteModificat++ ))
                        else
                                noulNumeTemp=$nume
                        fi
 
                        if [[ -n "$noulEmail" && $noulEmail =~ $emailRegex ]] && ! grep -q "$noulEmail" "./db.csv"
                        then
                                noulEmailTemp=$noulEmail
                                (( esteModificat++ ))
                        else
                                noulEmailTemp=$email
                        fi
 
                        if [[ -n "$nouaMedie" && $nouaMedie -le 10 && $nouaMedie -ge 1 ]]
                        then
                                nouaMedieTemp=$nouaMedie
                                (( esteModificat++ ))
                        else
                                nouaMedieTemp=$medie
                        fi
 
                        len=`expr length "$nouaInaltime"`
                        inaltimeRegex='^[0-9]+$'
                        if [[ -n "$nouaInaltime" && $len -eq 3 && $nouaInaltime =~ $inaltimeRegex ]]
                        then
                                nouaInaltimeTemp=$nouaInaltime
                                (( esteModificat++ ))
                        else
                                nouaInaltimeTemp=$inaltime
                        fi
                        echo "$ID,$noulNumeTemp,$noulEmailTemp,$nouaMedieTemp,$nouaInaltimeTemp" >> ./temp.csv
                else
                        echo "$ID,$nume,$email,$medie,$inaltime" >> ./temp.csv
                fi
        done < <(tail -n +2 "db.csv")
        mv ./temp.csv ./db.csv
        sleep 0.5
        if [[ $existaInregistrare -eq 1 && $esteModificat -gt 0 ]]
        then
                echo -e "${green}Actualizat cu succes${nc}"
                echo ""
        else
                echo -e "${red}ID-ul nu corespunde niciunei inregistrari sau exista date de intrare gresite${nc}"
                echo ""
        fi
}
 
function afisareDupaMedie {
        echo ""
        echo "Afisare dupa medie: "
        sleep 0.5
        echo ""
        sort -k4 -n -t, db.csv | tail -n +2
        echo ""
}
 
function afisareDupaInaltime {
        echo ""
        line_count=$(($(wc -l < db.csv) - 1))
        if [[ $line_count -lt 3 ]]
        then
                echo "Cei mai inalti ${line_count} studenti sunt: "
        else
                echo "Cei mai inalti 3 studenti sunt: "
        fi
        sleep 0.5
        echo ""
        sort -k5 -n -r -t, db.csv | head -n -1 | cut -d',' -f2,5 | head -n 3
        echo ""
}
 
creareDB
while true; do
    select item in "${items[@]}" Termina
    do
        case $REPLY in
            1) adaugare; break;;
            2) sterge; break;;
            3) afisare; break;;
            4) actualizare; break;;
            5) afisareDupaMedie; break;;
            6) afisareDupaInaltime; break;;
            $((${#items[@]}+1))) echo "Program terminat"; break 2;;
            *) echo -e "${red}Optiune necunoscuta!${nc}"; break;
        esac
    done
done