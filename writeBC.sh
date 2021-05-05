#!/bin/sh

function writeBCvalue(){
fileName=$1
awk -v fileName=$fileName '{
	bcName=$1;
	bcType=$2;
	switch(fileName){
		case "U":
			switch(bcType){
				case "wall":
					print bcName;
					print "{"
					print "   type fixedValue;"
					print "   value uniform (0 0 0);"
					print "}"
					break;
				case "pressure-outlet":
					print bcName;
					print "{"
					print "   type zeroGradient;"
					print "}"
					break;
				case "velocity-inlet":
					print bcName;
					print "{"
					print "   type surfaceNormalFixedValue;";
					printf "  refValue uniform ";
					printf -1*$3;
					printf ";\n"
					print "}"
					break;
				default:
					break;
			}
			break;
		case "p":
			switch(bcType){
				case "wall":
				case "velocity-inlet":
					print bcName;
					print "{"
					print "   type zeroGradient;"
					print "}"
					break;
				case "pressure-outlet":
					print bcName;
					print "{"
					print "   type fixedValue;"
					printf "  value uniform ";
					printf    $3";\n";
					print "}"
					break;
				default:
					break;
			}
			break;
		case "k":
			switch(bcType){
				case "wall":
					print bcName;
					print "{"
					print "   type kqRWallFunction;"
					print "   value $internalField;"
					print "}"
					break;
				case "pressure-outlet":
					print bcName;
					print "{"
					print "   type zeroGradient;"
					print "}"
					break;
				case "velocity-inlet":
					print bcName;
					print "{"
					print "   type turbulentIntensityKineticEnergyInlet;";
					printf "   intensity ";
					printf $5;
					printf ";\n"
					print "   value $internalField;"
					print "}"
					break;
				default:
					break;
			}
			break;
		case "epsilon":
			switch(bcType){
				case "wall":
					print "  " bcName;
					print "  {"
					print "   type epsilonWallFunction;"
					print "   value $internalField;"
					print "  }"
					break;
				case "pressure-outlet":
					print "  " bcName;
					print "  {"
					print "   type zeroGradient;"
					print "  }"
					break;
				case "velocity-inlet":
					print "  " bcName;
					print "  {"
					print "   type turbulentMixingLengthDissipationRateInlet;";
					printf "   mixingLength ";
					printf $7;
					printf ";\n"
					print "   value $internalField;"
					print "  }"
					break;
				default:
					break;
			}
			break;
		case "nut":
			switch(bcType){
				case "velocity-inlet":
				case "pressure-outlet":
					print "  " bcName;
					print "  {"
					print "   type calculated;"
					print "   value uniform 0;"
					print "  }"
					break;
				case "wall":
					print "  " bcName;
					print "  {"
					print "   type nutkWallFunction;"
					print "   Cmu             0.09;"
					print "   kappa           0.41;"
					print "   E               9.8;"
					print "   value           uniform 0;"
					print "  }"
					break;
				default:
					break;
			}
			break;
		default:
			print "defualt";
			break;
	}
}' bc_sample.txt 
} 

function writeHeader() {
	fileName=$1
	echo "FoamFile"
	echo "{"
	echo "    version     2.0;"
	echo "    format      ascii;"

	case $fileName in
	U)
	echo "    class       volVectorField;"
	;;
	epsilon|k|nut|p)
	echo "    class       volScalarField;"
	;;
	*)
	echo ""
	;;
	esac

    echo "    object      $fileName;"
    echo "}"
	echo "" 

	case $fileName in
	U)
	echo "dimensions [0 1 -1 0 0 0 0];"
    echo "internalField uniform (0 0 0);"
	;;
	epsilon)
	echo "dimensions [0 2 -3 0 0 0 0];"
    echo "internalField uniform 0.000431;"
	;;
	k)
	echo "dimensions [0 2 -2 0 0 0 0];"
    echo "internalField uniform 0.00015; // U = 0.2;"
	;;
	nut)
	echo "dimensions [0 2 -1 0 0 0 0];"
    echo "internalField uniform 0;"
	;;
	p)
	echo "dimensions [0 2 -2 0 0 0 0];"
    echo "internalField uniform 0;" 
	;;
	*)
	echo ""
	;;
	esac

    return 0
}
fileNames="
U
p
k
epsilon
nut
"

rm -rf 0
mkdir 0

for fileName in $fileNames
do
  writeHeader $fileName   > $fileName
  echo "boundaryField"   >> $fileName
  echo "{"               >> $fileName
  writeBCvalue $fileName >> $fileName
  echo "}"               >> $fileName
  sleep 0.1s
  mv $fileName 0/
done
