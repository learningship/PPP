////#include "rtklib.h"
////void main()
////{
////FILE *fp2 = 
////}
///*------------------------------------------------------------------------------
//* rnx2rtkp.c : read rinex obs/nav files and compute receiver positions
//*
//*          Copyright (C) 2007-2016 by T.TAKASU, All rights reserved.
//*
//* version : $Revision: 1.1 $ $Date: 2008/07/17 21:55:16 $
//* history : 2007/01/16  1.0 new
//*           2007/03/15  1.1 add library mode
//*           2007/05/08  1.2 separate from postpos.c
//*           2009/01/20  1.3 support rtklib 2.2.0 api
//*           2009/12/12  1.4 support glonass
//*                           add option -h, -a, -l, -x
//*           2010/01/28  1.5 add option -k
//*           2010/08/12  1.6 add option -y implementation (2.4.0_p1)
//*           2014/01/27  1.7 fix bug on default output time format
//*           2015/05/15  1.8 -r or -l options for fixed or ppp-fixed mode
//*           2015/06/12  1.9 output patch level in header
//*           2016/09/07  1.10 add option -sys
//*-----------------------------------------------------------------------------*/
//#include <stdarg.h>
//#include "rtklib.h"
//
//#define PROGNAME    "rnx2rtkp"          /* program name */
//#define MAXFILE     16                  /* max number of input files */
//
//static pcvs_t pcvss = { 0 };        /* receiver antenna parameters */
//static pcvs_t pcvsr = { 0 };        /* satellite antenna parameters */
//static obs_t obss = { 0 };          /* observation data */
//static nav_t navs = { 0 };          /* navigation data */
//static sta_t stas[MAXRCV];      /* station infomation */
//static int iobsu = 0;            /* current rover observation data index */
//static int iobsr = 0;            /* current reference observation data index */
//static int isbs = 0;            /* current sbas message index */
//static int revs = 0;            /* analysis direction (0:forward,1:backward) */
//static int aborts = 0;            /* abort status */
//static int nepoch = 0;            /* number of observation epochs */
//
//#define MAXRNXLEN   (16000*MAXOBSTYPE+4)   /* max RINEX record length */
//rtk_t *rtk;
//obsd_t *obs = { 0 };
//nav_t *nav = { 0 };
//char buff[MAXRNXLEN];
//double val[MAXOBSTYPE] = { 0 };
//
///* show message --------------------------------------------------------------*/
//extern int showmsg(const char *format, ...)
//{
//	va_list arg;
//	va_start(arg, format); vfprintf(stderr, format, arg); va_end(arg);
//	fprintf(stderr, "\r");
//	return 0;
//}
//extern void settspan(gtime_t ts, gtime_t te) {}
//extern void settime(gtime_t time) {}
//static FILE *openfile(const char *outfile)
//{
//	trace(3, "openfile: outfile=%s\n", outfile);
//
//	return !*outfile ? stdout : fopen(outfile, "ab");
//}
///* output reference position -------------------------------------------------*/
//static void outrpos(FILE *fp, const double *r, const solopt_t *opt)
//{
//	double pos[3], dms1[3], dms2[3];
//	const char *sep = opt->sep;
//
//	trace(3, "outrpos :\n");
//
//	if (opt->posf == SOLF_LLH || opt->posf == SOLF_ENU) {
//		ecef2pos(r, pos);
//		if (opt->degf) {
//			deg2dms(pos[0] * R2D, dms1, 5);
//			deg2dms(pos[1] * R2D, dms2, 5);
//			fprintf(fp, "%3.0f%s%02.0f%s%08.5f%s%4.0f%s%02.0f%s%08.5f%s%10.4f",
//				dms1[0], sep, dms1[1], sep, dms1[2], sep, dms2[0], sep, dms2[1],
//				sep, dms2[2], sep, pos[2]);
//		}
//		else {
//			fprintf(fp, "%13.9f%s%14.9f%s%10.4f", pos[0] * R2D, sep, pos[1] * R2D,
//				sep, pos[2]);
//		}
//	}
//	else if (opt->posf == SOLF_XYZ) {
//		fprintf(fp, "%14.4f%s%14.4f%s%14.4f", r[0], sep, r[1], sep, r[2]);
//	}
//}
///* output header -------------------------------------------------------------*/
//static void outheader(FILE *fp, char **file, int n, const prcopt_t *popt,
//	const solopt_t *sopt)
//{
//	const char *s1[] = { "GPST","UTC","JST" };
//	gtime_t ts, te;
//	double t1, t2;
//	int i, j, w1, w2;
//	char s2[32], s3[32];
//
//	trace(3, "outheader: n=%d\n", n);
//
//	if (sopt->posf == SOLF_NMEA || sopt->posf == SOLF_STAT) {
//		return;
//	}
//	if (sopt->outhead) {
//		if (!*sopt->prog) {
//			fprintf(fp, "%s program   : RTKLIB ver.%s\n", COMMENTH, VER_RTKLIB);
//		}
//		else {
//			fprintf(fp, "%s program   : %s\n", COMMENTH, sopt->prog);
//		}
//		for (i = 0; i < n; i++) {
//			fprintf(fp, "%s inp file  : %s\n", COMMENTH, file[i]);
//		}
//		for (i = 0; i < obss.n; i++)    if (obss.data[i].rcv == 1) break;
//		for (j = obss.n - 1; j >= 0; j--) if (obss.data[j].rcv == 1) break;
//		if (j < i) { fprintf(fp, "\n%s no rover obs data\n", COMMENTH); return; }
//		ts = obss.data[i].time;
//		te = obss.data[j].time;
//		t1 = time2gpst(ts, &w1);
//		t2 = time2gpst(te, &w2);
//		if (sopt->times >= 1) ts = gpst2utc(ts);
//		if (sopt->times >= 1) te = gpst2utc(te);
//		if (sopt->times == 2) ts = timeadd(ts, 9 * 3600.0);
//		if (sopt->times == 2) te = timeadd(te, 9 * 3600.0);
//		time2str(ts, s2, 1);
//		time2str(te, s3, 1);
//		fprintf(fp, "%s obs start : %s %s (week%04d %8.1fs)\n", COMMENTH, s2, s1[sopt->times], w1, t1);
//		fprintf(fp, "%s obs end   : %s %s (week%04d %8.1fs)\n", COMMENTH, s3, s1[sopt->times], w2, t2);
//	}
//	if (sopt->outopt) {
//		outprcopt(fp, popt);
//	}
//	if (PMODE_DGPS <= popt->mode&&popt->mode <= PMODE_FIXED && popt->mode != PMODE_MOVEB) {
//		fprintf(fp, "%s ref pos   :", COMMENTH);
//		outrpos(fp, popt->rb, sopt);
//		fprintf(fp, "\n");
//	}
//	if (sopt->outhead || sopt->outopt) fprintf(fp, "%s\n", COMMENTH);
//
//	outsolhead(fp, sopt);
//}
///* write header to output file -----------------------------------------------*/
//static int outhead(const char *outfile, char **infile, int n,
//	const prcopt_t *popt, const solopt_t *sopt)
//{
//	FILE *fp = stdout;
//
//	trace(3, "outhead: outfile=%s n=%d\n", outfile, n);
//
//	if (*outfile) {
//		createdir(outfile);
//
//		if (!(fp = fopen(outfile, "wb"))) {
//			showmsg("error : open output file %s", outfile);
//			return 0;
//		}
//	}
//	/* output header */
//	outheader(fp, infile, n, popt, sopt);
//
//	if (*outfile) fclose(fp);
//
//	return 1;
//}
//
///* free obs and nav data -----------------------------------------------------*/
//static void freeobsnav(obs_t *obs, nav_t *nav)
//{
//	trace(3, "freeobsnav:\n");
//
//	free(obs->data); obs->data = NULL; obs->n = obs->nmax = 0;
//	free(nav->eph); nav->eph = NULL; nav->n = nav->nmax = 0;
//	free(nav->geph); nav->geph = NULL; nav->ng = nav->ngmax = 0;
//	free(nav->seph); nav->seph = NULL; nav->ns = nav->nsmax = 0;
//}
///* search next observation data index ----------------------------------------*/
//static int nextobsf(const obs_t *obs, int *i, int rcv)
//{
//	double tt;
//	int n;
//
//	for (; *i < obs->n; (*i)++) if (obs->data[*i].rcv == rcv) break;
//	for (n = 0; *i + n < obs->n; n++) {
//		tt = timediff(obs->data[*i + n].time, obs->data[*i].time);
//		if (obs->data[*i + n].rcv != rcv || tt > DTTOL) break;
//	}
//	return n;
//}
//static int inputobs(obsd_t *obs, int solq, const prcopt_t *popt)
//{
//	gtime_t time = { 0 };
//	int i, nu, nr, n = 0;
//	/* input forward data */
//	if ((nu = nextobsf(&obss, &iobsu, 1)) <= 0) return -1;
//	if (popt->intpref) {
//		for (; (nr = nextobsf(&obss, &iobsr, 2)) > 0; iobsr += nr)
//			if (timediff(obss.data[iobsr].time, obss.data[iobsu].time) > -DTTOL) break;
//	}
//	else {
//		for (i = iobsr; (nr = nextobsf(&obss, &i, 2)) > 0; iobsr = i, i += nr)
//			if (timediff(obss.data[i].time, obss.data[iobsu].time) > DTTOL) break;
//	}
//	nr = nextobsf(&obss, &iobsr, 2);
//	if (nr <= 0) {
//		nr = nextobsf(&obss, &iobsr, 2);
//	}
//	for (i = 0; i < nu&&n < MAXOBS * 2; i++) obs[n++] = obss.data[iobsu + i];
//	for (i = 0; i < nr&&n < MAXOBS * 2; i++) obs[n++] = obss.data[iobsr + i];
//	iobsu += nu;
//	return n;
//}
///* carrier-phase bias correction by ssr --------------------------------------*/
//static void corr_phase_bias_ssr(obsd_t *obs, int n, const nav_t *nav)
//{
//	double freq;
//	uint8_t code;
//	int i, j;
//
//	for (i = 0; i < n; i++) for (j = 0; j < NFREQ; j++) {
//		code = obs[i].code[j];
//
//		if ((freq = sat2freq(obs[i].sat, code, nav)) == 0.0) continue;
//
//		/* correct phase bias (cyc) */
//		obs[i].L[j] -= nav->ssr[obs[i].sat - 1].pbias[code - 1] * freq / CLIGHT;
//	}
//}
///* rnx2rtkp main -------------------------------------------------------------*/
//int main(int argc, char **argv)
//{
//	FILE *fp;
//	prcopt_t prcopt = prcopt_default;
//	solopt_t solopt = solopt_default;
//	filopt_t filopt = { "" };
//
//	gtime_t ts = { 0 }, te = { 0 };
//	double tint = 0.0, es[] = { 2019,1,10,10,0,0 }, ee[] = { 2019,1,10,10,4,30 }, pos[3];
//
//	ts = epoch2time(es);
//    te = epoch2time(ee);
//	int i, j, n, ret;
//	char *infile[MAXFILE], *outfile = "", *p, *file_conf;
//	char tracefile[1024], statfile[1024], path[1024], *ext;
//
//
//	obss.data = NULL; obss.n = obss.nmax = 0;
//	navs.eph = NULL; navs.n = navs.nmax = 0;
//	navs.geph = NULL; navs.ng = navs.ngmax = 0;
//	navs.seph = NULL; navs.ns = navs.nsmax = 0;
//	nepoch = 0;
//	n = 3;
//	//file_conf = "D:\\mycode\\vscode\\rtklib\\rtklib\\ppp.conf";
//	//infile[0] = "D:\\mycode\\vscode\\rtklib\\rtklib\\new data\\bjfs0100.19n";
//	//infile[1] = "D:\\mycode\\vscode\\rtklib\\rtklib\\new data\\bjfs0100.19o";
//	//infile[2] = "D:\\mycode\\vscode\\rtklib\\rtklib\\new data\\igs20354.clk";
//	//infile[3] = "D:\\mycode\\vscode\\rtklib\\rtklib\\new data\\igs20354.sp3";
//	//infile[4] = "D:\\mycode\\vscode\\rtklib\\rtklib\\new data\\igsg0100.19i";
//	//infile[5] = "D:\\mycode\\vscode\\rtklib\\rtklib\\new data\\igs20427.erp";
//	//infile[6] = "D:\\mycode\\vscode\\rtklib\\rtklib\\new data\\igs14.atx";
//	//outfile = "ppp_test01.pos";
//	file_conf = "D:\\mycode\\vscode\\rtklib\\rtklib\\ppp.conf";
//	//infile[0] = "D:\\mycode\\vscode\\rtklib\\rtklib\\data\\daej190k00.19n";
//	//infile[1] = "D:\\mycode\\vscode\\rtklib\\rtklib\\data\\daej190k15.19n";
//	//infile[2] = "D:\\mycode\\vscode\\rtklib\\rtklib\\data\\daej190k30.19n";
//	//infile[3] = "D:\\mycode\\vscode\\rtklib\\rtklib\\data\\daej190k45.19n";
//	//infile[4] = "D:\\mycode\\vscode\\rtklib\\rtklib\\data\\daej190k00.19o";
//	//infile[5] = "D:\\mycode\\vscode\\rtklib\\rtklib\\data\\daej190k15.19o";
//	//infile[6] = "D:\\mycode\\vscode\\rtklib\\rtklib\\data\\daej190k30.19o";
//	//infile[7] = "D:\\mycode\\vscode\\rtklib\\rtklib\\data\\daej190k45.19o";
//	//infile[8] = "D:\\mycode\\vscode\\rtklib\\rtklib\\data\\igs20612.clk";
//	//infile[9] = "D:\\mycode\\vscode\\rtklib\\rtklib\\data\\igs20612.sp3";
//	//infile[10] = "D:\\mycode\\vscode\\rtklib\\rtklib\\data\\igs20617.erp";
//	//infile[11] = "D:\\mycode\\vscode\\rtklib\\rtklib\\data\\igs14.atx";
//	//infile[12] = "D:\\mycode\\vscode\\rtklib\\rtklib\\data\\CAS0MGXRAP_20191900000_01D_01D_DCB.BSX";
//	//infile[13] = "D:\\mycode\\vscode\\rtklib\\rtklib\\data\\igsg1900.19i";
//	//infile[14] = "D:\\mycode\\vscode\\rtklib\\rtklib\\data\\WHU0IGSFIN_20191900000_01D_01D_ABS.BIA";
//	//infile[15] = "D:\\mycode\\vscode\\rtklib\\rtklib\\data\\WHU5IGSFIN_20191900000_01D_30S_CLK.CLK";
//	//infile[0] = "D:\\mycode\\vscode\\rtklib\\rtklib\\datas\\gpsP11.txt";
//	//infile[1] = "D:\\mycode\\vscode\\rtklib\\rtklib\\datas\\gpsP12.txt";
//	//infile[2] = "D:\\mycode\\vscode\\rtklib\\rtklib\\datas\\gpsL11.txt";
//	//infile[3] = "D:\\mycode\\vscode\\rtklib\\rtklib\\datas\\gpsL12.txt";
//	//infile[4] = "D:\\mycode\\vscode\\rtklib\\rtklib\\datas\\leodata.sp3";
//	//infile[5] = "D:\\mycode\\vscode\\rtklib\\rtklib\\datas\\igs20354.sp3";
//	//infile[6] = "D:\\mycode\\vscode\\rtklib\\rtklib\\datas\\bjfs0100.obs"; 
//	infile[0] = "D:\\mycode\\vscode\\rtklib\\rtklib\\leo_data\\leo.nav";
//	infile[1] = "D:\\mycode\\vscode\\rtklib\\rtklib\\leo_data\\leoerror.obs";
//	infile[2] = "D:\\mycode\\vscode\\rtklib\\rtklib\\leo_data\\leo.sp3";
//	//infile[3] = "D:\\mycode\\vscode\\rtklib\\rtklib\\data\\daej190k00.19o";
//	outfile = "ppp_leo011.pos";
//	/* load options from configuration file */
//	resetsysopts();
//	if (!loadopts(file_conf, sysopts)) return -1;
//	getsysopts(&prcopt, &solopt, &filopt);
//
//	prcopt.mode = PMODE_PPP_STATIC;
//	prcopt.navsys = SYS_GPS;
//	prcopt.refpos = 1;
//	prcopt.glomodear = 1;
//	prcopt.modear = 1;/* AR mode (0:off,1:continuous,2:instantaneous,3:fix and hold,4:ppp-ar) */
//	prcopt.tidecorr = 0;/* earth tide correction (0:off,1:solid,2:solid+otl+pole) */
//	prcopt.ionoopt = IONOOPT_IFLC;
//	prcopt.tropopt = TROPOPT_ESTG;
//	solopt.timef = 0;
//	solopt.sstat = 2;
//	solopt.trace = 4;
//
//
//
//	/* open debug trace */
//	if (solopt.trace > 0) {
//		if (*outfile) {
//			strcpy(tracefile, outfile);
//			strcat(tracefile, ".trace");
//		}
//		else {
//			strcpy(tracefile, filopt.trace);
//		}
//		traceclose();
//		traceopen(tracefile);
//		tracelevel(solopt.trace);
//	}
////	double pos1[] = { 39.9289*D2R,116.388*D2R,100 };
////	double x[] = { 0 };
////	pos2ecef(pos1, x);
////	for (i = 0; i < 3; i++) {
////		printf("%.6f ", x[i]);
////	}
//////	readsp3(infile[5], &navs, 0);
////	readsp3(infile[4], &navs, 0);
////	readrnxt(infile[6], 1, ts, te, tint, &prcopt, &obss, &navs, &stas);
//	//j = 0;
//	//FILE *fp1;
//	//fp1 = fopen(infile[0], "r");
//	//while (fgets(buff, MAXRNXLEN, fp1)) 
//	//{
//	//	for (i = 0; i < 40; i++) {
//	//		val[i] = str2num(buff, 20 * i, 17);
//	//	}
//	//	for (int n = 0; n < 40; n++) {
//	//		obs[j].P[2 * n] = val[n];
//	//	}
//	//	j++;
//	//}
//	//fclose(fp1);
//	//j = 0;
//	//fp1 = fopen(infile[1], "r");
//	//while (fgets(buff, MAXRNXLEN, fp1))
//	//{
//	//	for (i = 0; i < 40; i++) {
//	//		val[i] = str2num(buff, 20 * i, 17);
//	//	}
//	//	for (int n = 0; n < 40; n++) {
//	//		obs[j].P[2 * n + 1] = val[n];
//	//	}
//	//	j++;
//	//}
//	//fclose(fp1);
//	//fp1 = fopen(infile[2], "r");
//	//while (fgets(buff, MAXRNXLEN, fp1))
//	//{
//	//	for (i = 0; i < 40; i++) {
//	//		val[i] = str2num(buff, 20 * i, 18);
//	//	}
//	//	for (int n = 0; n < 40; n++) {
//	//		obs[j].L[2 * n] = val[n];
//	//	}
//	//	j++;
//	//}
//	//fclose(fp1);
//	//j = 0;
//	//fp1 = fopen(infile[2], "r");
//	//while (fgets(buff, MAXRNXLEN, fp1))
//	//{
//	//	for (i = 0; i < 40; i++) {
//	//		val[i] = str2num(buff, 20 * i, 17);
//	//	}
//	//	for (int n = 0; n < 40; n++) {
//	//		obs[j].L[2 * n + 1] = val[n];
//	//	}
//	//	j++;
//	//}
//	//fclose(fp1);
//	/* read ionosphere data file */
//  // strcpy(filopt.iono, infile[13]);
//	if (*filopt.iono && (ext = strrchr(filopt.iono, '.'))) {
//		if (strlen(ext) == 4 && (ext[3] == 'i' || ext[3] == 'I')) {
//			reppath(filopt.iono, path, ts, "", "");
//			readtec(path, &navs, 1);
//		}
//	}
//	/* read erp data */
//	//strcpy(filopt.eop, infile[10]);
//	if (*filopt.eop) {
//		free(navs.erp.data); navs.erp.data = NULL; navs.erp.n = navs.erp.nmax = 0;
//		reppath(filopt.eop, path, ts, "", "");
//		if (!readerp(path, &navs.erp)) {
//			showmsg("error : no erp data %s", path);
//			trace(2, "no erp data %s\n", path);
//		}
//	}
//	/* read rinex obs and nav file */
//	for (i = 0; i < 2; i++) {
//		if (readrnxt(infile[i], 1, ts, te, tint, &prcopt, &obss, &navs, &stas) < 0) {
//			staticcheckbrk("error : insufficient memory");
//			trace(1, "insufficient memory\n");
//			return 0;
//		}
//	}
//	//for (i = 4; i < 8; i++) {
//	//	if (readrnxt(infile[1], 1, ts, te, tint, &prcopt, &obss, &navs, &stas) < 0) {
//	//		staticcheckbrk("error : insufficient memory");
//	//		trace(1, "insufficient memory\n");
//	//		return 0;
//	//	}
//	//}
//	/* read precise ephemeris files */
//	readsp3(infile[2], &navs, 0);
//	/* read precise clock files */
////	readrnxc(infile[8], &navs);
//	/* read dcb parameters */
//	//strcpy(filopt.dcb, infile[14]);
//	if (*filopt.dcb) {
//		reppath(filopt.dcb, path, ts, "", "");
//		readdcb(path, &navs, stas);
//	}
//
//
//
//	/* read satellite antenna parameters */
//	//strcpy(filopt.satantp, infile[11]);
//	if (*filopt.satantp && !(readpcv(filopt.satantp, &pcvss))) {
//		showmsg("error : no sat ant pcv in %s", filopt.satantp);
//		trace(1, "sat antenna pcv read error: %s\n", filopt.satantp);
//		return 0;
//	}
//	/* read receiver antenna parameters */
////	strcpy(filopt.rcvantp, infile[11]);
//	if (*filopt.rcvantp && !(readpcv(filopt.rcvantp, &pcvsr))) {
//		showmsg("error : no rec ant pcv in %s", filopt.rcvantp);
//		trace(1, "rec antenna pcv read error: %s\n", filopt.rcvantp);
//		return 0;
//	}
//	/* set antenna paramters */
//	if (prcopt.mode != PMODE_SINGLE) {
//		staticsetpcv(obss.n > 0 ? obss.data[0].time : timeget(), &prcopt, &navs, &pcvss, &pcvsr,
//			stas);
//	}
//	/* read ocean tide loading parameters */
//	if (prcopt.mode > PMODE_SINGLE&&*filopt.blq) {
//		staticreadotl(&prcopt, filopt.blq, stas);
//	}
//	/* open solution statistics */
//	if (solopt.sstat > 0) {
//		strcpy(statfile, outfile);
//		strcat(statfile, ".stat");
//		rtkclosestat();
//		rtkopenstat(statfile, solopt.sstat);
//	}
//	/* write header to output file */
//	if (!outhead(outfile, infile, n, &prcopt, &solopt)) {
//		freeobsnav(&obss, &navs);
//		return 0;
//	}
//	iobsu = iobsr = isbs = revs = aborts = 0;
//	if (prcopt.mode == PMODE_SINGLE || prcopt.soltype == 0) {
//		if ((fp = openfile(outfile))) {
//			 /* forward */
//			int mode = 0;
//			gtime_t time = { 0 };
//			sol_t sol = { {0} };
//			rtk_t rtk;
//			obsd_t obs[MAXOBS * 2]; /* for rover and base */
//			double rb[3] = { 0 };
//			int i, nobs, n, solstatic, pri[] = { 6,1,2,3,4,5,1,6 };
//
//
//			solstatic = solopt.solstatic &&
//				(prcopt.mode == PMODE_STATIC || prcopt.mode == PMODE_PPP_STATIC);
//
//			rtkinit(&rtk, &prcopt);
//
//
//			trace(3, "infunc  : revs=%d iobsu=%d iobsr=%d isbs=%d\n", revs, iobsu, iobsr, isbs);
//
//			if (0 <= iobsu && iobsu < obss.n) {
//				settime((time = obss.data[iobsu].time));
//				if (staticcheckbrk("processing : %s Q=%d", time_str(time, 0), rtk.sol.stat)) {
//					aborts = 1; showmsg("aborted"); return -1;
//				}
//			}
//
//			
//			while ((nobs = inputobs(obs, rtk.sol.stat, &prcopt)) >= 0) {
//
//				/* exclude satellites */
//				for (i = n = 0; i < nobs; i++) {
//					if ((satsys(obs[i].sat, NULL)&prcopt.navsys) &&
//						prcopt.exsats[obs[i].sat - 1] != 1) obs[n++] = obs[i];
//				}
//				if (n <= 0) continue;
//
//				/* carrier-phase bias correction */
//				if (!strstr(prcopt.pppopt, "-ENA_FCB")) {
//					corr_phase_bias_ssr(obs, n, &navs);
//				}
//
//				if (!rtkpos(&rtk, obs, n, &navs)) continue;
//
//				if (mode == 0) { /* forward/backward */
//					if (!solstatic) {
//						outsol(fp, &rtk.sol, rtk.rb, &solopt);
//					}
//					else if (time.time == 0 || pri[rtk.sol.stat] <= pri[sol.stat]) {
//						sol = rtk.sol;
//						for (i = 0; i < 3; i++) rb[i] = rtk.rb[i];
//						if (time.time == 0 || timediff(rtk.sol.time, time) < 0.0) {
//							time = rtk.sol.time;
//						}
//					}
//
//				}
//				if (mode == 0 && solstatic&&time.time != 0.0) {
//					sol.time = time;
//					outsol(fp, &sol, rb, &solopt);
//				}
//			}
//				rtkfree(&rtk);
//			}
//			fclose(fp);
//		}
//	//
//	//sprintf(solopt.prog, "%s ver.%s %s", PROGNAME, VER_RTKLIB, PATCH_LEVEL);
//	//sprintf(filopt.trace, "%s.trace", PROGNAME);
//
//
//
//
//
//	//for (i = 1; i < argc; i++) {
//	//	if (!strcmp(argv[i], "-k") && i + 1 < argc) {
//
//	//	}
//	//}
//	//for (i = 1, n = 0; i < argc; i++) {
//	//	if (!strcmp(argv[i], "-o") && i + 1 < argc) outfile = argv[++i];
//	//	else if (!strcmp(argv[i], "-ts") && i + 2 < argc) {
//	//		sscanf(argv[++i], "%lf/%lf/%lf", es, es + 1, es + 2);
//	//		sscanf(argv[++i], "%lf:%lf:%lf", es + 3, es + 4, es + 5);
//	//		ts = epoch2time(es);
//	//	}
//	//	else if (!strcmp(argv[i], "-te") && i + 2 < argc) {
//	//		sscanf(argv[++i], "%lf/%lf/%lf", ee, ee + 1, ee + 2);
//	//		sscanf(argv[++i], "%lf:%lf:%lf", ee + 3, ee + 4, ee + 5);
//	//		te = epoch2time(ee);
//	//	}
//	//	else if (!strcmp(argv[i], "-ti") && i + 1 < argc) tint = atof(argv[++i]);
//	//	else if (!strcmp(argv[i], "-k") && i + 1 < argc) { ++i; continue; }
//	//	else if (!strcmp(argv[i], "-p") && i + 1 < argc) prcopt.mode = atoi(argv[++i]);
//	//	else if (!strcmp(argv[i], "-f") && i + 1 < argc) prcopt.nf = atoi(argv[++i]);
//	//	else if (!strcmp(argv[i], "-sys") && i + 1 < argc) {
//	//		for (p = argv[++i]; *p; p++) {
//	//			switch (*p) {
//	//			case 'G': prcopt.navsys |= SYS_GPS;
//	//			case 'R': prcopt.navsys |= SYS_GLO;
//	//			case 'E': prcopt.navsys |= SYS_GAL;
//	//			case 'J': prcopt.navsys |= SYS_QZS;
//	//			case 'C': prcopt.navsys |= SYS_CMP;
//	//			case 'I': prcopt.navsys |= SYS_IRN;
//	//			}
//	//			if (!(p = strchr(p, ','))) break;
//	//		}
//	//	}
//	//	else if (!strcmp(argv[i], "-m") && i + 1 < argc) prcopt.elmin = atof(argv[++i])*D2R;
//	//	else if (!strcmp(argv[i], "-v") && i + 1 < argc) prcopt.thresar[0] = atof(argv[++i]);
//	//	else if (!strcmp(argv[i], "-s") && i + 1 < argc) strcpy(solopt.sep, argv[++i]);
//	//	else if (!strcmp(argv[i], "-d") && i + 1 < argc) solopt.timeu = atoi(argv[++i]);
//	//	else if (!strcmp(argv[i], "-b")) prcopt.soltype = 1;
//	//	else if (!strcmp(argv[i], "-c")) prcopt.soltype = 2;
//	//	else if (!strcmp(argv[i], "-i")) prcopt.modear = 2;
//	//	else if (!strcmp(argv[i], "-h")) prcopt.modear = 3;
//	//	else if (!strcmp(argv[i], "-t")) solopt.timef = 1;
//	//	else if (!strcmp(argv[i], "-u")) solopt.times = TIMES_UTC;
//	//	else if (!strcmp(argv[i], "-e")) solopt.posf = SOLF_XYZ;
//	//	else if (!strcmp(argv[i], "-a")) solopt.posf = SOLF_ENU;
//	//	else if (!strcmp(argv[i], "-n")) solopt.posf = SOLF_NMEA;
//	//	else if (!strcmp(argv[i], "-g")) solopt.degf = 1;
//	//	else if (!strcmp(argv[i], "-r") && i + 3 < argc) {
//	//		prcopt.refpos = prcopt.rovpos = 0;
//	//		for (j = 0; j < 3; j++) prcopt.rb[j] = atof(argv[++i]);
//	//		matcpy(prcopt.ru, prcopt.rb, 3, 1);
//	//	}
//	//	else if (!strcmp(argv[i], "-l") && i + 3 < argc) {
//	//		prcopt.refpos = prcopt.rovpos = 0;
//	//		for (j = 0; j < 3; j++) pos[j] = atof(argv[++i]);
//	//		for (j = 0; j < 2; j++) pos[j] *= D2R;
//	//		pos2ecef(pos, prcopt.rb);
//	//		matcpy(prcopt.ru, prcopt.rb, 3, 1);
//	//	}
//	//	else if (!strcmp(argv[i], "-y") && i + 1 < argc) solopt.sstat = atoi(argv[++i]);
//	//	else if (!strcmp(argv[i], "-x") && i + 1 < argc) solopt.trace = atoi(argv[++i]);
//	//	else if (*argv[i] == '-') printhelp();
//	//	// else if (n<MAXFILE) infile[n++]=argv[i];
//	//}
//	//n = 7;
//
//
//	//if (!prcopt.navsys) {
//	//	prcopt.navsys = SYS_GPS | SYS_GLO;
//	//}
//	//if (n <= 0) {
//	//	showmsg("error : no input file");
//	//	return -2;
//	//}
//	//double t1[] = { 2019,1,10,0,10,0 }, t2[] = { 2019,1,10,3,30,0 };
//	////double ecf[] = { -2148744.8320,  4426641.7236,  4044656.2003 }, pos1[] = { 0 };
//	////ecef2pos(ecf, pos1);
//	////pos1[0] *= R2D;
//	////pos1[1] *= R2D;
//	//ts = epoch2time(t1);
//	//te = epoch2time(t2);
//	//prcopt.modear = 5;
//	//ret = postpos(ts, te, tint, 0.0, &prcopt, &solopt, &filopt, infile, n, outfile, "", "");
//
//	//if (!ret) fprintf(stderr, "%40s\r", "");
//	//return ret;
//}
