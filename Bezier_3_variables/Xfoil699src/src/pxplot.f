
      PROGRAM PXPLOT
C***********************************************************************
C  Polar dump plotting facility for ISES and XFOIL
C
C    INPUT:
C     * Polar dump file generated by XFOIL (binary format)
C***********************************************************************
C
C--- Uncomment for Win32/Compaq Visual Fortran compiler (needed for GETARG)
ccc      USE DFLIB
C
      INCLUDE 'PXPLOT.INC'
      CHARACTER*132 FNAME
C
C---- Plotting flag
      IDEV = 1   ! X11 window only
c     IDEV = 2   ! B&W PostScript output file only (no color)
c     IDEV = 3   ! both X11 and B&W PostScript file
c     IDEV = 4   ! Color PostScript output file only 
c     IDEV = 5   ! both X11 and Color PostScript file 
C
C---- Re-plotting flag (for hardcopy)
      IDEVRP = 2   ! B&W PostScript
c     IDEVRP = 4   ! Color PostScript
C
C---- PostScript output logical unit and file specification
      IPSLU = 0  ! output to file  plot.ps   on LU 4    (default case)
c     IPSLU = ?  ! output to file  plot?.ps  on LU 10+?
C
C---- screen fraction taken up by plot window upon opening
      SCRNFR = 0.70
C
C---- Default plot size in inches
C-    (Default plot window is 11.0 x 8.5)
      SIZE = 8.0
C
      LREF   = .FALSE.
      LFORCE = .TRUE.
      LPLOT  = .FALSE.
C
      CALL PLINITIALIZE
      NA = 0
C
C
C---- Check for dump file on command line
      CALL GETARG0(NARG,FNAME)
      IF(FNAME.NE.' ') GO TO 40
C
C=======================================================
    2 WRITE(*,*)
      WRITE(*,*) 'Select option (0=quit):'
      WRITE(*,*)
      WRITE(*,*) '  1   Select point(s)'
      WRITE(*,*) '  2   Plot selected point(s)'
      WRITE(*,*) '  3   Load polar dump file'
      WRITE(*,*)
C
      READ (*,*,ERR=2) IOPT
C
      GO TO ( 5, 10, 20, 30 ), IOPT+1
      GO TO 2
C
    5 CALL PLCLOSE
      STOP
C
C---- Select alpha points for plotting
   10 CALL SELPNT
      GO TO 2
C
C---- Plot data for selected points
   20 CALL PLTPNT
      GO TO 2
C
C---- Load a polar dump file
   30 WRITE(*,*) 'Enter polar dump filename'
      READ (*,1000) FNAME
C
   40 IF(FNAME.NE.' ') THEN 
        CALL READIT(FNAME)
CCC     CALL SORT
      ENDIF
      GO TO 2
C
 1000 FORMAT(A)
C
      END ! PXPLOT



      SUBROUTINE SELPNT
C.............................................
C     Requests the user to select the target 
C     points for all the surface plots. NAPLT
C     points are selected and their indices 
C     are saved in the IAPLT array.
C.............................................
      INCLUDE 'PXPLOT.INC'
      CHARACTER*80 RECORD
      LOGICAL ERROR
C
      WRITE(*,*)
      WRITE(*,*) 'Computed points are:'
      WRITE(*,*)
      IF(LMACH) THEN
C
       WRITE(*,*)
     &  '  Mach   alpha    CL       CD      CDi      CM    S xtr  P xtr'
CCC       0.875 -10.111  1.1111  1.00000  1.00000  1.0000 1.0000 1.0000
       DO IA=1, NA
         WRITE(*,9110) MA(IA),
     &    ALFA(IA),CL(IA),CD(IA),CDI(IA),CM(IA),XTR(1,IA),XTR(2,IA)
       END DO
 9110  FORMAT(1X,F6.3,F8.3,F8.4,2F9.5,F8.4,2F7.4)
C
      ELSE
C 
       WRITE(*,*)
     &  '  alpha    CL       CD      CDi      CM    S xtr  P xtr   Mach'
CCC      -10.234  1.1111  1.00000  1.00000  1.0000 1.0000 1.0000  0.876
       DO IA=1, NA
         WRITE(*,9120) ALFA(IA),
     &    CL(IA),CD(IA),CDI(IA),CM(IA),XTR(1,IA),XTR(2,IA),MA(IA)
       END DO
 9120  FORMAT(1X,F7.3,F8.4,2F9.5,F8.4,2F7.4,F7.3)
C 
      ENDIF
      NAP   = 0
      NAPLT = 0
C
    3 CONTINUE
C
      IF(LMACH) THEN
       WRITE(*,*)
       WRITE(*,*)
     &     'Enter Mach(s) of point(s) to be plotted:'
       READ (*,9200) RECORD
      ELSE
       WRITE(*,*)
       WRITE(*,*)
     &     'Enter alpha(s) of point(s) to be plotted:'
       READ (*,9200) RECORD
      ENDIF
 9200 FORMAT(A80)
C
C---- do not make any changes if just a <CR> was input
      IF(RECORD.EQ.' ') GO TO 80
C
      NIN = 0
      CALL GETFLT(RECORD,APLT(NAP+1),NIN,ERROR)
C
C---- do not make any changes if just a <CR> was input
      IF(NIN.EQ.0) GO TO 80
      NAPLT = NAPLT + NIN
C
      IF(LMACH) THEN
C
C---- save selected point indices and count up how many points there are
      DO 50 KA=NAP+1, NAPLT
        IAPLT(KA) = 0
        DO IA=1, NA 
          IF(ABS(APLT(KA)-MA(IA)) .LE. 0.0011) IAPLT(KA) = IA
        END DO
        IF(IAPLT(KA).EQ.0) THEN
         WRITE(*,9500) APLT(KA)
        ENDIF
   50 CONTINUE
 9500 FORMAT(1X,'Mach  = ',F6.3,'  has not been computed')
C
      ELSE
C
C---- save selected point indices and count up how many points there are
      DO 60 KA=NAP+1, NAPLT
        IAPLT(KA) = 0
        DO IA=1, NA 
          IF(ABS(APLT(KA)-ALFA(IA)) .LE. 0.0011) IAPLT(KA) = IA
        END DO
        IF(IAPLT(KA).EQ.0) THEN
         WRITE(*,9600) APLT(KA)
        ENDIF
   60 CONTINUE
 9600 FORMAT(1X,'alpha = ',F6.3,'  has not been computed')
C
      ENDIF
C
C--- Check for and eliminate invalid alpha or Mach points
 70   DO IA = 1, NAPLT
        IF(IAPLT(IA).LE.0) THEN
          DO IIA = IA+1,NAPLT
            APLT(IIA-1)  = APLT(IIA)
            IAPLT(IIA-1) = IAPLT(IIA)
          END DO
          NAPLT = NAPLT-1
          GO TO 70
        END IF
      END DO
C
      NAP = NAPLT
      GO TO 3
C
C---- Display selected alphas/Machs
 80   WRITE(*,*)
      WRITE(*,*) 'Selected points are:'
      WRITE(*,*)
      IF(LMACH) THEN
       WRITE(*,*)
     &  '  Mach   alpha    CL       CD      CDi      CM    S xtr  P xtr'
CCC       0.875 -10.111  1.1111  1.00000  1.00000  1.0000 1.0000 1.0000
       DO I=1, NAPLT
         IA = IAPLT(I)
         WRITE(*,9110) MA(IA),
     &    ALFA(IA),CL(IA),CD(IA),CDI(IA),CM(IA),XTR(1,IA),XTR(2,IA)
       END DO
      ELSE
       WRITE(*,*)
     &  '  alpha    CL       CD      CDi      CM    S xtr  P xtr   Mach'
CCC      -10.234  1.1111  1.00000  1.00000  1.0000 1.0000 1.0000  0.876
       DO I=1, NAPLT
         IA = IAPLT(I)
         WRITE(*,9120) ALFA(IA),
     &    CL(IA),CD(IA),CDI(IA),CM(IA),XTR(1,IA),XTR(2,IA),MA(IA)
       END DO
      ENDIF
C
      RETURN
      END ! SELPNT


      SUBROUTINE PLTPNT
      INCLUDE 'PXPLOT.INC'
C
      REAL W(NX,2,NAX)
      CHARACTER*1 ANS
C
      CH = 0.015
      XWAKE = 0.3
C
C---- Cp amd Mach axis limits, increments
      CPMIN = -2.0
      DCP = 0.5
C
      MAMAX = 1.4
      DMA = 0.2
C
    6 WRITE(*,*)
      WRITE(*,*) 'Selected points are:'
      WRITE(*,*)
      WRITE(*,*)
     &  '  alpha   Mach    CL       CD      CDi      CM    S xtr  P xtr'
      DO KA=1, NAPLT
        IA = IAPLT(KA)
        IF(IA.NE.0) THEN
         WRITE(*,9120) ALFA(IA),
     &     MA(IA),CL(IA),CD(IA),CDI(IA),CM(IA),XTR(1,IA),XTR(2,IA)
        ENDIF
      END DO
 9120 FORMAT(1X,F7.3,F7.3,F8.4,2F9.5,F8.4,2F7.4)
C
 1100 FORMAT(A1)
C
    2 WRITE(*,2000)
 2000 FORMAT(/'  1   Mach vs x'
     &       /'  2   Cp   vs x'
     &       /'  3   Hk   vs x'
     &       /'  4   D,T  vs x (top    side)'
     &       /'  5   D,T  vs x (bottom side)'
     &       /'  7   Cf   vs x'
     &       /'  8   A/Ao vs x'
     &       /'  9   Ctau vs x'
     &       /' 12   change settings'
     &       /' 13   annotate current plot'
     &       /' 14   hardcopy current plot'
     &      //'Select plot option (0 = return to top level):  ',$)
      READ (*,*,ERR=2) IOPT
C
      IF(IOPT.EQ.0) THEN
        IF(LPLOT) CALL PLEND
        LPLOT = .FALSE.
        RETURN
      ENDIF
C
C
      GO TO (10,20,30,40,50,2 ,70,80,90,2 ,2 ,120,130,140), IOPT
CCCC         1  2  3  4  5     7  8  9        12
      GO TO 2
C
C=============================================
C**** Plot Mach vs x
C
   10 NF = 0
      IF(LREF) CALL GETREF(XF,MF,NF)
C
      DO IA=1, NAX
       DO IS=1, 2
        DO I=1, NX
         W(I,IS,IA) = 0.
        END DO
       END DO
      END DO
C
      DO KA=1, NAPLT
        IA = IAPLT(KA)
        MACHSQ = MA(IA)**2
        DO IS=1, 2
          IEND = II(IS,IA)-1
          DO I=1, IEND
            PRATEX = (CP(I,IS,IA)*0.5*GAM*MACHSQ + 1.0)**(GM1/GAM)
     &             / (1.0 + 0.5*GM1*MACHSQ)
            ATMP = ABS( 1.0/PRATEX - 1.0 )
            W(I,IS,KA) = SQRT( ATMP*2.0/GM1 )
          END DO
        END DO
      END DO
C
      CALL PLTINI
      CALL PLOT(6.*CH,0.175,-3)
C
CCC      CALL SCALIT(NX*2*NAPLT,W,0.0,YFAC)
      YFAC = 1.0/MAMAX
C
      YAXT = 0.70
C
      XOFF = -.10
      XSF = 0.75
C
      YOFF = 0.
      YSF = YFAC*YAXT
C
      CALL YAXIS(0.0,0.0,YSF*MAMAX,YSF*DMA,0.0,DMA,CH,1)
      CALL NEWPEN(3)
      CALL PLCHAR(-3.0*CH,0.8*YAXT,1.4*CH,'M',0.0,1)
      CALL IDENT(0.0,YAXT)
C
      CALL AIRFOI(XOFF,0.05*YSF/XSF,XSF)
C
      CALL NEWPEN(1)
      IF(1.0.LE.MAMAX) CALL DASH(0.0,0.58,(1.0-YOFF)*YSF)
      CALL XTICK(XOFF,-YSF*MA(IA),XSF,1.0/XSF)
C
      CALL NEWPEN(2)
      DO KA=1, NAPLT
        IA = IAPLT(KA)
        DO IS=1, 2
          IEND = II(IS,IA)-1
          IF(IS.EQ.1) IEND = ITE(IS,IA)
          CALL XYLINE(IEND,X(1,IS,IA),W(1,IS,KA),XOFF,XSF,YOFF,YSF,KA)
        END DO
      END DO
C
      IF(LREF)
     & CALL RFPLOT(NF,XF,MF,XOFF,XSF,YOFF,YSF,0.5*CH,0)
C
      CALL PLTFOR(0.625,YAXT)
C
      CALL PLFLUSH
ccc      WRITE(*,*) 'Hit <return>'
ccc      READ (*,1100) ANS
      GO TO 2
C
C
C=============================================
C**** Plot Cp vs x
C
   20 NF = 0
      IF(LREF) CALL GETREF(XF,MF,NF)
C
      DO IA=1, NAX
       DO IS=1, 2
        DO I=1, NX
         W(I,IS,IA) = 0.
        END DO
       END DO
      END DO
C
      DO KA=1, NAPLT
        IA = IAPLT(KA)
        DO IS=1, 2
          IEND = II(IS,IA)-1
          DO I=1, IEND
            W(I,IS,KA) = -CP(I,IS,IA)
          END DO
        END DO
      END DO
C
      CALL PLTINI
      CALL PLOT(6.*CH,0.2,-3)
C
CCC      CALL SCALIT(NX*2*NAPLT,W,0.0,YFAC)
      YFAC = 1.0/(-CPMIN)
C
      YAXT = 0.4
C
      XOFF = -.1
      XSF = 0.75
C
      YOFF = 0.0
      YSF = YFAC*YAXT
C
      CALL PLOT(0.0,YSF,-3)
C
      CALL YAXIS(0.0,-YSF,YSF*(1.0-CPMIN),YSF*DCP,1.0,-DCP,CH,1)
      CALL NEWPEN(3)
      CALL PLCHAR(-3.5*CH,0.875*YAXT-0.3*CH,1.4*CH,'C',0.0,1)
      CALL PLCHAR(-2.4*CH,0.875*YAXT-0.7*CH,0.9*CH,'p',0.0,1)
      CALL IDENT(0.0,YAXT)
C
      CALL NEWPEN(1)
      DO KA=1, NAPLT
        IA = IAPLT(KA)
        IF(-CPSTAR(IA).LE.-CPMIN)
     &     CALL DASH(0.0,0.58,(-CPSTAR(IA)-YOFF)*YSF)
      END DO
C
      CALL AIRFOI(XOFF,1.25*YSF/XSF,XSF)
      CALL XTICK(XOFF,0.0,XSF,1.0/XSF)
C
      CALL NEWPEN(2)
      DO KA=1, NAPLT
        IA = IAPLT(KA)
        DO IS=1, 2
          IEND = II(IS,IA)-1
          IF(IS.EQ.1) IEND = ITE(IS,IA)
          CALL XYLINE(IEND,X(1,IS,IA),W(1,IS,KA),XOFF,XSF,YOFF,YSF,KA)
        END DO
      END DO
C
      IF(LREF)
     & CALL RFPLOT(NF,XF,MF,XOFF,XSF,-YOFF,-YSF,0.5*CH,0)
C
      CALL PLTFOR(0.625,YAXT)
C
      CALL PLFLUSH
ccc      WRITE(*,*) 'Hit <return>'
ccc      READ (*,1100) ANS
      GO TO 2
C
C=============================================
C**** Plot H vs sb
C
   30 CONTINUE
C
      DO IA=1, NAX
       DO IS=1, 2
        DO I=1, NX
         W(I,IS,IA) = 0.
        END DO
       END DO
      END DO
C
C ...... Find Hk for plotting
      DO KA=1, NAPLT
        IA = IAPLT(KA)
        MACHSQ = MA(IA)**2
        DO IS=1, 2
          IEND = II(IS,IA)-1
          DO I=ILE(IS,IA)+1, IEND
            H = DSTR(I,IS,IA)/THET(I,IS,IA)
            PRATEX = (CP(I,IS,IA)*0.5*GAM*MACHSQ + 1.0)**(GM1/GAM)
     &             / (1.0 + 0.5*GM1*MACHSQ)
            ATMP = ABS( 1.0/PRATEX - 1.0 )
            XM = SQRT( ATMP*2.0/GM1 )
            W(I,IS,KA) = (H-0.29*XM**2)/(1.+0.113*XM**2)
          END DO
        END DO
      END DO
C
      CALL PLTINI
      CALL PLOT(6.*CH,0.2,-3)
C
CCC      CALL SCALIT(NX*2*NAPLT,W,0.0,YFAC)
      YFAC = 1.0/6.0
C
      ANN =  1.0/YFAC
      YAXT = 0.6
C
      XOFF = 0.
      XSF = 0.6
C
      YOFF = 0.
      YSF = YFAC*YAXT
      XAX = 1.4*XSF
C
      CALL XAXIS(0.0,0.0,XAX,0.2*XSF,0.0,0.2,CH,1)
C
      CALL YAXIS(0.0,0.0,YAXT,YAXT/6.0,0.0,ANN/6.0,CH,1)
C
      CALL NEWPEN(3)
      CALL PLCHAR(-4.0*CH,3.4*YFAC       ,1.4*CH,'H' ,0.0,1)
      CALL PLCHAR(-2.6*CH,3.4*YFAC-0.4*CH,    CH,'k' ,0.0,1)
      CALL IDENT(0.0,YAXT)
C
      CALL PLCHAR(1.1*XSF-0.6*CH,-3.5*CH,1.2*CH,'X',0.0,1)
C
      CALL NEWPEN(2)
      DO KA=1, NAPLT
        IA = IAPLT(KA)
        DO IS=1, 2
          IL = ILE(IS,IA)
          IEND = II(IS,IA)-1
          IF(IS.EQ.1) IEND = ITE(IS,IA)+1
          CALL XYLINE(IEND-1-IL,X(IL+1,IS,IA),W(IL+1,IS,KA),
     &                XOFF,XSF,YOFF,YSF,KA)
        END DO
      END DO
C
      CALL PLTFOR(0.65,YAXT)
C
      CALL PLFLUSH
ccc      WRITE(*,*) 'Hit <return>'
ccc      READ (*,1100) ANS
      GO TO 2
C
C=============================================
C**** plot top Dstar, Theta vs sb 
C
   40 CONTINUE
C
      DO IA=1, NAX
       DO IS=1, 2
        DO I=1, NX
         W(I,IS,IA) = 0.
        END DO
       END DO
      END DO
C
      IS = 1
      DO KA=1, NAPLT
        IA = IAPLT(KA)
        IEND = II(IS,IA)-1
        DO I=ILE(IS,IA)+1, IEND
          W(I,1,KA) = DSTR(I,IS,IA)
          W(I,2,KA) = THET(I,IS,IA)
        END DO
      END DO
C
      CALL PLTINI
      CALL PLOT(6.*CH,0.2,-3)
C
      CALL SCALIT(NX*2*NAPLT,W,0.0,YFAC)
C
      ANN = 1.0/YFAC
C
      YAXT = 0.6
      XOFF = 0.
      XSF = 0.6
C
      YOFF = 0.
      YSF = YFAC*YAXT
C
      XAX = 1.4*XSF
      CALL XAXIS(0.0,0.0,XAX,0.2*XSF,0.0,0.2,CH,1)
C
      FN = 5.
      CALL YAXIS(0.0,0.0,YAXT,YAXT/FN,0.0,ANN/FN,CH,3)
C
      CALL NEWPEN(3)
      CALL PLCHAR(-4.5*CH,3.4*YAXT/FN       ,1.3*CH,'Top',0.0, 3)
      CALL PLMATH(-4.0*CH,2.4*YAXT/FN       ,1.5*CH,'d'  ,0.0, 1)
      CALL PLCHAR(-2.5*CH,2.4*YAXT/FN+1.6*CH,0.6*CH,'*'  ,0.0, 1)
      CALL PLMATH(-3.5*CH,1.4*YAXT/FN       ,1.5*CH,'q'  ,0.0, 1)
      CALL IDENT(0.0,YAXT)
C
      CALL PLCHAR(1.1*XSF-0.6*CH,-3.5*CH,1.2*CH,'X',0.0,1)
C
      CALL NEWPEN(2)
      DO KA=1, NAPLT
        IA = IAPLT(KA)
        DO IDT=1, 2
          IL = ILE(IS,IA)
          IEND = II(IS,IA)-1
          CALL XYLINE(IEND-1-IL,X(IL+1,1,IA),W(IL+1,IDT,KA),
     &               XOFF,XSF,YOFF,YSF,KA)
        END DO
      END DO
C
      CALL PLTFOR(0.65,YAXT)
C
      CALL PLFLUSH
ccc      WRITE(*,*) 'Hit <return>'
ccc      READ (*,1100) ANS
      GO TO 2
C
C=============================================
C**** plot bottom Dstar, Theta vs sb 
C
   50 CONTINUE
C
      DO IA=1, NAX
       DO IS=1, 2
        DO I=1, NX
         W(I,IS,IA) = 0.
        END DO
       END DO
      END DO
C
      IS = 2
      DO KA=1, NAPLT
        IA = IAPLT(KA)
        IEND = II(IS,IA)-1
        DO I=ILE(IS,IA)+1, IEND
          W(I,1,KA) = DSTR(I,IS,IA)
          W(I,2,KA) = THET(I,IS,IA)
        END DO
      END DO
C
      CALL PLTINI
      CALL PLOT(6.*CH,0.2,-3)
C
      CALL SCALIT(NX*2*NAPLT,W,0.0,YFAC)
C
      ANN = 1.0/YFAC
C
      YAXT = 0.6
      XOFF = 0.
      XSF = 0.6
C
      YOFF = 0.
      YSF = YFAC*YAXT
C
      XAX = 1.4*XSF
      CALL XAXIS(0.0,0.0,XAX,0.2*XSF,0.0,0.2,CH,1)
C
      FN = 5.
      CALL YAXIS(0.0,0.0,YAXT,YAXT/FN,0.0,ANN/FN,CH,3)
C
      CALL NEWPEN(3)
      CALL PLCHAR(-4.5*CH,3.4*YAXT/FN       ,1.3*CH,'Bot',0.0, 3)
      CALL PLMATH(-4.0*CH,2.4*YAXT/FN       ,1.5*CH,'d'  ,0.0, 1)
      CALL PLCHAR(-2.5*CH,2.4*YAXT/FN+1.6*CH,0.6*CH,'*'  ,0.0, 1)
      CALL PLMATH(-3.5*CH,1.4*YAXT/FN       ,1.5*CH,'q'  ,0.0, 1)
      CALL IDENT(0.0,YAXT)
C
      CALL PLCHAR(1.1*XSF-0.6*CH,-3.5*CH,1.2*CH,'X',0.0,1)
C
      CALL NEWPEN(2)
      DO KA=1, NAPLT
        IA = IAPLT(KA)
        DO IDT=1, 2
          IL = ILE(IS,IA)
          IEND = II(IS,IA)-1
          CALL XYLINE(IEND-1-IL,X(IL+1,2,IA),W(IL+1,IDT,KA),
     &               XOFF,XSF,YOFF,YSF,KA)
        END DO
      END DO
C
      CALL PLTFOR(0.65,YAXT)
C
      CALL PLFLUSH
ccc      WRITE(*,*) 'Hit <return>'
ccc      READ (*,1100) ANS
      GO TO 2
C
C=============================================
C**** Plot Cf vs sb
C
   70 CONTINUE
C
      DO IA=1, NAX
       DO IS=1, 2
        DO I=1, NX
         W(I,IS,IA) = 0.
        END DO
       END DO
      END DO
C
      DO KA=1, NAPLT
        IA = IAPLT(KA)
        DO IS=1, 2
          IEND = II(IS,IA)-1
          DO I=ILE(IS,IA)+1, IEND
            W(I,IS,KA) = CF(I,IS,IA)
          END DO
        END DO
      END DO
C
      CALL PLTINI
      CALL PLOT(6.*CH,0.2,-3)
C
      CALL SCALIT(NX*2*NAPLT,W,0.0,YFAC)
      YFAC = 2.0*YFAC
C
      ANN = 1.0/YFAC
C
      YAXT = 0.6
C
      XOFF = 0.
      XSF = 0.6
C
      YOFF = 0.
      YSF = YFAC*YAXT
C
      FN = 5.
      CALL YAXIS(0.0,0.0,YAXT,YAXT/FN,0.0,ANN/FN,CH,3)
C
      XAX = 1.4*XSF
      CALL XAXIS(0.0,0.0,XAX,0.2*XSF,0.0,0.2,CH,1)
C
      CALL NEWPEN(3)
      CALL PLCHAR(-3.5*CH,2.5*YAXT/FN       ,1.4*CH,'C',0.0,1)
      CALL PLCHAR(-2.1*CH,2.5*YAXT/FN-0.4*CH,1.0*CH,'f',0.0,1)
      CALL IDENT(0.0,YAXT)
C
      CALL PLCHAR(1.1*XSF-0.6*CH,-3.5*CH,1.2*CH,'X',0.0,1)
C
      CALL NEWPEN(2)
      DO KA=1, NAPLT
        IA = IAPLT(KA)
        DO IS=1, 2
          IL = ILE(IS,IA)
          IEND = II(IS,IA)-1
          IF(IS.EQ.1) IEND = ITE(IS,IA)+1
          CALL XYLINE(IEND-1-IL,X(IL+1,IS,IA),W(IL+1,IS,KA),
     &                XOFF,XSF,YOFF,YSF,KA)
        END DO
      END DO
C
      CALL PLTFOR(0.65,YAXT)
C
      CALL PLFLUSH
ccc      WRITE(*,*) 'Hit <return>'
ccc      READ (*,1100) ANS
      GO TO 2
C
C=============================================
C**** plot A/Ao vs sb
   80 CONTINUE
C
      DO IA=1, NAX
       DO IS=1, 2
        DO I=1, NX
         W(I,IS,IA) = 0.
        END DO
       END DO
      END DO
C
      DO KA=1, NAPLT
        IA = IAPLT(KA)
        DO IS=1, 2
          ITR = ITRAN(IS,IA)
          DO I=ILE(IS,IA)+1, ITR-1
            W(I,IS,KA) = CTAU(I,IS,IA)
          END DO
        END DO
      END DO
C
      CALL PLTINI
      CALL PLOT(6.*CH,0.2,-3)
C
CCC      CALL SCALIT(NX*2*NAPLT,W,0.0,YFAC)
      YFAC = 1.0 / ( 2.0*AINT(0.5*(ACRIT + 1.0)) )
C
      ANN= 1.0/YFAC
C
      YAXT = 0.6
C
      YSF = YFAC*YAXT
      YOFF = 0.
C
      XOFF = 0.
      XSF = 0.6
      XAX = 1.4*XSF
C
      CALL XAXIS(0.0,0.0,XAX,0.2*XSF,0.0,0.2,CH,1)
C
      DANN = 2.0
      DYANN = YAXT/(ANN/DANN)
      CALL YAXIS(0.0,0.0,YAXT,DYANN,0.0,DANN,CH,1)
      CALL NEWPEN(3)
      CALL PLCHAR(-4.5*CH,4.4*DYANN       ,1.2*CH,'log',0.0,3)
      CALL PLCHAR(-5.0*CH,3.4*DYANN       ,1.2*CH,'A/A',0.0,3)
      CALL PLCHAR(-1.4*CH,3.4*DYANN-0.4*CH,0.8*CH,'0'  ,0.0,1)
      CALL IDENT(0.0,YAXT)
C
      CALL PLCHAR(1.1*XSF-0.6*CH,-3.5*CH,1.2*CH,'X',0.0,1)
C
      CALL DASH(0.0,1.0,(ACRIT-YOFF)*YSF)
C
      CALL NEWPEN(2)
      DO KA=1, NAPLT
        IA = IAPLT(KA)
        DO IS=1, 2
          IL = ILE(IS,IA)
          ITR = ITRAN(IS,IA)
          CALL XYLINE(ITR-(IL+1),X(IL+1,IS,IA),W(IL+1,IS,KA),
     &                XOFF,XSF,YOFF,YSF,KA)
        END DO
      END DO
C
      CALL PLTFOR(0.65,YAXT)
C
      CALL PLFLUSH
ccc      WRITE(*,*) 'Hit <return>'
ccc      READ (*,1100) ANS
      GO TO 2
C
C=============================================
C**** Plot Ctau vs sb
C
   90 CONTINUE
C
      DO IA=1, NAX
       DO IS=1, 2
        DO I=1, NX
         W(I,IS,IA) = 0.
        END DO
       END DO
      END DO
C
      DO KA=1, NAPLT
        IA = IAPLT(KA)
        DO IS=1, 2
          ITR = ITRAN(IS,IA)
          IEND = II(IS,IA)-1
          DO I=ITR, IEND
            W(I,IS,KA) = CTAU(I,IS,IA)
          END DO
        END DO
      END DO
C
      CALL PLTINI
      CALL PLOT(6.*CH,0.2,-3)
C
      CALL SCALIT(NX*2*NAPLT,W,0.0,YFAC)
C
      ANN = 1.0/YFAC
C
      YAXT = 0.6
C
      XOFF = 0.
      XSF = 0.6
C
      YOFF = 0.
      YSF = YFAC*YAXT
C
      XAX = 1.4*XSF
      CALL XAXIS(0.0,0.0,XAX,0.2*XSF,0.0,0.2,CH,1)
C
      FN = 5.
      CALL YAXIS(0.0,0.0,YAXT,YAXT/FN,0.0,ANN/FN,CH,2)
      CALL NEWPEN(3)
      CALL PLMATH(-4.5*CH,2.5*YAXT/FN       ,1.4*CH,'R  ',0.0,3)
      CALL PLCHAR(-4.5*CH,2.5*YAXT/FN       ,1.4*CH,' C ',0.0,3)
      CALL PLMATH(-2.1*CH,2.5*YAXT/FN-0.4*CH,1.0*CH,'  t',0.0,3)
      CALL IDENT(0.0,ANN*YSF)
C
      CALL PLCHAR(1.1*XSF-0.6*CH,-3.5*CH,1.2*CH,'X',0.0,1)
C
      CALL NEWPEN(2)
      DO KA=1, NAPLT
        IA = IAPLT(KA)
        DO IS=1, 2
          ITR = ITRAN(IS,IA)
          IEND = II(IS,IA)-1
          IF(IS.EQ.1) IEND = ITE(IS,IA)+1
          CALL XYLINE(IEND-ITR,X(ITR,IS,IA),W(ITR,IS,KA),
     &                XOFF,XSF,YOFF,YSF,KA)
        END DO
      END DO
C
      CALL PLTFOR(0.65,YAXT)
C
      CALL PLFLUSH
ccc      WRITE(*,*) 'Hit <return>'
ccc      READ (*,1100) ANS
      GO TO 2
C
C=============================================
C**** Change settings
C
  120 CONTINUE
      WRITE(*,*)
      WRITE(*,*) '  0  Cancel'
      WRITE(*,*) '  1  SIZE    plot size'
      WRITE(*,*) '  2  LREF    reference solution plotting flag'
      WRITE(*,*) '  3  LFORCE  force coefficient plotting flag'
      WRITE(*,*) '  4  NAME    case name'
      WRITE(*,*)
  129 WRITE(*,*) 'Change what ?'
      READ (*,*,ERR=129) NUM
      IF(NUM.EQ.0) RETURN
      IF(NUM.EQ.1) THEN
       WRITE(*,*) 'Currently SIZE = ',SIZE
  121  WRITE(*,*) 'Enter new value:'
       READ (*,*,ERR=121) SIZE
      ELSE IF(NUM.EQ.2) THEN
       LREF = .NOT.LREF
       IF(     LREF) WRITE(*,*) 'Reference data will be overlaid'
       IF(.NOT.LREF) WRITE(*,*) 'Reference data will not be overlaid'
      ELSE IF(NUM.EQ.3) THEN
       LFORCE = .NOT.LFORCE
       IF(     LFORCE) WRITE(*,*) 'Force coeffs. will be plotted'
       IF(.NOT.LFORCE) WRITE(*,*) 'Force coeffs. will not be plotted'
      ELSE IF(NUM.EQ.4) THEN
       WRITE(*,1200) NAME
 1200  FORMAT(1X,'Current NAME: ',A)
       WRITE(*,*) 'Enter new name:'
       READ (*,1210) NAME
 1210  FORMAT(A)
      ENDIF
      GO TO 2
C
C=============================================
C**** annotate plot
 130  IF(.NOT.LPLOT) THEN
        WRITE(*,*) 'No active plot to annotate'     
       ELSE
        CALL ANNOT(CH)
      ENDIF
      GO TO 2
C
C=============================================
C**** hardcopy output
 140  IF(LPLOT) CALL PLEND
      LPLOT = .FALSE.
      CALL REPLOT(IDEVRP)
      GO TO 2
C
      END     



      SUBROUTINE PLTINI
      INCLUDE 'PXPLOT.INC'
C
      IF(LPLOT) CALL PLEND
C
      CALL PLOPEN(SCRNFR,IPSLU,IDEV)
      LPLOT = .TRUE.
C
      CALL NEWFACTOR(SIZE)
C
      RETURN
      END
 
 
      SUBROUTINE XTICK(XOFF,YOFF,XSF,XLEN)
      CALL NEWPEN(1)
C
      CALL PLOT(0.,-YOFF,3)
      CALL PLOT(-XOFF*XSF,-YOFF,2)
C
      CALL PLOT(     -XOFF *XSF,-YOFF,3)
      CALL PLOT((XLEN-XOFF)*XSF,-YOFF,2)
      DO 10 NT=1, 9
        XT = FLOAT(NT)/10.
        CALL PLOT((XT-XOFF)*XSF,-YOFF+0.0025,3) 
        CALL PLOT((XT-XOFF)*XSF,-YOFF-0.0025,2) 
   10 CONTINUE
      DO 20 NT=0, 2
        XT = FLOAT(NT)/2.
        CALL PLOT((XT-XOFF)*XSF,-YOFF+0.005,3) 
        CALL PLOT((XT-XOFF)*XSF,-YOFF-0.005,2) 
   20 CONTINUE
      RETURN
      END ! XTICK


      SUBROUTINE RFPLOT(N,X,Y,XOFF,XWT,YOFF,YWT,CH,ID)
      REAL X(N), Y(N)
C
      ISYM = ID
      DO 10 I=1, N
        XPLT = XWT*(X(I)-XOFF)
        YPLT = YWT*(Y(I)-YOFF)
        IF(X(I).EQ.999.0) THEN
         ISYM = ISYM + 1
        ELSE
         CALL PLSYMB(XPLT,YPLT,CH,ISYM,0.0,0)
        ENDIF
   10 CONTINUE
C
      RETURN
      END ! RFPLOT



      SUBROUTINE AIRFOI(XOFF,YOFF,SF)
      INCLUDE 'PXPLOT.INC'
C
      CALL NEWPEN(2)
      IPEN = 3
      DO 10 IB=1, IIB
        CALL PLOT((XB(IB)-XOFF)*SF,(YB(IB)-YOFF)*SF,IPEN)
        IPEN = 2
   10 CONTINUE
C
      RETURN
      END ! AIRFOI

 
 
      SUBROUTINE PLTFOR(X1,Y1)
      INCLUDE 'PXPLOT.INC'
C
c      CH2 = 0.012
c      CH3 = 0.010
c      CHN = 0.015
C
      CH2 = 0.015
      CH3 = 0.013
      CHN = 0.018
C
C---- find index of last non-blank character in NAME array
      DO 10 LNB=32, 1, -1
        IF(NAME(LNB:LNB).NE.' ') GO TO 11
   10 CONTINUE
      LNB = 1
   11 CONTINUE
CCC      LNB = LNB-1
C
      XLAB = X1
      YLAB = Y1   !!!  - CHN
C
      IF(LNB.GT.0) THEN
       CALL NEWPEN(4)
       CALL PLCHAR(X1,YLAB,CHN,NAME,0.0,LNB)
       YLAB = YLAB - 0.5*CH2
      ENDIF
C
      IF(LMACH) THEN
       IF(LCLFIX) THEN
        XLAB = X1
        YLAB = YLAB - 2.2*CH2
        CALL NEWPEN(3)
        CALL PLCHAR(XLAB,YLAB,CH2,'CL    = ',0.0, 8)
        CALL NEWPEN(2)
        CALL PLNUMB(XLAB+ 8.0*CH2,YLAB,CH2,CL(1),0.0,4)
       ELSE
        XLAB = X1
        YLAB = YLAB - 2.2*CH2
        CALL NEWPEN(3)
        CALL PLCHAR(XLAB,YLAB,CH2,'Alfa  = ',0.0, 8)
        CALL NEWPEN(2)
        CALL PLNUMB(XLAB+ 8.0*CH2,YLAB,CH2,ALFA(1),0.0,4)
       ENDIF
      ELSE
       XLAB = X1
       YLAB = YLAB - 2.2*CH2
       CALL NEWPEN(3)
       ITYP = MATYP
       IF(ITYP.EQ.1) CALL PLCHAR(XLAB,YLAB,CH2,'Ma    = ',0.0, 8)
       IF(ITYP.EQ.2) CALL PLCHAR(XLAB,YLAB,CH2,'Ma CL = ',0.0, 8)
       IF(ITYP.EQ.2) CALL PLMATH(XLAB,YLAB,CH2,'  R     ',0.0, 8)
       IF(ITYP.EQ.3) CALL PLCHAR(XLAB,YLAB,CH2,'Ma CL = ',0.0, 8)
       IF(ITYP.EQ.3) CALL PLMATH(XLAB,YLAB,CH2,'  #     ',0.0, 8)
       CALL NEWPEN(2)
       CALL PLNUMB(XLAB+ 8.0*CH2,YLAB        ,     CH2, MACH,0.0,4)
      ENDIF
C
      IF(REYN.NE.0.0) THEN
       YLAB = YLAB - 2.0*CH2
       CALL NEWPEN(3)
       ITYP = RETYP
       IF(ITYP.EQ.1) CALL PLCHAR(XLAB,YLAB,CH2,'Re    = ',0.0, 8)
       IF(ITYP.EQ.2) CALL PLCHAR(XLAB,YLAB,CH2,'Re CL = ',0.0, 8)
       IF(ITYP.EQ.2) CALL PLMATH(XLAB,YLAB,CH2,'  R     ',0.0, 8)
       IF(ITYP.EQ.3) CALL PLCHAR(XLAB,YLAB,CH2,'Re CL = ',0.0, 8)
       IF(ITYP.EQ.3) CALL PLMATH(XLAB,YLAB,CH2,'  #     ',0.0, 8)
       CALL NEWPEN(2)
       CALL PLNUMB(XLAB+ 8.0*CH2,YLAB        ,     CH2, REYN  ,0.0,4)
       CALL PLMATH(XLAB+14.0*CH2,YLAB+0.2*CH2,0.80*CH2,' #   ',0.0,5)
       CALL PLCHAR(XLAB+14.0*CH2,YLAB        ,     CH2,'  10 ',0.0,5)
       CALL PLMATH(XLAB+14.0*CH2,YLAB+0.6*CH2,     CH2,'    6',0.0,5)
C
       YLAB = YLAB - 2.0*CH2
       CALL NEWPEN(3)
       CALL PLCHAR(XLAB        ,YLAB,     CH2,'N'   ,0.0,1)
       CALL PLCHAR(XLAB+1.0*CH2,YLAB,0.75*CH2,'crit',0.0,4)
       CALL PLCHAR(XLAB+4.0*CH2,YLAB,     CH2,'  = ',0.0,4)
       CALL NEWPEN(2)
       CALL PLNUMB(XLAB+8.0*CH2,YLAB,     CH2, ACRIT,0.0,3)
      ENDIF
C
      XL1 = XLAB 
      XL2 = XL1 + 7.0*CH3
      XL3 = XL2 + 8.0*CH3
      XL4 = XL3 + 9.0*CH3
      XL5 = XL4 + 8.0*CH3
      XL6 = XL5 + 7.0*CH3
      YLAB = YLAB - 2.7*CH3
      CALL NEWPEN(3)
      IF(LMACH) THEN
       CALL PLCHAR(XL1+0.5*CH3,YLAB,CH3,'Mach' ,0.0,4)
       IF(LCLFIX) THEN
        CALL PLCHAR(XL2+0.5*CH3,YLAB,CH3,'Alfa',0.0,4)
       ELSE
        CALL PLCHAR(XL2+0.5*CH3,YLAB,CH3,' CL ',0.0,4)
       ENDIF
      ELSE
       CALL PLCHAR(XL1+0.5*CH3,YLAB,CH3,'Alfa' ,0.0,4)
       CALL PLCHAR(XL2+0.5*CH3,YLAB,CH3,' CL ' ,0.0,4)
      ENDIF
      CALL PLCHAR(XL3+2.5*CH3,YLAB,CH3,'CD'   ,0.0,2)
      CALL PLCHAR(XL4+2.0*CH3,YLAB,CH3,'CM'   ,0.0,2)
      IF(REYN.NE.0.0) THEN
       CALL PLCHAR(XL5+1.5*CH3,YLAB,    CH3,'Xtr',0.0,3)
       CALL PLCHAR(999.       ,YLAB,0.6*CH3,'T'  ,0.0,1)
       CALL PLCHAR(XL6+1.5*CH3,YLAB,    CH3,'Xtr',0.0,3)
       CALL PLCHAR(999.       ,YLAB,0.6*CH3,'B'  ,0.0,1)
      ENDIF
C
      CALL NEWPEN(1)
      CALL PLOT(XL1        ,YLAB-0.4*CH3,3)
      CALL PLOT(XL1+5.0*CH3,YLAB-0.4*CH3,2)
      CALL PLOT(XL2        ,YLAB-0.4*CH3,3)
      CALL PLOT(XL2+6.0*CH3,YLAB-0.4*CH3,2)
      CALL PLOT(XL3        ,YLAB-0.4*CH3,3)
      CALL PLOT(XL3+7.0*CH3,YLAB-0.4*CH3,2)
      CALL PLOT(XL4        ,YLAB-0.4*CH3,3)
      CALL PLOT(XL4+6.0*CH3,YLAB-0.4*CH3,2)
      IF(REYN.NE.0.0) THEN
       CALL PLOT(XL5        ,YLAB-0.4*CH3,3)
       CALL PLOT(XL5+5.0*CH3,YLAB-0.4*CH3,2)
       CALL PLOT(XL6        ,YLAB-0.4*CH3,3)
       CALL PLOT(XL6+5.0*CH3,YLAB-0.4*CH3,2)
      ENDIF
C
      CALL NEWPEN(2)
      YLAB = YLAB - 0.5*CH3
      DO 50 KA=1, NAPLT
        IA = IAPLT(KA)
        DXL1 = 0.
        DXL2 = 0.
        DXL3 = 0.
        DXL4 = 0.
        IF(LMACH) THEN
         IF(LCLFIX) THEN
          IF(ALFA(IA).LT.0.0) DXL2 = -CH3
         ELSE
          IF(  CL(IA).LT.0.0) DXL2 = -CH3
         ENDIF
        ELSE
         IF(ALFA(IA).LT.0.0) DXL1 = -CH3
         IF(  CL(IA).LT.0.0) DXL2 = -CH3
        ENDIF

        IF(  CD(IA).LT.0.0) DXL3 = -CH3
        IF(  CM(IA).LT.0.0) DXL4 = -CH3
        YLAB = YLAB - 2.0*CH3
        IF(LMACH) THEN
         CALL PLNUMB(XL1+DXL1,YLAB,CH3,  MA(IA),0.0,3)
         IF(LCLFIX) THEN
          CALL PLNUMB(XL2+DXL2,YLAB,CH3,ALFA(IA),0.0,3)
         ELSE
          CALL PLNUMB(XL2+DXL2,YLAB,CH3,  CL(IA),0.0,4)
         ENDIF
        ELSE
         CALL PLNUMB(XL1+DXL1,YLAB,CH3,ALFA(IA),0.0,3)
         CALL PLNUMB(XL2+DXL2,YLAB,CH3,  CL(IA),0.0,4)
        ENDIF
        CALL PLNUMB(XL3+DXL3,YLAB,CH3,  CD(IA),0.0,5)
        CALL PLNUMB(XL4+DXL3,YLAB,CH3,  CM(IA),0.0,3)
        IF(REYN.NE.0.0) THEN
         CALL PLNUMB(XL5,YLAB,CH3,XTR(1,IA),0.0,3)
         CALL PLNUMB(XL6,YLAB,CH3,XTR(2,IA),0.0,3)
        ENDIF
   50 CONTINUE
C
      RETURN
      END ! PLTFOR
 
 
 
      SUBROUTINE GETREF(X,Y,N)
      REAL X(1), Y(1)
      CHARACTER*132 FNAME
C
      WRITE(*,*) 'Enter reference solution filename:'
      READ (*,1000) FNAME
 1000 FORMAT(A)
C
      OPEN(UNIT=1,FILE=FNAME,STATUS='OLD',ERR=5)
      GO TO 10
C
    5 WRITE(*,*) '***   File open error   ***'
      CLOSE(UNIT=1)
      RETURN
C
   10 DO 11 I=1, 500
        READ(1,*,END=12) X(I), Y(I)
   11 CONTINUE
   12 N = I-1
C
      CLOSE(UNIT=1)
      RETURN
      END ! GETREF



      SUBROUTINE READIT(FNAME)
C
C--- Uncomment for Win32/Compaq Visual Fortran compiler (needed for GETARG)
ccc      USE DFLIB
C
      INCLUDE 'PXPLOT.INC'
      CHARACTER*132 FNAME
C
 10   IF(FNAME.EQ.' ') THEN 
       WRITE(*,*) 'Enter polar dump filename'
       READ (*,1000) FNAME
      ENDIF
C
      IF(FNAME.EQ.' ') RETURN
C
      OPEN(11,FILE=FNAME,STATUS='OLD',FORM='UNFORMATTED',ERR=800)
C
      READ(11) NAME, CODE, VERSION
      READ(11) MACH, REYN, ACRIT
      READ(11) MATYP, RETYP
      READ(11) IITOT, ILETOT, ITETOT, IIB
      READ(11) (XB(IB), YB(IB), IB=1, IIB)
C
C---- T if this is an ISES polar, F if XFOIL polar
      LISES = IITOT .NE. 0
C
C---- T if this is a Mach sweep, F if alpha sweep
      LMACH = (MACH .EQ. 0.0) .AND. LISES
C
      DO IA=1, NAX
C
        IF(LISES) THEN
C------- ISES dump file read
         IF(LMACH) THEN
          READ(11,END=30) 
     &     ALFA(IA),CL(IA),CD(IA),CDI(IA),CM(IA),XTR(1,IA),XTR(2,IA),
     &     MA(IA)
         ELSE
          READ(11,END=30)
     &     ALFA(IA),CL(IA),CD(IA),CDI(IA),CM(IA),XTR(1,IA),XTR(2,IA)
          IF(MATYP.EQ.1) MA(IA) = MACH
          IF(MATYP.EQ.2) MA(IA) = MACH/SQRT(CL(IA))
          IF(MATYP.EQ.3) MA(IA) = MACH/CL(IA)
         ENDIF
         II(1,IA) = IITOT
         II(2,IA) = IITOT
         ILE(1,IA) = ILETOT
         ILE(2,IA) = ILETOT
         ITE(1,IA) = ITETOT
         ITE(2,IA) = ITETOT
        ELSE
C------- XFOIL dump file read
         READ(11,END=30)
     &     ALFA(IA),CL(IA),CD(IA),CDI(IA),CM(IA),XTR(1,IA),XTR(2,IA)
         READ(11,END=30) II(1,IA), II(2,IA), ITE(1,IA), ITE(2,IA)
         ILE(1,IA) = 1
         ILE(2,IA) = 1
         IF(MATYP.EQ.1) MA(IA) = MACH
         IF(MATYP.EQ.2) MA(IA) = MACH/SQRT(CL(IA))
         IF(MATYP.EQ.3) MA(IA) = MACH/CL(IA)
        ENDIF
C
        DO IS=1, 2
          IF(II(IS,IA).GT.NX) STOP 'Array overflow.  Increase NX.'
          READ(11,END=30) (X(I,IS,IA),CP(I,IS,IA),
     &                     THET(I,IS,IA),DSTR(I,IS,IA),
     &                     CF(I,IS,IA), CTAU(I,IS,IA), I=1, II(IS,IA))
         END DO
C
      END DO
      WRITE(*,*) 'Point array limit NAX reached.'
C
 30   NA = IA - 1
      CLOSE(11)
C
      DO IA=1, NA
        DO 40 IS=1, 2
          DO I=ILE(IS,IA)+2, II(IS,IA)-1
            IF(X(I-1,IS,IA).LT.XTR(IS,IA) .AND.
     &         X(I  ,IS,IA).GE.XTR(IS,IA)      ) THEN
             ITRAN(IS,IA) = I
             GO TO 40
            ENDIF
          END DO
 40     CONTINUE
      END DO
C
      GAM = 1.4
      GM1 = GAM - 1.0
C
      DO IA=1, NA
        CPSTAR(IA) = -999.0
        IF(MA(IA) .NE. 0.0) THEN
         MACHSQ = MA(IA)**2
         CPSTAR(IA) = ( ( (1.0+0.5*GM1*MACHSQ)
     &                   /(1.0+0.5*GM1       ) )**(GAM/GM1) - 1.0 )
     &              / (0.5*GAM*MACHSQ)
        ENDIF
      END DO
C
      CLOSE(11)
C
C---- set flags indicating if CL or alpha have been held fixed (in Mach sweep)
      LCLFIX = .TRUE.
      LALFIX = .TRUE.
      DO IA=1, NA-1
        ADCL = ABS(   CL(IA) -   CL(IA+1) )
        ADAL = ABS( ALFA(IA) - ALFA(IA+1) )
        IF(ADCL .GT. 0.001) LCLFIX = .FALSE.
        IF(ADAL .GT. 0.001) LALFIX = .FALSE.
      END DO
      GO TO 900
C
 800  WRITE(*,*) 'Error opening polar dump file '
C      
 900  RETURN
C
 1000 FORMAT(A)
      END ! READIT


      SUBROUTINE IDENT(XID,YID)
      INCLUDE 'PXPLOT.INC'
C
C---- plot code and version identifier
      CALL NEWPEN(1)
      CHI = 0.012
      CALL PLCHAR(XID+    CHI,YID-1.0*CHI,CHI,CODE   ,0.0,5)
      CALL PLCHAR(XID+    CHI,YID-3.0*CHI,CHI,'V'    ,0.0,1)
      CALL PLNUMB(XID+3.0*CHI,YID-3.0*CHI,CHI,VERSION,0.0,2)
C
      RETURN
      END ! IDENT



