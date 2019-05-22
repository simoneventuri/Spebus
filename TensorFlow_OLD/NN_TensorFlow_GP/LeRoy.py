import numpy
import math
import matplotlib.pyplot as plt
from IPython.core.pylabtools import figsize

def V_LeRoy(r):

  nrep  =  12
  co    =  49.0
  ao    =  2.4
  a1    =  5.38484562702061
  c     =  23.9717901220746
  cx20  =  c * 20.0
  cx500 =  c * 500.0
  d     =  3.0
  d2    =  d**2
  d4    =  d**4
  d6    =  d**6
  re    =  2.1
  csr   =  numpy.array([ -3.89327515161896e+02, -6.19410598346194e+02, -5.51461129947346e+02, -3.54896837660797e+02, -1.08347448451266e+02, -6.59348244094835e+01, 1.30457802135760e+01,  7.20557758084161e+01, -1.81062803146583e+01, -2.84137057950277e+01,  1.40509401686544e+01, -1.84651681798865e+00])

  Vrep    =   co * numpy.exp( -ao * r) / r

  suma    =   csr[nrep-1]
  dV      =   r - re

  for n in range(nrep-2, -1, -1):
    suma  =   csr[n] + suma * dV

  ex      =   numpy.exp( - a1 * r ) * r**6
  Vsr     =   suma * ex

  Vdlr    =        - c     / ( r**6 + d6 )
  Vdlr    =   Vdlr - cx20  / ( r**4 + d4 )**2
  Vdlr    =   Vdlr - cx500 / ( r**2 + d2 )**5

  V       =   Vrep + Vdlr + Vsr

  V       =   V * 27.2113839712790

  return V


def plot_DiatPot(rMin, rMax, NPoints):

  rVec = numpy.linspace(rMin, rMax, num=NPoints)
  
  V = V_LeRoy(rVec)

  fig = plt.figure(figsize(12.5, 5))
  ax = fig.add_subplot(1, 1, 1)
  ax.plot(rVec, V, 'b')
  plt.title(r"N2 Diatomic Potential")
  plt.xlim(rMin-0.3, rMax+0.3);

  plt.show()