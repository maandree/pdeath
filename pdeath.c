/* See LICENSE file for copyright and license details. */
#include <sys/prctl.h>
#include <errno.h>
#include <limits.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <unistd.h>

struct sig {
	int signo;
	const char *name;
} sigs[] = {
	{SIGHUP,    "HUP"},
	{SIGINT,    "INT"},
	{SIGQUIT,   "QUIT"},
	{SIGILL,    "ILL"},
	{SIGTRAP,   "TRAP"},
	{SIGABRT,   "ABRT"},
	{SIGIOT,    "IOT"},
	{SIGBUS,    "BUS"},
	{SIGFPE,    "FPE"},
	{SIGKILL,   "KILL"},
	{SIGUSR1,   "USR1"},
	{SIGSEGV,   "SEGV"},
	{SIGUSR2,   "USR2"},
	{SIGPIPE,   "PIPE"},
	{SIGALRM,   "ALRM"},
	{SIGTERM,   "TERM"},
	{SIGSTKFLT, "TKFLT"},
	{SIGCLD,    "CLD"},
	{SIGCHLD,   "CHLD"},
	{SIGCONT,   "CONT"},
	{SIGSTOP,   "STOP"},
	{SIGTSTP,   "TSTP"},
	{SIGTTIN,   "TTIN"},
	{SIGTTOU,   "TTOU"},
	{SIGURG,    "URG"},
	{SIGXCPU,   "XCPU"},
	{SIGXFSZ,   "XFSZ"},
	{SIGVTALRM, "VTALRM"},
	{SIGPROF,   "PROF"},
	{SIGWINCH,  "WINCH"},
	{SIGPOLL,   "POLL"},
	{SIGIO,     "IO"},
	{SIGPWR,    "PWR"},
	{SIGSYS,    "SYS"},
	{0,         NULL}
};

const char *argv0;

static void
usage(void)
{
	fprintf(stderr, "usage: %s (-L | (signal)[(+|-)off] command [argument] ...)\n", argv0);
	exit(127);
}

static void
invalid_signal(void)
{
	fprintf(stderr, "%s: invalid signal\n", argv0);
	exit(127);
}

static void
print_signals(void)
{
	struct sig *sig = sigs;
	for (; sig->name; sig++)
		printf("%s\n", sig->name);
	printf("RTMIN\nRTMAX\n");
}

static int
strict_strtoi(const char *str, int min, int max)
{
	char *end;
	long int ret;
	errno = 0;
	ret = strtol(str, &end, 10);
	if (errno || *end)
		usage();
	if (ret < min || ret > max)
		invalid_signal();
	return (int)ret;
}

static int
get_signal(const char *str)
{
	struct sig *sig = sigs;
	int have_prefix = 0;
	char *end;
	long int ret;
	if (!strncasecmp(str, "SIG", 3)) {
		str += 3;
		have_prefix = 1;
	}
	if (!strcasecmp(str, "RTMIN"))
		return SIGRTMIN;
	if (!strcasecmp(str, "RTMAX"))
		return SIGRTMAX;
	for (; sig->name; sig++) {
		if (!strcasecmp(str, sig->name))
		  return sig->signo;
	}
	if (!have_prefix) {
		errno = 0;
		ret = strtol(str, &end, 10);
		if (!errno && !*end && 0 <= ret && ret < _NSIG)
			return (int)ret;

	}
	invalid_signal();
	return -1;
}

int
main(int argc, char *argv[])
{
	char *off;
	char sign = '\0';
	int signo;

	argv0 = *argv ? (argc--, *argv++) : "pdeath";

	if (*argv && **argv == '-') {
		if (argc == 1 && !strcmp(*argv, "-L")) {
			print_signals();
			if (fflush(stdout) || fclose(stdout)) {
				perror(argv0);
				return 127;
			}
			return 0;
		}
		usage();
	}

	if (argc < 2)
		usage();

	if ((off = strpbrk(*argv, "+-"))) {
		sign = *off;
		*off++ = '\0';
	}
	signo = get_signal(*argv);
	if (sign == '-')
		signo -= strict_strtoi(off, 0, signo);
	else if (sign == '+')
		signo += strict_strtoi(off, 0, _NSIG - 1 - signo);
	argv++, argc--;

	if (prctl(PR_SET_PDEATHSIG, signo) == -1) {
		perror(argv0);
		return 127;
	}

	execvp(*argv, argv);
	fprintf(stderr, "%s: %s: %s\n", argv0, strerror(errno), *argv);
	return 127;
}
