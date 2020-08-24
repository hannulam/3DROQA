

# ThreeDROQA

Introduction

The MATLAB code is part of the 3D-Round-Object-Quantification Algorithm (3DROQA or ThreeDROQA). The code can be used to calculate and tabulate the spatial and intensity measurements for round objects segmented from 3D-image data. The code takes 3D intensity and segmented binary data as inputs and transforms the found voxel particles into ellipsoids via intermediate polygon particles. Using the particles, the code calculates various measures for each subject entity, including shape, dimensional, and intensity values. The code also monitors the data quality by excluding hyperboloids (an indication of proximate under-segmented particles) and calculating ellipsoid-to-voxels volume ratios (extreme ratios far from 1 indicate issues in the particle quality or transformation process). The tabulated values can then be used for making statistical tests. For more information, the 3DROQA was published as a part of Tamminen I. et al. Communications biology (2020).


How to use

[Tähän voisi lyhyesti kirjoittaa, miten koodi käytännössä otetaan käyttöön, miten sille annetaan data, ja miten data tulee pihalle]


Other matter

The software package includes three outside libraries/functions listed below: 

iso2mesh by Qianqian Fang https://github.com/fangq/iso2mesh

ellipsoid_fit_new by Yury Petrov https://se.mathworks.com/matlabcentral/fileexchange/24693-ellipsoid-fit

stlVolume by Krishnan Suresh https://se.mathworks.com/matlabcentral/fileexchange/26982-volume-of-a-surface-triangulation

The iso2mesh was published under GPL v2 license. The ellipsoid_fit_new and stlVolume were published under the following license: 

"All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
