#!/bin/bash
echo "--------------------------"
echo "User Name: LimYechan"
echo "Student Number: 12223802"
echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of action genre movies from 'u.item'"
echo "3. Get the average 'rating' of the movie identified by a specific 'movie id' from 'u.data'"
echo "4. Delete the 'IMDb URL' from 'u.item'"
echo "5. Get the data about users from 'u.user'"
echo "6. Modify the format of 'release date' in 'u.item'"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "--------------------------"

while true
do
	read -p "Enter your choice [ 1-9 ] " choice
	echo
	case $choice in
		1)
		read -p "Please enter 'movie id' (1~1682):" mid
		echo
		awk -v mid="$mid" -F '|' '$1 == mid { print $0 }' $1
		echo ;;

		2)
		read -p "Do you want to get the data of 'action' genre movies from 'u.item'? (y/n):" answer
		
		if [ "$answer" = "y" ]; then
			echo
			awk -F '|' 'BEGIN { count=0 } $7 == 1 && count<10 { printf("%d %s\n", $1, $2); count++ }' $1
		fi 
		echo ;;

		3)
		read -p "Please enter the 'movie id' (1~1682):" mid
		if [ $mid -ge 1 ] && [ $mid -le 1682 ]; then
			echo
			awk -v mid="$mid" -F '\t' 'BEGIN { sum=0; count=0 } $2 == mid { sum += $3; count++ } END {printf("average rating of %d: %.5f\n", mid, sum/count)}' $2
		else 
			echo "Invalid value"
		fi
		echo ;;


		4)
		read -p "Do you want to delete the 'IMDb URL' from 'u.item'?(y/n):" reply
		
		if [ "$reply" = "y" ]; then
			echo
			sed 's/http[^)]*)//g' $1 > u.item.new
			head -n 10 u.item.new
			rm u.item.new
		fi
		echo ;;
		
		5)
		read -p "Do you want to get the data about users from 'u.user'?(y/n):" answer
		
		if [ "$answer" = "y" ]; then
			echo
			awk -F '|' '$1<=10 {printf("user %d is %d years old %s %s\n", $1, $2, ($3 == "M" ? "male" : "female"), $4)}' $3
		fi
		echo ;;

		6)
		read -p "Do you want to Modify the format of 'release data' in 'u.item'?(y/n):" answer

		if [ "$answer" = "y" ]; then
			echo
			sed -E -e 's/-Jan-/-01-/g' -e 's/-Feb-/-02-/g' -e 's/-Mar-/-03-/g' -e 's/-Apr-/-04-/g' -e 's/-May-/-05-/g' -e 's/-Jun-/-06-/g' -e 's/-Jul-/-07-/g' -e 's/-Aug-/-08-/g' -e 's/-Sep-/-09-/g' -e 's/-Oct-/-10-/g' -e 's/-Nov-/-11-/g' -e 's/-Dec-/-12-/g' $1 > u.item.new
			sed -E -i -e 's/([0-9]{2})-([0-9]{2})-([0-9]{4})/\3\2\1/' u.item.new
			tail -n 10 u.item.new
			rm u.item.new
		fi
		echo ;;
		
		7)
		read -p "Please enter the 'user id'(1~943):" answer
		if [ $answer -ge 1 ] && [ $answer -le 943 ]; then
			echo
			awk -v answer="$answer" -F '\t' '$1 == answer { print $2 }' $2 > movieId.data
			sort -n -o movieId.data movieId.data
			awk 'NR==1 {printf("%d",$1);next} {printf("|%d", $1)} END {printf("\n")}' movieId.data
			echo 
			for i in {1..10}; do
			    pattern=$(sed -n "${i}p" movieId.data)
			    awk -v pattern="$pattern" -F '|' '$1 == pattern {printf("%d|%s\n", $1, $2)}' $1
			done
			rm movieId.data
		else
			echo
			echo "Invalid value"
		fi
		echo ;;
		

		8)
		read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'? (y/n): " answer
		if [ "$answer" = "y" ]; then
			awk -F '|' '$2<=29 && $2>=20 && $4=="programmer" { print $1 }' $3 > p.user
			lines=$(wc -l < p.user)
			for i in $(seq 1 $lines); do
				pattern=$(sed -n "${i}p" p.user)
				awk -v pattern="$pattern" -F '\t' '$1 == pattern {printf("%d %d\n",$2,$3)}' $2 >> p.data
			done
			for j in {1..1682}; do
				awk -v j="$j" 'BEGIN { sum=0;count=0 } $1 == j {sum += $2; count++} END { if ( count!=0 ) printf("%d %.5f\n", j, sum/count)}' p.data
			done
			rm p.user
			rm p.data
		fi
		
		echo;;

		9)
		echo "Bye!"
		echo
		exit 0 ;;

		*)
		exit 1 ;;
	esac
done

