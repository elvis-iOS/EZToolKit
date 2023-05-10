//
//  libproc.h
//  Pods
//
//  Created by Elvis on 2021/12/3.
//

#ifndef libproc_h
#define libproc_h

#define PROC_ALL_PIDS       1
#define PROC_PIDTBSDINFO    3

struct proc_bsdinfo {
    uint32_t        pbi_flags;        /* 64bit; emulated etc */
    uint32_t        pbi_status;
    uint32_t        pbi_xstatus;
    uint32_t        pbi_pid;
    uint32_t        pbi_ppid;
    uid_t            pbi_uid;
    gid_t            pbi_gid;
    uid_t            pbi_ruid;
    gid_t            pbi_rgid;
    uid_t            pbi_svuid;
    gid_t            pbi_svgid;
    char            pbi_comm[MAXCOMLEN + 1];
    char            pbi_name[2*MAXCOMLEN + 1];    /* empty if no name is registered */
    uint32_t        pbi_nfiles;
    uint32_t        pbi_pgid;
    uint32_t        pbi_pjobc;
    uint32_t        e_tdev;            /* controlling tty dev */
    uint32_t        e_tpgid;        /* tty process group id */
    struct timeval         pbi_start;
    int32_t            pbi_nice;
};
extern int proc_listpids(uint32_t type, uint32_t typeinfo, void *buffer, int buffersize);
extern int proc_pidinfo(int pid, int flavor, uint64_t arg,  void *buffer, int buffersize);
extern int proc_name(int pid, void * buffer, uint32_t buffersize);

#endif /* libproc_h */
