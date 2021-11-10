#!/bin/bash
#cd Desktop/VSCodeProjects/BashScripts

#Hier sei nochmal angemerkt, dass ich das Skript in ein paar Stunden ohne Erfahrung geschrieben habe. Shell Scripts / Bash ist einfach nur mega akward und veraltet.
#Vieles ist bestimmt richtig unnötig oder überflüssig gestaltet, ABER alles funktioniert, so wie es soll, von daher pff.
#Never change a running system I guess :'D
#Einziges Ding ist noch, dass die Argumente in der richtigen Reihenfolge genannt werden müssen, weiß noch nicht, wie ich das ändern kann, 
#dass immer erst a, dann s, dann d usw. erfolgt


#Variablen deklarieren -> Flags dazu da, um zu schauen, welche Optionen bereits ausgeführt wurden und welche nicht
declare -i a_flag=0
declare -i s_flag=0
declare -i d_flag=0
declare -a file_names

#Aktuelles Datum
currentDate=$(date +"%Y-%m-%d %H:%M")

#Befülle ein Array mit den Dateinamen -> dynamisch, da nicht immer bekannt, wie viele Dateien und welche Namen.
for ARG in "$@"; do
    firstCharacter=${ARG:0:1}
	#Nicht die beste Möglichkeit, aber ausreichend -> alles was keine Flag ist "-x" (am Bindestrich zu erkennen) wird in das Array gepackt
    if [ ! "$firstCharacter" = "-" ]
    then
        file_names+=("$ARG.txt")
    fi
done

#Flag-Menü
while getopts ":asd" opt; do
    case $opt in
        a)
            cat "${file_names[@]}" > Telefonliste_Gesamt.txt
            sort -o Telefonliste_Gesamt.txt Telefonliste_Gesamt.txt
            a_flag=1
            ;;
        s)	#Konsolenausgabe der Aktionen
            s_flag=1

			#d_flag Überprüfung eigentlich unnötig, aber keine andere schöne Idee gehabt :)
            if [ $a_flag = 1 ] && [ $s_flag = 1 ] && [ $d_flag = 1 ]
            then
                echo "---------------------"
                echo -e "<Matrikel-Nr. 692853> $currentDate \t Telefonliste \t Seite 1"
                cat Telefonliste_Gesamt.txt
                echo "---------------------"
            fi
            ;;
        d)	#Zweispaltige Option
            if [ $a_flag = 1 ]
            then
				#Bringe eine einspaltige sortierte Liste zu einer zweispaltigen -> mittels Paste
				#Eine Temp-Datei wird erstellt, die alte gelöscht und die Temp-Datei umbenannt
                paste - - < Telefonliste_Gesamt.txt | column -s $'\t\t\t' -t > temp.txt
                rm Telefonliste_Gesamt.txt
                mv temp.txt Telefonliste_Gesamt.txt
                if [ $s_flag -eq 1 ] 
                then
                    echo "---------------------"
                    echo -e "<Matrikel-Nr. 692853> $currentDate \t Telefonliste \t Seite 1"
                    column Telefonliste_Gesamt.txt -c 75
                    echo "---------------------"
                fi
                exit 1
            fi

            if [ $a_flag -eq 0 ]
            then
                for file in "${file_names[@]}"; do
                    file_short=${file%????}

                    cat "$file" > "${file_short}_Sorted.txt"
                    sort -o "${file_short}_Sorted.txt" "${file_short}_Sorted.txt"

                    paste - - < "${file_short}_Sorted.txt" | column -c 75 > temp.txt
                    rm "${file_short}_Sorted.txt"
                    mv temp.txt "${file_short}_Sorted.txt"

                done

                if [ $s_flag -eq 1 ] 
                then
                    for file in "${file_names[@]}"; do
                        file_short=${file%????}
                        echo "---------------------"
                        echo "${file_short}_Sorted.txt"
                        echo "---------------------"
                        column "${file_short}_Sorted.txt" -c 75

                    done
                fi
                exit 1
            fi

            d_flag=1
            ;;
        \?)
            echo "---------------------"
            echo "<Matrikel-Nr. 692853>"
            echo "Die angegebene Option $OPTARG ist nicht erlaubt."
            echo "---------------------"
            exit 1
            ;;

    esac
done

#Wenn keine Flags oder Argumente (Dateinamen) gegeben sind, bricht das Programm ab.
if [ $a_flag -eq 0 ] && [ $s_flag -eq 0 ] && [ $d_flag -eq 0 ] && [[ ! ${file_names[*]} ]]
then
    echo "---------------------"
    echo "<Matrikel-Nr. 692853>"
    echo "Aufruf der Prozedur erfolgte ohne (gültige) Parameter! Fehler."
    echo "---------------------"
    exit 1
fi

if [ $a_flag -eq 0 ]
then
    for file in "${file_names[@]}"; do
        file_short=${file%????}

        cat "$file" > "${file_short}_Sorted.txt"
        sort -o "${file_short}_Sorted.txt" "${file_short}_Sorted.txt"
    done

    if [ $s_flag -eq 1 ]
    then
        echo "---------------------"
        echo -e "<Matrikel-Nr. 692853> $currentDate \t Telefonliste \t Seite 1"
        for file in "${file_names[@]}"; do
            file_short=${file%????}
            echo "---------------------"
            echo "${file_short}_Sorted.txt"
            echo "---------------------"
            cat "${file_short}_Sorted.txt"
        done
        exit 1
    fi
fi

#Keine Ahnung, oben hat mich die Situation überfordert -> Notlösung I guess?
if [ $a_flag -eq 1 ] && [ $s_flag -eq 1 ]
then
    echo "---------------------"
    echo -e "<Matrikel-Nr. 692853> $currentDate \t Telefonliste \t Seite 1"
    cat Telefonliste_Gesamt.txt
    echo "---------------------"
    exit 1
fi
