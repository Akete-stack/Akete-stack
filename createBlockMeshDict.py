#!/usr/bin/python3
import os
import pyvista as pv
import numpy as np
import glob
baseh=640
stls=glob.glob('constant/triSurface/*.stl')
points = np.concatenate([pv.read(stl).points for stl in stls])
#mesh = pv.read(filename)
#points = mesh.points
import pandas as pd
df = pd.DataFrame(data=points, columns=['X', 'Y', 'Z'])
minx=np.min(df.X)
maxx=np.max(df.X)
miny=np.min(df.Y)
maxy=np.max(df.Y)
minz=np.min(df.Z)
maxz=np.max(df.Z)
print(maxx)
print(minx)
print(maxy)
print(miny)
print(maxz)
print(minz)
length = maxx - minx
width = maxy - miny
height = maxz - minz
maxx=maxx + length*0.05
minx=minx - length*0.05
maxy=maxy + width*0.05
miny=miny - width*0.05
maxz=maxz + height*0.05
minz=minz - height*0.05
length = maxx - minx
width = maxy - miny
height = maxz - minz
maxx=maxx-length%baseh/2.0
minx=minx+length%baseh/2.0
maxy=maxy-width%baseh/2.0
miny=miny+width%baseh/2.0
maxz=maxz-height%baseh/2.0
minz=minz+height%baseh/2.0
length = maxx - minx
width = maxy - miny
height = maxz - minz
xdiv=int(length/baseh)
ydiv=int(width/baseh)
zdiv=int(height/baseh)
msg=f"""\
FoamFile
{{
  version 2.0;
  format ascii;
  class dictionary;
  object blockMeshDict;
}}
convertToMeters 1;

minx {minx};
maxx {maxx};
miny {miny};
maxy {maxy};
minz {minz};
maxz {maxz};
nx {xdiv};
ny {ydiv};
nz {zdiv};

vertices
(
    ({minx} {miny} {minz}) 
    ({maxx} {miny} {minz}) 
    ({maxx} {maxy} {minz}) 
    ({minx} {maxy} {minz}) 
    ({minx} {miny} {maxz}) 
    ({maxx} {miny} {maxz})
    ({maxx} {maxy} {maxz}) 
    ({minx} {maxy} {maxz})
);

blocks 
( 
  hex (0 1 2 3 4 5 6 7) ({xdiv} {ydiv} {zdiv}) simpleGrading (1 1 1) 
);
edges ();
patches ();
mergePatchPairs ();
"""
if not os.path.exists('system'):
    os.mkdir('system')
f = open('system/blockMeshDict', 'w')
f.write(msg)
f.close()

