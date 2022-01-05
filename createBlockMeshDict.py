
import numpy as np
from stl import mesh
import stl
import glob
import os
def find_mins_maxs(obj):
    minx = maxx = miny = maxy = minz = maxz = None
    for p in obj.points:
        # p contains (x, y, z)
        if minx is None:
            minx = p[stl.Dimension.X]
            maxx = p[stl.Dimension.X]
            miny = p[stl.Dimension.Y]
            maxy = p[stl.Dimension.Y]
            minz = p[stl.Dimension.Z]
            maxz = p[stl.Dimension.Z]
        else:
            maxx = max(p[stl.Dimension.X], maxx)
            minx = min(p[stl.Dimension.X], minx)
            maxy = max(p[stl.Dimension.Y], maxy)
            miny = min(p[stl.Dimension.Y], miny)
            maxz = max(p[stl.Dimension.Z], maxz)
            minz = min(p[stl.Dimension.Z], minz)
    return minx, maxx, miny, maxy, minz, maxz

##########
baseh=640
##########
stls=glob.glob('constant/triSurface_org/*.stl')
body = mesh.Mesh(np.concatenate([mesh.Mesh.from_file(stl).data for stl in stls]))
minx, maxx, miny, maxy, minz, maxz = find_mins_maxs(body)
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
maxx=maxx-length%baseh/2
minx=minx+length%baseh/2
maxy=maxy-width%baseh/2
miny=miny+width%baseh/2
maxz=maxz-height%baseh/2
minz=minz+height%baseh/2
length = maxx - minx
width = maxy - miny
height = maxz - minz
xdiv=int(length/baseh)
ydiv=int(width/baseh)
zdiv=int(height/baseh)

msg=f"""\
FoamFile{{version 2.0;format ascii;class dictionary;object blockMeshDict;}}
convertToMeters 1e-3;
minx={minx};
maxx={maxx};
miny={miny};
maxy={maxy};
minz={minz};
maxz={maxz};
nx {xdiv};
ny {ydiv};
nz {zdiv};
vertices(
    ($minx $miny $minz) ($maxx $miny $minz) 
    ($maxx $maxy $minz) ($minx $maxy $minz) 
    ($minx $miny $maxz) ($maxx $miny $maxz)
    ($maxx $maxy $maxz) ($minx $maxy $maxz)
);
blocks ( hex (0 1 2 3 4 5 6 7) ($nx $ny $nz) simpleGrading (1 1 1) );
edges();
patches();
mergePatchPairs();
"""
if not os.path.exists('system'):
    os.mkdir('system')
f = open('system/blockMeshDict', 'w')
f.write(msg)
f.close()


