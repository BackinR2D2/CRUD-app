#!/bin/bash
PS3="Selecteaza element [1-6]: "
#Prompt pentru select in bash
items=("Adauga inregistrare" "Sterge inregistrare" "Afisare situatie student" "Actualizeaza inregistrare" "Afisare studenti dupa medie" "Afisare studenti dupa inaltime")

# ID,nume,email,medie,inaltime

emailRegex="^[a-z0-9!#\$%&'+/=?^_\`{|}~-]+(\.[a-z0-9!#$%&'+/=?^_\`{|}~-]+)@([a-z0-9]([a-z0-9-][a-z0-9])?\.)+[a-z0-9]([a-z0-9-]*[a-z0-9])?\$"

function creareDB {
        # Verificare daca exista fisierul folosind -f (file)
        if [ -f "./db.csv" ]
        then
                echo "Exista fisier"
        else
                echo "Nu exista fisier"
                touch ./db.csv
                echo "ID,nume,email,medie,inaltime" > ./db.csv
                echo "A fost initializat fisierul CSV"
                echo ""
        fi
}

function adaugare {
        echo "Adaugare Inregistrare"
        echo "Introduceti datele noii inregistrari: "
        echo ""
        read -p 'Nume: ' nume # -p: prompt - iti permite sa adaugi un prompt pentru a informa utilizatorul
        read -p 'Email: ' email
        read -p 'Medie: ' medie
        read -p 'Inaltime (in cm): ' inaltime

        local inregistrareValida=0 # variabila locala nu poate fi accesata la nivel global

        # operatorul =~ este utilizat pentru a cauta tipare cu expresiile regulate
        if [[ $email =~ $emailRegex ]]
        then
                (( inregistrareValida++ ))
        else
                echo "Email gresit"
        fi

        if [[ $medie -le 10 && $medie -ge 1 ]]
        then
                (( inregistrareValida++ ))
        else
                echo "Medie gresita"
        fi

        len=`expr length "$inaltime"` # Verifica numarul de caractere a variabilei inaltime
        inaltimeRegex='^[0-9]+$'
        if [[ $len -eq 3 && $inaltime =~ $inaltimeRegex ]]
        then
                (( inregistrareValida++ ))
        else
                echo "Inaltime gresita"
        fi

        if ! grep -q $email "db.csv";  # -q pentru a nu afisa nimic
        then
                (( inregistrareValida++ ))
        else
                echo "Email existent"
        fi

        if [[ $inregistrareValida -eq 4 ]]
        then
                idGenerat=$(tail -n1 db.csv | cut -d',' -f1) # Este luat ultimul ID din fisierul curent si se incrementeaza valoarea
                # -n este o optiune care specifica numarul de linii pe care dorim sa le afisam, iar 1 indica faptul ca dorim sa afisam ultima linie
                (( idGenerat++ ))
                echo "$idGenerat,$nume,$email,$medie,$inaltime" >> db.csv # Adauga inregistrarea in fisier fara sa suprascrie fisierul
                echo "Inregistrare adaugata cu succes"
        else
                echo "Inregistrare gresita"
        fi
}

function sterge {
        echo "Stergere Inregistrare"
        read -p 'Introduceti ID pentru a sterge inregistrare: ' id
        local existaInregistrare=0
#IFS=internal field separator
        while IFS=',' read -ra arr; do
                if [[ ${arr[0]} == $id ]]
                then
                        (( existaInregistrare++ ))
                fi
        done < "./db.csv"
        if [[ $existaInregistrare -eq 1 ]]
        then
                # Sterge randul care contine ID-ul precizat
                # awk & sed nu permit suprascrierea aceluiasi fisier, trebuie utilizat un fisier temporar
                grep -v "^$id," "./db.csv" > ./temp.csv # -v afiseaza continutul excluzand randul care incepe cu ID-ul precizat
                mv ./temp.csv ./db.csv
                echo "Inregistrare stearsa cu succes"
        else
                echo "Inregistrarea cu ID-ul precizat nu exista in fisier"
        fi
}

function afisare {
        echo "Afisarea situatiei universitare si posibilitatea inscrierii in echipa de baschet"
        read -p 'Introduceti ID-ul: ' id
        while IFS="," read -r ID nume email medie inaltime
        do
         if [[ $ID -eq $id && $medie -gt 5 && $inaltime -ge 185 ]]
         then
                echo "$nume poate intra in echipa de baschet (Media > 5 si inaltime >= 185)"
         elif [[ $ID -eq $id && $medie -gt 5 && $inaltime -lt 185 ]]
         then
                echo "$nume nu este restant(a) dar nu poate intra in echipa de baschet (Inaltime < 185)"
         elif [[ $ID -eq $id && !$medie -gt 5 && !$inaltime -ge 185 ]]
         then
                echo "$nume este restant(a) si nu poate intra in echipa de baschet"
         elif [[ $ID -eq $id && $medie -lt 5 && $inaltime -lt 185 ]]
         then
                echo "$nume este restant(a)"
         fi
        done < <(tail -n +2 "./db.csv")
}

function actualizare {
        echo "Actualizarea inregistrarii dupa ID"
        # Utilizam un fisier temporar CSV pentru a stoca noile informatii, dupa care mutam continutul fisierului temporar in fisierul principal CSV
        echo "ID,nume,email,medie,inaltime" > temp.csv # Initializare fisier temporar CSV
        read -p 'Introduceti ID-ul pentru a actualiza informatiile unui student: ' id
        local existaInregistrare=0 # Folosit pentru a stabili daca exista sau nu inregistrare cu ID-ul precizat
        local esteModificat=0 # Folosit pentru a contoriza o modificare exacta
        while IFS="," read -r ID nume email medie inaltime
        do
                if [[ $id -eq $ID ]]
                then
                        # -u 1 - citeste de la stdout
                        (( existaInregistrare++ ))
                        read -u 1 -p "Introduceti noul nume (Enter daca nu doriti sa modificati): " noulNume
                        read -u 1 -p "Introduceti noua adresa de mail (Enter daca nu doriti sa modificati): " noulEmail
                        read -u 1 -p "Introduceti noua medie (Enter daca nu doriti sa modificati): " nouaMedie
                        read -u 1 -p "Introduceti noua inaltime (Enter daca nu doriti sa modificati): " nouaInaltime
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
        if [[ $existaInregistrare -eq 1 && $esteModificat -gt 0 ]]
        then
                echo "Actualizat cu succes"
        else
                echo "ID-ul nu corespunde niciunei inregistrari sau date de intrare gresite"
        fi
}

function afisareDupaMedie {
        echo ""
        echo "Afisare dupa medie: "
        sort -k4 -n -t, db.csv # -k4 sorteaza dupa a patra coloana (medie), -n sorteaza lexicografic, -t, delimiteaza dupa virgula
        echo ""
}

function afisareDupaInaltime {
        echo ""
        echo "Afisare dupa inaltime: "
        sort -k5 -n -t, db.csv
        echo ""
}

creareDB # Apelare functie pentru a crea fisierul CSV daca nu exista
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
            *) echo "Optiune necunoscuta"; break;
        esac
    done
done