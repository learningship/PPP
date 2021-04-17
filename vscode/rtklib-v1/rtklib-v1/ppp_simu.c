//#include "rtklib.h"
//
///* show message --------------------------------------------------------------*/
//extern int showmsg(const char *format, ...)
//{
//    va_list arg;
//    va_start(arg,format); vfprintf(stderr,format,arg); va_end(arg);
//    fprintf(stderr,"\r");
//    return 0;
//}
//extern void settspan(gtime_t ts, gtime_t te) {}
//extern void settime(gtime_t time) {}
//
//static int nextobsf(const obs_t* obs, int* i)
//{
//    double tt;
//    int n;
//
//    for (n = 0; *i + n < obs->n; n++)
//    {
//        tt = timediff(obs->data[*i + n].time, obs->data[*i].time);
//        if (tt > DTTOL)
//            break;
//    }
//    return n;
//}
//
//int main(int argc, char** argv)
//{
//    gtime_t t0 = { 0 }, ts = { 0 }, te = { 0 };
//
//    char file1[] = "D:\\vscode\\rtklib-v1\\rtklib-v1\\new data\\igs20354.sp3";
//    char file2[] = "D:\\vscode\\rtklib-v1\\rtklib-v1\\new data\\igs20354.clk";
//    char file4[] = "D:\\vscode\\rtklib-v1\\rtklib-v1\\new data\\bjfs0100.19o";
//    char file3[] = "D:\\vscode\\rtklib-v1\\rtklib-v1\\new data\\bjfs0100.19n";
//    //char file3[] = "bjfs0100.19n";
//
//
//    //char file1[] = "igs20425.sp3";
//    //char file2[] = "igs20425.clk";
//    //char file3[] = "mas10600.19n";
//    //char file4[] = "mas10600.19o";
//    //char file5[] = "igs14.atx";
//
//    FILE* fp;
//    fp = fopen("bjtest01.txt", "w+");
//    int ret;
//    obs_t obs = { 0 };
//    nav_t nav = { 0 };
//    sta_t sta = { "" };
//
//
//
//    double refpos[3];
//
//    readsp3(file1, &nav, 0);//
//    readrnxc(file2, &nav);
//
//    //1 -> rover
//    ret = readrnxt(file3, 1, ts, te, 0.0, "", &obs, &nav, &sta);
//    ret = readrnxt(file4, 1, t0, t0, 0.0, "", &obs, &nav, &sta);
//
//
//
//    printf("refpos  = %.9f %.9f %.9f\n", sta.pos[0], sta.pos[1], sta.pos[2]);
//    ecef2pos(sta.pos, refpos);
//    printf("refpos     = %.9f %.9f %.9f\n", refpos[0], refpos[1], refpos[2]);
//    printf("refpos R2D     = %.9f %.9f %.9f\n", refpos[0] * R2D, refpos[1] * R2D, refpos[2]);
//
//    traceopen("ppp.trace");
//    tracelevel(3);
//
//    prcopt_t prcopt = prcopt_default;
//    solopt_t solopt = solopt_default;
//
//
//    prcopt.mode = PMODE_PPP_STATIC;
//    prcopt.navsys = SYS_GPS;
//    prcopt.sateph = EPHOPT_BRDC;
//    prcopt.ionoopt = IONOOPT_OFF;
//    prcopt.tropopt = TROPOPT_OFF;
//    prcopt.soltype = 0;
//    prcopt.refpos = 1;
//    prcopt.glomodear = 0;
//    solopt.timef = 0;
//    solopt.posf = SOLF_LLH;
//    sprintf(solopt.prog, "ver.%s", VER_RTKLIB);
//    printf("%d %d %d\n", prcopt.syncsol, solopt.solstatic, prcopt.posopt[2]);
//
//    rtk_t rtk;
//    rtkinit(&rtk, &prcopt);
//
//    double pos[3];
//    int m = 0;
//    for (int i = 0; (m = nextobsf(&obs, &i)) > 0; i += m)
//    {
//        rtk.sol.time = obs.data[i].time;
//        rtkpos(&rtk, &obs.data[i], m, &nav);
//
//        sol_t* sol = &rtk.sol;
//
//        //pppoutsolstat(&rtk.sol, 1, fp);
//
//        outsol(fp, &rtk.sol, rtk.rb, &solopt);
//
//        // printf("sat: %d, rcv: %d\n", obs.data[i].sat, obs.data[i].rcv);
//        if (sol->stat == SOLQ_PPP)
//        {
//            printf("%d/%d, pos: %lf,%lf,%lf\n", i, obs.n, sol->rr[0], sol->rr[1], sol->rr[2]);
//            // fprintf(fp, "%lf,%lf,%lf\n", sol->rr[0], sol->rr[1], sol->rr[2]);//使用fprintf  将输出端口变更为 文档
//             //for (int ii = 0; ii < 3; ii++) {
//             //    pos[ii] = sol->rr[ii];
//             //}
//            ecef2pos(sol->rr, pos);
//            printf("pos: %lf,%lf,%lf\n", pos[0], pos[1], pos[2]);
//            printf("posR2D: %lf,%lf,%lf\n", pos[0] * R2D, pos[1] * R2D, pos[2]);
//            // printf("sat: %d, rcv: %d\n", obs.data[i].sat, obs.data[i].rcv);
//             //printf("qr: %lf,%lf,%lf,%lf,%lf,%lf\n", sol->qr[0], sol->qr[1], sol->qr[2], sol->qr[3], sol->qr[4], sol->qr[5]);
//        }
//        else
//        {
//            printf("(%d,%d)/%d, type: %d\n", i, m, obs.n, sol->type);
//            printf("msg: %s\n\n", rtk.errbuf);
//        }
//    }
//    // fclose(fp);
//    fclose(fp);
//    traceclose();
//    rtkfree(&rtk);
//    return 0;
//}