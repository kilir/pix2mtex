# pix2mtex
A simple loader for pixel maps allowing grain reconstruction using mtex.

Three image models are available: matrix, single and poly

## matrix
This is a map of test grains (black) on a white background, which 
is an example for the model 'matrix':

![testgrains](https://user-images.githubusercontent.com/11697557/37593838-b39707f2-2b73-11e8-9fad-1451f7745307.png)

```Matlab

[ebsd,grains]=loadPhaseMap('testgrains.png','matrix')
 
ebsd = EBSD (show methods, plot)
 
 Phase  Orientations     Mineral       Color  Symmetry  Crystal reference frame
     0  285285 (79%)  notIndexed                                               
     1   74715 (21%)      1phase  light blue        -1       X||a, Y||b*, Z||c*
 
 Properties: x, y, grainId
 Scan unit : um
 
grains = grain2d (show methods, plot)
 
 Phase  Grains  Pixels     Mineral  Symmetry  Crystal reference frame
     0       1  285285  notIndexed                                   
     1      15   74715      1phase        -1       X||a, Y||b*, Z||c*
 
 boundary segments: 8768
 triple points: 0
 
 Id   Phase   Pixels   GOS   phi1   Phi   phi2
  1       1     4925     0      0     0      0
  2       1     4939     0      0     0      0
  3       1     5396     0      0     0      0
  4       1     4968     0      0     0      0
  5       1     4994     0      0     0      0
  6       1     3001     0      0     0      0
  7       1     6561     0      0     0      0
  8       1     6525     0      0     0      0
  9       1     6613     0      0     0      0
 10       1     5439     0      0     0      0
 11       1     3192     0      0     0      0
 12       1     6785     0      0     0      0
 13       1     5456     0      0     0      0
 14       1     2953     0      0     0      0
 15       1     2968     0      0     0      0
 16       0   285285     0      0     0      0
```


## single
Using a pixel map with 2 pixel wide bounadries (white) of otherwise space-filling
grains is an example for the 'single' model.

![single-small](https://user-images.githubusercontent.com/11697557/37593998-45f673bc-2b74-11e8-8ef4-d265b78eeaa5.png)

```Matlab
[ebsd,grains]=loadPhaseMap('single-small.png','single')
% by default, non-indexed points are removed and the area between grains
% is considered as empty and hence will be reconstructed during grain computation
plot(grains)
```
![single-results](https://user-images.githubusercontent.com/11697557/37594005-4b975ce6-2b74-11e8-9eb2-1abd29f4fd3f.png)



## poly
This is an example of the 'poly' model which requires I) a phase map
where each phase is described by a gray value and II) a boundary map.

![boundarymap](https://user-images.githubusercontent.com/11697557/37594308-1c6d0c08-2b75-11e8-8e9c-d353fe002500.png)
![phasemap](https://user-images.githubusercontent.com/11697557/37594309-1ca596ea-2b75-11e8-9c63-0362aca4a6ab.png)

```Matlab
[ebsd,grains]=loadPhaseMap('boundarymap.png','phasemap.png','poly')
grains=calcGrains(ebsd('indexed'))
plot(grains)
```
![poly_result](https://user-images.githubusercontent.com/11697557/37594356-308717c4-2b75-11e8-996b-0b214db840ae.png)



