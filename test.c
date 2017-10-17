/* See LICENSE file for copyright and license details. */
#include <sys/prctl.h>

int
main(void)
{
	int val = 0;
	return prctl(PR_GET_PDEATHSIG, &val) || !val;
}
