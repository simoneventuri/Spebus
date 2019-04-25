import numpy
import math
import matplotlib.pyplot as plt
import six
from IPython.core.pylabtools import figsize


def V_N2_DS(RVec):
    # UNITS OF MEASURE: BOHR - ELECTRONVOLT

    csr  = [-7.64388144433896e+02, -2.11569028013955e+03, -2.67675739355454e+03, -2.46303302042839e+03, -1.53331085357664e+03, -6.03848288404665e+02, 1.27445322988364e+02, 1.49427946215489e+02]
    co   = 49.0
    ao   = 2.4
    a1   = 6.0
    clr  = 21.8526654564325
    d    = 2.5
    nrep = 7
    nlr  = 10
    re   = 2.1

    c6   = clr
    c8   = clr*20.0
    c10  = clr*500.0

    VVec  = []
    dVVec = []
    for R in RVec:

        vrep =    co * math.exp(-ao*R) / R   
        drep = -vrep * (ao + (1.0/R))

        suma  = csr[nrep] + 0.0
        dsuma = 0.0
        dr    = R - re
        for n in range(nrep-1,-1,-1):
            dsuma = suma   + dsuma * dr
            suma  = csr[n] +  suma * dr
        
        ex   = math.exp(-a1*R) * (R**6)
        vsr  = suma * ex
        drep = drep + ((-a1 + (6.0/R)) * suma + dsuma) * ex

        vdlr =      - c6           / (R**6 + d**6)
        vdlr = vdlr - c8           / (R**4 + d**4)**2
        vdlr = vdlr - c10          / (R**2 + d**2)**5
        
        V    = (vrep + vdlr + vsr) * 27.2113839712790
        dV   = 0.0

        VVec  = numpy.append(VVec, V)
        dVVec = numpy.append(dVVec, dV)

    return VVec, dVVec


def V_N2_LeRoy(RVec):
    # UNITS OF MEASURE: BOHR - ELECTRONVOLT

    csr  = [-3.89327515161896e2, -6.19410598346194e2, -5.51461129947346e2, -3.54896837660797e2, -1.08347448451266e2, -6.59348244094835e1, 1.30457802135760e1, 7.20557758084161e1, -1.81062803146583e1, -2.84137057950277e1, 1.40509401686544e1, -1.84651681798865]
    co   = 49.0
    ao   = 2.4
    a1   = 5.38484562702061
    clr  = 23.9717901220746
    d    = 3.0
    nrep = 11
    nlr  = 10
    re   = 2.1

    c6   = clr
    c8   = clr*20.0
    c10  = clr*500.0

    VVec  = []
    dVVec = []
    for R in RVec:

        vrep =    co * math.exp(-ao*R) / R   
        drep = -vrep * (ao + (1.0/R))

        suma  = csr[nrep] + 0.0
        dsuma = 0.0
        dr    = R - re
        for n in range(nrep-1,-1,-1):
            dsuma = suma   + dsuma * dr
            suma  = csr[n] +  suma * dr
        
        ex   = math.exp(-a1*R) * (R**6)
        vsr  = suma * ex
        drep = drep + ((-a1 + (6.0/R)) * suma + dsuma) * ex

        vdlr =      - c6           / (R**6 + d**6)
        vdlr = vdlr - c8           / (R**4 + d**4)**2
        vdlr = vdlr - c10          / (R**2 + d**2)**5
        
        V    = (vrep + vdlr + vsr) * 27.2113839712790
        dV   = 0.0

        VVec  = numpy.append(VVec, V)
        dVVec = numpy.append(dVVec, dV)

    return VVec, dVVec