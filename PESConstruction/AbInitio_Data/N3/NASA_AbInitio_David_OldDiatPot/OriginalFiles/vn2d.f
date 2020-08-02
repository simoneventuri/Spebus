      subroutine vn2d(r,vnn,dr)
c     determine two body (N2) potential energy vnn
c     fit to acpf 2s doubly occupied
      implicit real*8(a-h,o-z)
      dimension csr(8)
      data csr / -7.64388144433896D+02,-2.11569028013955D+03,
     $     -2.67675739355454D+03,-2.46303302042839D+03,
     $     -1.53331085357664D+03,-6.03848288404665D+02,
     $      1.27445322988364D+02, 1.49427946215489D+02/
      data co/  49D0/
      data ao/  2.4D+00/
      data a1/  6.0d0/
      data clr/ 21.8526654564325d0/
      data d /2.5d0/
      data nrep /8/
      data nlr /10/
      data re /2.1d0/
      vdlr=0.d0
      vrep=co*dexp(-ao*r)/r
      drep=-vrep*(ao+(1d0/r))
c$$$      vrep=co*dexp(-ao*r)
c$$$      drep=-vrep*ao
      suma=csr(nrep)
      dsuma=0d0
      dr=r-re
      do n=nrep-1,1,-1
       dsuma=suma+dr*dsuma
       suma=csr(n)+suma*dr
      end do
c$$$      dsuma=suma+r*dsuma
c$$$      suma=suma*r
c$$$       write(6,*)r,suma
c$$$      suma=0.d0
c$$$      xs=1.0d0
c$$$       do n=1,nrep
c$$$       xs=r*xs
c$$$       suma=suma+xs*csr(n)
c$$$       enddo
      ex=exp(-a1*r)*(r**6)
      vsr=suma*ex
c$$$      vrep=vrep+suma*ex
      drep=drep+((-a1+(6d0/r))*suma+dsuma)*ex
 30   r2=r*r
      c6=clr
      c8=clr*20d0
      c10=clr*500d0
      r3=r2*r
      r4=r2*r2
      r5=r4*r
      r6=r4*r2
      d2=d*d
      d4=d2*d2
      d6=d4*d2
      vdlr=vdlr-c6/(r6+d6)
      dr=drep+c6*6d0*r5/((r6+d6)**2)
      vdlr=vdlr-c8/((r4+d4)**2)
      dr=dr+8d0*c8*r3/((r4+d4)**3)
      vdlr=vdlr-c10/((r2+d2)**5)
      dr=dr+10d0*c10*r/((r2+d2)**6)
 50   vnn=vrep+vdlr+vsr
c$$$      write(6,*)vdlr,vsr,vrep
c$$$      vnn=vrep
      return
      end
