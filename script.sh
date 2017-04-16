#!/bin/sh

getValues () {
	for i in $1
		do
					path=`readlink -f $i`
					name=`basename $i`
					perm=`ls -ld $i | awk '{ print $1 }' | cut -c 2-`
					type=`ls -ld $i | awk '{ print $1 }' | cut -c -1`
					owner=`ls -ld $i | awk '{ print $3 }'`
					group=`ls -ld $i | awk '{ print $4 }'`
					modTime=`stat --printf="%y" $i`
					changeTime=`stat --printf="%z" $i`
			
					if [ $type = "d" ]
						then
							l=$i
							l=$l"/*"
							echo "$path $name $perm $owner $group $type $modTime $changeTime" 
							getValues "$l" "$2"
			
					elif [ $type != "d" ]
						then type="file"
							hash=`md5sum $i | awk '{print $1 }'`
							count=`wc -m $i | awk '{print $1 }'`
							echo "$path $name $perm $owner $group $type $modTime $changeTime $count $hash"
					fi

	done >> $2
}

generateFile() {
	>"$2"
	getValues "$1" "$2"
	echo "Validation File Created \n"
}

testCommands() {
	#echo $(grep /home/seed/Assignment/testFolder/branchFolder/efe.txt /home/seed/Assignment/verificationFile.txt)
	echo "\n"
	echo $(grep /home/seed/Assignment/testFolder/branchFolder/efe.txt /home/seed/Assignment/verificationFile.txt | awk '{ printf $7 "\t" $8 "\t" $9 }') ]
		
}

checkNew() {
	echo ""
	for i in $1
		do
			path=`readlink -f $i`
			type=`ls -ld $i | awk '{ print $1 }' | cut -c -1`
			if ! grep -q "$path" /home/seed/Assignment/verificationFile.txt
				then
					echo "New File Added: $path"
					addCount=`expr $addCount + 1`
			fi
			
			

			if [ $type = "d" ]
				then
					l=$i
					l=$l"/*"
					checkNew "$l"
			fi		
			
	done

	
}

checkDelete(){
	while read line
		do
			path=$(echo "$line" | awk '{ printf $1 }')
			if [ ! -e $1 ]
				then
					echo "File $name has been deleted or changed names \n"
					delCount=`expr $delCount + 1`
			fi
	done < verificationFile.txt
	</dev/null
}

checkFile() {
	
					echo "\n$1 modifications:"
					if [ "$name" != $(grep "^$1\s" /home/seed/Assignment/verificationFile.txt | awk '{ printf $2 }') ]
						then
							echo " $name's name has been modified to: $name"
							modified=true
					fi
					if [ "$perm" != $(grep "^$1\s" /home/seed/Assignment/verificationFile.txt | awk '{ printf $3 }') ]
						then
							echo " $name's permissions have been modified to: $perm"
							modified=true
					fi
					if [ "$owner" != $(grep "^$1\s" /home/seed/Assignment/verificationFile.txt | awk '{ printf $4 }') ]
						then
							echo " $name's owner has been modified to: $owner"
							modified=true
					fi
					if [ "$group" != $(grep "^$1\s" /home/seed/Assignment/verificationFile.txt | awk '{ printf $5 }') ]
						then
							echo " $name's group has been modified to: $group"
							modified=true
					fi
					if [ "$type" != $(grep "^$1\s" /home/seed/Assignment/verificationFile.txt | awk '{ printf $6 }') ]
						then
							echo " $name's type has been modified to: $type"
							modified=true
					fi
					if [ "$modTime" != "$(grep "^$1\s" /home/seed/Assignment/verificationFile.txt | awk '{ printf $7 " "$8 " " $9 }')" ]
						then
							echo "$modTime" 
							test=$(grep "^$1\s" /home/seed/Assignment/verificationFile.txt)
							echo $($test | '{ printf $7 " "$8 " " $9 }')				
							modified=true
					fi
					if [ "$changeTime" != "$(grep "^$1\s" /home/seed/Assignment/verificationFile.txt | awk '{ printf $10 " "$11 " " $12 }')" ]
						then
							echo " $name's status change time has been modified to: $changeTime"
							modified=true
					fi
					
					if $2
						then
							if [ "$count" != $(grep "^$path\s" /home/seed/Assignment/verificationFile.txt | awk '{ printf $13 }') ]
								then
									echo " $name's word count has been modified to: $changeTime"
									echo "$count"
									echo $(grep "^$path\s" /home/seed/Assignment/verificationFile.txt | awk '{ printf $13 }')
									modified=true
							fi
							if [ "$hash" != $(grep "^$path\s" /home/seed/Assignment/verificationFile.txt | awk '{ printf $14 }') ]
								then
									echo " $name's hash has been modified to: $changeTime"
									modified=true
							fi
					fi

					if ! $modified
						then
							echo "No Changes. \n"
					fi

}

getChanges () {
	for i in $1
		do
					totCount=`expr $totCount + 1`
					modified=false
					path=`readlink -f $i`
					name=`basename $i`
					perm=`ls -ld $i | awk '{ print $1 }' | cut -c 2-`
					type=`ls -ld $i | awk '{ print $1 }' | cut -c -1`
					owner=`ls -ld $i | awk '{ print $3 }'`
					group=`ls -ld $i | awk '{ print $4 }'`
					modTime=`stat --printf="%y" $i`
					changeTime=`stat --printf="%z" $i`
			
					if [ $type = "d" ]
						then
							l=$i
							l=$l"/*"
							checkFile "$path" "false"
							getChanges "$l"
			
					elif [ $type != "d" ]
						then type="file"
							hash=`md5sum $i | awk '{print $1 }'`
							count=`wc -m $i | awk '{print $1 }'`
							checkFile "$path" "true"
					fi

	done 
}

compareToFile()	{
	delCount=0
	addCount=0
	totCount=0
	chngCount=0
	
	getChanges "$1"

	checkDelete
	checkNew "$1"
	
	echo "\nTotal Files Checked: $totCount"
	echo "Total Files Changed: $chngCount"
	echo "Total Files Added: $addCount"
	echo "Total Files Deleted: $delCount \n"
}

while true; do
	read -p "Commands:`echo '\n '`-c to generate validation file.`echo '\n '`-o to check for changes`echo '\n '`-exit to exit application`echo '\n '`Enter a Command: " inp
	case $inp in
	-c ) generateFile "./testFolder/*" "verificationFile.txt"; ;; 
	-o ) compareToFile "./testFolder/*"; ;;
	-t ) testCommands; ;;
	-e ) exit;;
	* ) echo "na";;
esac
done



