/* 
 * C Wrapper for AUTO user functions - proper global linkage
 * Includes only the necessary parts of auto_f2c.h without the static declarations
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <math.h>

/* Type definitions from auto_f2c.h */
typedef int integer;
typedef float real;
typedef double doublereal;
typedef struct { real r, i; } complex;
typedef struct {doublereal r, i; } doublecomplex;
typedef integer logical;

#define TRUE_ (1)
#define FALSE_ (0)

#define ARRAY2D(array,i,j) array[(i) + (j) * array ## _dim1]
#define ARRAY3D(array,i,j,k) array[(i) + ((j)  + (k) * array ## _dim2) * array ## _dim1]

/* External common blocks needed */
extern struct {
    integer itwist, istart, iequib, nfixed, npsi, nunstab, nstab, nrev;
} blhom_1;

/* ================================================================  */
/* Function implementations - declared with global extern linkage   */
/* ================================================================  */

int func(integer ndim, const doublereal *u, const integer *icp, 
	const doublereal *par, integer ijac, doublereal *f, doublereal *dfdu, 
	doublereal *dfdp)
{
    /* System generated locals */
    integer dfdu_dim1 = ndim, dfdp_dim1 = ndim;

    /* Function Body */
    f[0] = u[1];
    f[1] = par[0] * u[1] + u[0] * (u[0] - par[1]) * (u[0] - 1.) + u[2];
    f[2] = par[2] * u[0] / par[0];

    if (ijac == 0) {
	return 0;
    }

    ARRAY2D(dfdu,0,0) = 0.;
    ARRAY2D(dfdu,0,1) = 1.;
    ARRAY2D(dfdu,0,2) = 0.;

    ARRAY2D(dfdu,1,0) = u[0] * 3 * u[0] - (par[1] + 1) * 2 * u[0] + par[1];
    ARRAY2D(dfdu,1,1) = par[0];
    ARRAY2D(dfdu,1,2) = 1.;

    ARRAY2D(dfdu,2,0) = par[2] / par[0];
    ARRAY2D(dfdu,2,1) = 0.;
    ARRAY2D(dfdu,2,2) = 0.;

    if (ijac == 1) {
	return 0;
    }


    ARRAY2D(dfdp,0,0) = 0.;
    ARRAY2D(dfdp,0,1) = 0.;
    ARRAY2D(dfdp,0,2) = 0.;

    ARRAY2D(dfdp,1,0) = u[1];
    ARRAY2D(dfdp,1,1) = -u[0] * (u[0] - 1.);
    ARRAY2D(dfdp,1,2) = 0.;

    ARRAY2D(dfdp,2,0) = -par[2] * u[0] / (par[0] * par[0]);
    ARRAY2D(dfdp,2,1) = 0.;
    ARRAY2D(dfdp,2,2) = u[0] / par[0];

    return 0;
}

int stpnt(integer ndim, doublereal t, doublereal *u, doublereal *par)
{
    par[0] = .21;
    par[1] = .2;
    par[2] = .0025;
    par[10] = .1;

    if (blhom_1.iequib != 0) {
	par[11] = 0.;
	par[12] = 0.;
	par[13] = 0.;
    }

    if (blhom_1.istart == 3) {
	par[ndim * blhom_1.iequib + 11] = 1e-5;
    }

    return 0;
}

int pvls(integer ndim, const doublereal *u, doublereal *par)
{
    return 0;
}

int bcnd(integer ndim, const doublereal *par, const integer *icp,
         integer nbc, const doublereal *u0, const doublereal *u1, integer ijac,
         doublereal *fb, doublereal *dbc)
{
    return 0;
}

int icnd(integer ndim, const doublereal *par, const integer *icp, integer nint,
         const doublereal *u, const doublereal *uold, const doublereal *udot,
         const doublereal *upold, integer ijac, doublereal *fi, doublereal *dint)
{
    return 0;
}

int fopt(integer ndim, const doublereal *u, const integer *icp, const doublereal *par,
         integer ijac, doublereal *fs, doublereal *dfdu, doublereal *dfdp)
{
    return 0;
}
