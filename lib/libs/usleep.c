/* usleep.c
 */
#include <unistd.h>
#include <stdlib.h>
#include <signal.h>
#include <syscalls.h>

int usleep(useconds_t us)
{
	/* _pause() timeouts are in deciseconds. Round UP: rounding down
	   turns any period below 100ms into _pause(0), which means "pause
	   until a signal" - i.e. sleep forever. */
	if (us == 0)
		return 0;
	return _pause((us + 99999UL) / 100000UL);
}
