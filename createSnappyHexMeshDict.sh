#!/bin/bash
outFile="system/snappyHexMeshDict"
lev=4
startPoint="5000.0 0.0 4000.0"

stls=`ls stl/*.stl`

declare -a stl_array=()


for stl in $stls
do
 stl_name=`basename  $stl`
 stl_name=${stl_name%.*}
 stl_array+=($stl_name)
done

cat << EOS > $outFile
FoamFile
{
    version     2.0;
    format      ascii;
    class       dictionary;
    object      snappyHexMeshDict;
}
castellatedMesh true;
snap            true;
addLayers       true;
EOS

cat << EOS >> $outFile
geometry
{
  kwt.stl{type triSurfaceMesh;name kwt;}
EOS
###
for stl in ${stl_array[@]};
do
 echo "  ${stl}.stl{type triSurfaceMesh;name ${stl};}" >> $outFile
done

cat << EOS >> $outFile
}
castellatedMeshControls
{
  features (
    {file "kwt.eMesh"; level 1;}
  );
  refinementSurfaces{ 
    kwt{
      level (0 0);
      regions{
        ground {level (0 0); patchInfo{type wall; }}
        inlet {level (0 0);patchInfo{type patch;}}
        outlet {level (0 0); patchInfo{type patch;}}
        wall {level (0 0); patchInfo{type wall;}}
      }
    }
EOS

####################################
## Caution !!!                    ##
## level needs space after itself ##
####################################

for stl in ${stl_array[@]};
do
 echo "     ${stl}{level ($lev $lev);regions{${stl}{level ($lev $lev);patchInfo{type wall;}}}}" >> $outFile
done

cat << EOS >> $outFile
  }
  refinementRegions {}
  locationInMesh ($startPoint);
  maxLocalCells 100000000;
  maxGlobalCells 100000000;
  minRefinementCells 1;
  nCellsBetweenLevels 2;
  resolveFeatureAngle 30;
  allowFreeStandingZoneFaces false;
}
snapControls{
  nSolveIter 30;
  nSmoothPatch 3;
  tolerance 4.0;
  nRelaxIter 5;
  nFeatureSnapIter 10;
}
addLayersControls{
  layers  {  
      ground { nSurfaceLayers 2; }
EOS
for stl in ${stl_array[@]};
do
 echo "      ${stl}{ nSurfaceLayers 2; }" >> $outFile
done


cat << EOS >> $outFile
}
  relativeSizes true;
  expansionRatio 1.0;
  finalLayerThickness 0.3;
  minThickness 0.03;
  nGrow 1;
  featureAngle 60;
  nRelaxIter 5;
  nSmoothSurfaceNormals 1;
  nSmoothNormals 3;
  nSmoothThickness 10;
  maxFaceThicknessRatio 0.5;
  maxThicknessToMedialRatio 0.3;
  minMedianAxisAngle 130;
  nBufferCellsNoExtrude 0;
  nLayerIter 50;
  nRelaxedIter 20;
}
meshQualityControls
{
  maxNonOrtho 65;
  maxBoundarySkewness 20;
  maxInternalSkewness 4;
  maxConcave 80;
  minFlatness 0.5;
  minVol 1.00E-13;
  minTetQuality -1e30;
  minArea -1;
  minTwist 0.05;
  minDeterminant 0.001;
  minFaceWeight 0.05;
  minVolRatio 0.01;
  minTriangleTwist -1;
  nSmoothScale 4;
  errorReduction 0.75;
  relaxed {maxNonOrtho 180;}
}
debug 0;
mergeTolerance 1e-5;
EOS

