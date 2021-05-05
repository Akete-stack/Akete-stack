#!/bin/sh

cat << EOS
FoamFile
{
    version   2.0;
    format    ascii;
    class     dictionary;
    location  "system";
    object    meshDict;
}
EOS

awk 'BEGIN{
        numRefine=0;
        numPatch=0;
    }
    {
        option = $1;
        switch(option){
            case "INFILENAME":
                surfaceFile=$2
                break;
            case "BASEH":
                maxCellSize=$2
                break;
            case "LOCALREFINEMENTDEFINITION":
                numRefine++;
                LocalRefineName[numRefine]=$2;
                LocalRefineLevel[numRefine]=$3;
                break;
            case "Patch":
                numPatch++;
                patchName[numPatch]=$2;
                break;
        }
    }
    END{
        print ""
        print "surfaceFile \"" surfaceFile "\";";
        print ""
        print "maxCellSize "maxCellSize";";
        print ""
        print "localRefinement"
        print "{"
        for(i=1; i<=numRefine; i++){
            localRefinement
            print "    \""LocalRefineName[i]"\"";
            print "    {";
            printf "      cellSize ";
            printf maxCellSize/(2**LocalRefineLevel[i]);
            printf ";\n"
            print "    }";
        }
        print "}";
        print "renameBoundary"
        print "{"
        print "//  defaultName     fixedWalls;"
        print "  defaultType     wall;"
        print "  newPatchNames"
        print "  {";
        for(i=1; i<=numPatch; i++){
            print "    \""patchName[i]"\"";
            print "      {";
            print "       type patch;"
            print "       newName " patchName[i] ";";
            print "      }"
        }
    print "    }";
    print "  }"
}' mesh.conf
