#! /bin/dash

usage () {
	echo 'Usage: generateMakefile.sh name [directory]
where:
 	name is the name of the program
 	directory is the source directory'
}
find_dep () {
		if [ ! -f $1 ]; then
			return;
		fi
		DEPS="$DEPS $(grep '#include' "$1" | sed -n 's/#include "//;s/"//p' | tr '\n' ' ')"

		NBRDEPS=$(echo $DEPS | wc -w)
		COMPT=0
		while [ $COMPT -ne $NBRDEPS ];do
			COMPT=$(($COMPT+1))
			TEMPDEPS=$(echo $DEPS | cut -d ' ' -f $COMPT)
			if [ "$TEMPDEPS" = "$1" ]; then
				return;
			fi
			find_dep $TEMPDEPS
		done
}

if [ $# -ne 2 ]; then
	echo 'Incorrect number arguments' >&2
	usage >&2
	exit 1
fi
if [ ! -d $2 ]; then
	echo 'Error :' $2 'doesn’t exist or isn’t a directory' >&2
	usage >&2
	exit 2
fi

PROGRAM="$1"
ROOTDIR="$2"

cd "$ROOTDIR"


# parcourir fichier c un par un et voir indépendance
# 
CFILES=$(ls *.c)
NBRCFILES=$(echo "$CFILES" | wc -w)
COMPTEUR=0
DEPS=""

if [ "$NBRCFILES" -eq 0 ]; then
	echo 'Error : no .c files' >&2
	usage >&2
	exit 3
fi

#sed -n 's/#include "//;s/"//p'
while [ "$COMPTEUR" -ne "$NBRCFILES" ]; do
	COMPTEUR=$(($COMPTEUR+1))
	TEMP=$(echo $CFILES | cut -d ' ' -f "$COMPTEUR")
	find_dep $TEMP
done
DEPS=$(echo $DEPS | tr ' ' '\n' | uniq)
echo $DEPS

touch Makefile

echo '# generate by generateMakefile.sh' > Makefile



exit 0