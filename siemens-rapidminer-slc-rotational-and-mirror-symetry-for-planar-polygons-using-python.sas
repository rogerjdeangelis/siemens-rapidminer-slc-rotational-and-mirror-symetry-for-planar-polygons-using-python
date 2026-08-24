/*---
c:/utl/siemens-rapidminer-slc-rotational-and-mirror-symetry-for-planar-polygons-using-python.sas

Siemens Rapidminer slc rotational and mirror symetry for planar polygons using python

Too long to post, see
https://github.com/rogerjdeangelis/siemens-rapidminer-slc-rotational-and-mirror-symetry-for-planar-polygons-using-python

This python codecomputes max rotational and mirror symmetry for planal polygons
Sjould not ne that had for solid objects?

NOTE:  360 degree rotation will always be  symmetric (y0u can sent verice tolerance fuzzy vertices)

                   INCLUDES TRIVIAL 360
                   ROTATIONAL SYMMETRY                       NON_TRIVIAL_ROTATIONALAL
      SHAPE        ROTATIONAL_ORDER    HAS_MIRROR_SYMMETRY          SYMMETRY

  square                   4                    1                       3
  parallelogram            2                    0                       1
  isosceles                1                    1                       0
  octagon                  8                    1                       7
---*/
 
 /*==========================================================================*/
 /*                                                                          */
 /* INPUT VERTICES                                                           */
 /*                                                                          */
 /*  square = [(1, 1), (-1, 1), (-1, -1), (1, -1)]                           */
 /*  parallelogram = [(0, 0), (3, 0), (4, 2), (1, 2)]                        */
 /*  isosceles = [(0, 2), (-2, -1), (2, -1)]                                 */
 /*                                                                          */
 /*  """ angles are needed for precesion """                                 */
 /*  angles = np.arange(8) * 2 * np.pi / 8                                   */
 /*  octagon = list(zip(np.cos(angles), np.sin(angles)))                     */
 /*                                                                          */
 /*==========================================================================*/ 
 
 /*==========================================================================*/
 /* PROCESS                                                                  */
 /*==========================================================================*/ 
 
options set=PYTHONHOME "D:\py314";
proc python;
submit;
import numpy as np
import pandas as pd

def polygon_symmetry(vertices, tol=1e-6):
    """
    rotational_order: the true order of rotational symmetry (1 = none
        beyond the trivial 360 degrees). Every divisor of this number
        is automatically also a valid symmetry, so there's no need to
        report them separately.
    has_mirror_symmetry: True if any reflection axis through the
        centroid maps the polygon onto itself. (If True, the number
        of such axes always equals rotational_order -- a basic fact
        about dihedral symmetry groups -- so that count isn't
        separately meaningful either.)
    """
    pts = np.asarray(vertices, dtype=float)
    n = len(pts)
    z = pts - pts.mean(axis=0)
    zc = z[:, 0] + 1j * z[:, 1]

    rotational_order = 1
    for k in range(n, 1, -1):
        if n % k == 0:
            shift = n // k
            rotated = zc * np.exp(2j * np.pi / k)
            if np.allclose(rotated, np.roll(zc, -shift), atol=tol):
                rotational_order = k
                break

    has_mirror_symmetry = False
    nz = np.abs(zc) > tol
    for shift in range(n):
        target = zc[[(shift - i) % n for i in range(n)]]
        ratios = target[nz] / np.conj(zc[nz])
        if np.isclose(np.abs(ratios[0]), 1.0, atol=tol) and np.allclose(ratios, ratios[0], atol=tol):
            has_mirror_symmetry = True
            break

    return {"rotational_order": rotational_order, "has_mirror_symmetry": has_mirror_symmetry}
    
square = [(1, 1), (-1, 1), (-1, -1), (1, -1)]
result = polygon_symmetry(square)
square_sym = pd.DataFrame([result])
print("square")
print(square_sym)

parallelogram = [(0, 0), (3, 0), (4, 2), (1, 2)]
result = polygon_symmetry(parallelogram)   # <-- capture it this time
parallelogram_sym = pd.DataFrame([result])
print("parallelogram")
print(parallelogram_sym)

isosceles = [(0, 2), (-2, -1), (2, -1)]
result = polygon_symmetry(isosceles)
isosceles_sym = pd.DataFrame([result])
print("isosceles triangle") 
print(isosceles_sym)

""" angles are needed for precesion """ 
angles = np.arange(8) * 2 * np.pi / 8
octagon = list(zip(np.cos(angles), np.sin(angles)))           
result=polygon_symmetry(octagon)
octagon_sym = pd.DataFrame([result])
print("octagon") 
print(octagon_sym)

combined = pd.concat([square_sym, parallelogram_sym, isosceles_sym, octagon_sym], ignore_index=True)
combined["non_trivial_rotations"] = combined["rotational_order"] - 1
combined["shape"] = ["square", "parallelogram", "isosceles", "octagon"]

print(combined)
endsubmit;
import data=workx.combined python=combined;
run;

proc print data=workx.combined;
var shape rotational_order  has_mirror_symmetry  non_trivial_rotations;
run;

 /*==========================================================================*/
 /*  OUTPUT                                                                  */
 /*==========================================================================*/ 
 

The PYTHON Procedure

square                                                                                                                                                                                                                                                         
                                                                                                                                                                                                                                                               
   rotational_order  has_mirror_symmetry                                                                                                                                                                                                                       
0                 4                 True                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                               
parallelogram                                                                                                                                                                                                                                                  
                                                                                                                                                                                                                                                               
   rotational_order  has_mirror_symmetry                                                                                                                                                                                                                       
0                 2                False                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                               
isosceles triangle                                                                                                                                                                                                                                             
                                                                                                                                                                                                                                                               
   rotational_order  has_mirror_symmetry                                                                                                                                                                                                                       
0                 1                 True                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                               
octagon                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                               
   rotational_order  has_mirror_symmetry                                                                                                                                                                                                                       
0                 8                 True                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                               
   rotational_order  has_mirror_symmetry  non_trivial_rotations          shape                                                                                                                                                                                 
0                 4                 True                      3         square                                                                                                                                                                                 
1                 2                False                      1  parallelogram                                                                                                                                                                                 
2                 1                 True                      0      isosceles                                                                                                                                                                                 
3                 8                 True                      7        octagon                                                                                                                                                                                 
                                                                                                                                                                                                                                                               
 
SLC

     SHAPE      ROTATIONAL_ORDER  HAS_MIRROR_SYMMETRY  NON_TRIVIAL_ROTATIONS

 square                 4                  1                     3
 parallelogram          2                  0                     1
 isosceles              1                  1                     0
 octagon                8                  1                     7


LOG

 1                                          Altair SLC         11:17 Monday, August 24, 2026     

NOTE: Copyright 2002-2025 World Programming, an Altair Company
NOTE: Altair SLC 2026 (05.26.01.00.000758)
      Licensed to Roger DeAngelis
NOTE: This session is executing on the X64_WIN11PRO platform and is running in 64 bit mode

NOTE: AUTOEXEC processing beginning; file is c:\wpsoto\autoexec.sas
NOTE: Library workx assigned as follows:
      Engine:        SAS7BDAT
      Physical Name: d:\wpswrkx

NOTE: Library wpdx assigned as follows:
      Engine:        WPD
      Physical Name: d:\wpswrkx

NOTE: Library slchelp assigned as follows:
      Engine:        WPD
      Physical Name: C:\Program Files\Altair\SLC\2026\sashelp


LOG:  11:17:41
NOTE: 1 record was written to file PRINT

NOTE: The data step took :
      real time : 0.036
      cpu time  : 0.015


NOTE: Format num2mis output
NOTE: Format $chr2mis output
NOTE: Procedure format step took :
      real time : 0.021
      cpu time  : 0.000


 /*==========================================================================*/
 /*  LOG                                                                     */
 /*==========================================================================*/ 
 
NOTE: AUTOEXEC processing completed

1         /*---
2         c:/utl/Siemens-Rapidminer-cls-rotational-and-mirror-symetry-for-planar-polygons-using-python.sas
3         ---*/
4         
5         options set=PYTHONHOME "D:\py314";
6         proc python;
7         submit;
8         import numpy as np
9         import pandas as pd
10        
11        def polygon_symmetry(vertices, tol=1e-6):
12            """
13            rotational_order: the true order of rotational symmetry (1 = none
14                beyond the trivial 360 degrees). Every divisor of this number
15                is automatically also a valid symmetry, so there's no need to
16                report them separately.
17            has_mirror_symmetry: True if any reflection axis through the
18                centroid maps the polygon onto itself. (If True, the number
19                of such axes always equals rotational_order -- a basic fact
20                about dihedral symmetry groups -- so that count isn't
21                separately meaningful either.)
22            """
23            pts = np.asarray(vertices, dtype=float)
24            n = len(pts)
25            z = pts - pts.mean(axis=0)
26            zc = z[:, 0] + 1j * z[:, 1]
27        
28            rotational_order = 1
29            for k in range(n, 1, -1):
30                if n % k == 0:
31                    shift = n // k
32                    rotated = zc * np.exp(2j * np.pi / k)
33                    if np.allclose(rotated, np.roll(zc, -shift), atol=tol):
34                        rotational_order = k
35                        break
36        
37            has_mirror_symmetry = False
38            nz = np.abs(zc) > tol
39            for shift in range(n):
40                target = zc[[(shift - i) % n for i in range(n)]]
41                ratios = target[nz] / np.conj(zc[nz])
42                if np.isclose(np.abs(ratios[0]), 1.0, atol=tol) and np.allclose(ratios, ratios[0], atol=tol):
43                    has_mirror_symmetry = True
44                    break
45        
46            return {"rotational_order": rotational_order, "has_mirror_symmetry": has_mirror_symmetry}
47        
48        square = [(1, 1), (-1, 1), (-1, -1), (1, -1)]
49        result = polygon_symmetry(square)
50        square_sym = pd.DataFrame([result])
51        print("square")
52        print(square_sym)
53        
54        parallelogram = [(0, 0), (3, 0), (4, 2), (1, 2)]
55        result = polygon_symmetry(parallelogram)   # <-- capture it this time
56        parallelogram_sym = pd.DataFrame([result])
57        print("parallelogram")
58        print(parallelogram_sym)
59        
60        isosceles = [(0, 2), (-2, -1), (2, -1)]
61        result = polygon_symmetry(isosceles)
62        isosceles_sym = pd.DataFrame([result])
63        print("isosceles triangle")
64        print(isosceles_sym)
65        
66        """ angles are needed for precesion """
67        angles = np.arange(8) * 2 * np.pi / 8
68        octagon = list(zip(np.cos(angles), np.sin(angles)))
69        result=polygon_symmetry(octagon)
70        octagon_sym = pd.DataFrame([result])
71        print("octagon")
72        print(octagon_sym)
73        
74        combined = pd.concat([square_sym, parallelogram_sym, isosceles_sym, octagon_sym], ignore_index=True)
75        combined["non_trivial_rotations"] = combined["rotational_order"] - 1
76        combined["shape"] = ["square", "parallelogram", "isosceles", "octagon"]
77        
78        print(combined)
79        endsubmit;

NOTE: Submitting statements to Python:


80        import data=workx.combined python=combined;
NOTE: Creating data set 'WORKX.combined' from Python data frame 'combined'
NOTE: Data set "WORKX.combined" has 4 observation(s) and 4 variable(s)

81        run;
NOTE: Procedure python step took :
      real time : 0.951
      cpu time  : 0.062


82        
83        proc print data=workx.combined;
84        var shape rotational_order  has_mirror_symmetry  non_trivial_rotations;
85        run;
NOTE: 4 observations were read from "WORKX.combined"
NOTE: Procedure print step took :
      real time : 0.018
      cpu time  : 0.015

 
NOTE: Submitted statements took :
      real time : 1.099
      cpu time  : 0.140

/*==========================================================================*/
/*  END                                                                     */
/*==========================================================================*/ 
