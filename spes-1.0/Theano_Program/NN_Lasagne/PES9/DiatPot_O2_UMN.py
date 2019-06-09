import numpy
import math
import matplotlib.pyplot as plt
import six
from IPython.core.pylabtools import figsize


def V_O2_UMN(RVec):
    # UNITS OF MEASURE: BOHR - ELECTRONVOLT

    B_To_Ang       = 0.52917721067
    Kcm_To_Hartree = 0.159360144e-2

    VRef       = 0.1915103559

    a          = numpy.array([-1.488979427684798e3, 1.881435846488955e4, -1.053475425838226e5, 2.755135591229064e5, -4.277588997761775e5, 4.404104009614092e5, -2.946204062950765e5, 1.176861219078620e5 ])     
    alpha      = 9.439784362354936e-1
    beta       = 1.262242998506810

    r2r4Scalar = 2.59361680                                                                                     
    rs6        = 0.5299
    rs8        = 2.20
    c6         = 12.8

    VVec  = []
    dVVec = []
    for R in RVec:

        ######################################################################################################     <--- Compute_Vd_dVd_O2
        ### 
        RAng = R * B_To_Ang   


        ##############################################################################################     <--- Ev2gm2_Grad
        ###
        V = 0.0
        for k in range(8):
            V = V + a[k] * math.exp(-alpha * beta**k * RAng**2)
        V = V*1.e-3

        dV = 0.0
        for k in range(8):
            dV = dV - 2.0 * a[k] * alpha * beta**k * RAng * math.exp(-alpha * beta**k * RAng**2)
        dV = dV*1.e-3
        ######################################################################################     <--- d3disp_Grad
        ###


        ##############################################################################       <--- edisp_Grad
        ###
        c8Step = 3.0 * c6 * r2r4Scalar**2

        tmp = math.sqrt(c8Step / c6)              
        e6  = c6     / (R**6 + (rs6*tmp + rs8)**6)
        e8  = c8Step / (R**8 + (rs6*tmp + rs8)**8)

        e6dr =     c6 * (-6.0 * R**5) / (R**6 + (rs6*tmp + rs8)**6)**2
        e8dr = c8Step * (-8.0 * R**7) / (R**8 + (rs6*tmp + rs8)**8)**2
        ##############################################################################       ---> edisp_Grad


        VDisp  = (-e6   -2.0*e8)  
        dVDisp = (-e6dr -2.0*e8dr) / B_To_Ang
        ######################################################################################     ---> d3disp_Grad


        VDiat  = VDisp  + V    
        dVDiat = dVDisp + dV     
        ##############################################################################################     ---> Ev2gm2_Grad


        V  = (VDiat)             * 27.2113839712790       
        dV = (dVDiat * B_To_Ang) * 27.2113839712790                                                                                     
        ######################################################################################################     ---> Compute_Vd_dVd_O2


        VVec  = numpy.append(VVec, V)
        dVVec = numpy.append(dVVec, dV)


    return VVec, dVVec