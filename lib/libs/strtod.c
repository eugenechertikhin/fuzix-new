#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include <errno.h>

/*
 *	Sign
 */

const char *get_sign(register const char *p, unsigned *sign)
{
	*sign = 0;	/* +ve */
	if (*p == '+')
		return p + 1;
	if (*p != '-')
		return p;
	*sign = 1;
	return p + 1;
}

/*
 *	Signed hex value
 */

double hexnumber(const char **ptr, unsigned *err)
{
	register const char *p = *ptr;
	unsigned sign;
	unsigned prev = 0;
	double sum = 0;
	uint_fast8_t c;

	p = get_sign(p, &sign);
	if (!isdigit(*p))
		*err = 1;
	while(isxdigit(c = *p)) {
		sum *= 16;
		if (c >= '0' && c <= '9')
			sum += *p - '0';
		else if (c >= 'A' && c <= 'F')
			sum += *p - 'A' + 10;
		else if (c >= 'a' && c <= 'f')
			sum += *p - 'a' + 10;
		p++;
	}
	*ptr = p;
	/* Much faster than a multiply in most processors */
	if (sign)
		return -sum;
	return sum;
}

signed inumber(const char **ptr, unsigned *err)
{
	register const char *p = *ptr;
	unsigned sign;
	unsigned sum = 0;

	p = get_sign(p, &sign);
	if (!isdigit(*p))
		*err = 1;
	while(isdigit(*p)) {
		sum *= 10;
		sum += *p - '0';
		/* Exponent range is way below this in all cases */
		if (sum > 255)
			*err = 1;
		p++;
	}
	*ptr = p;
	/* Much faster than a multiply in most processors */
	if (sign)
		return -sum;
	return sum;
}

static double number(const char **ptr)
{
	register const char *p = *ptr;
	double working = 0.0;
	double scale = 10;

	while(isdigit(*p)) {
		working *= 10.0;
		working += *p - '0';
		p++;
	}
	*ptr = p;
	return working;
}

static double fraction(const char **ptr)
{
	register const char *p = *ptr;
	double working = 0.0;
	double scale = 0.1;

	while(isdigit(*p)) {
		working += (*p - '0') * scale;
		scale *= 0.1;
		p++;
	}
	*ptr = p;
	return working;
}

double __strtod(const char *nptr, char **endptr, unsigned *err)
{
	double working;
	unsigned sign;
	signed exponent = 0;
	unsigned scale = 10.0;

	/* An initial possibly empty sequence of white-space characters */
	while(isspace(*nptr))
		nptr++;
	/* An optional sign */
	nptr = get_sign(nptr, &sign);

	/* One of:  NAN followed by an n-char-sequence */
	if (*nptr == 'N' || *nptr == 'n') {
		/* NaN check */
		if (strncasecmp(nptr, "NAN", 3) == 0) {
			working = 0.0/0.0;
			nptr += 3;
			while(isalnum(*nptr))
				nptr++;
			goto out;
		}
	}
	/* INF or INFINITY (again case independent) */
	if (*nptr == 'I' || *nptr == 'i') {
		/* INFinity check */
		if (strncasecmp(nptr, "INF", 3) == 0) {
			working = 1.0/0.0;
			nptr += 3;
			if (strncasecmp(nptr, "INITY", 5) == 0)
				nptr += 5;
			goto out;
		}
	}
	/* Now check for digits */
	if (!isdigit(*nptr)) {
		*err = 1;
		return 0.0;
	}
	/* TODO: do we also need to allow octal integer in this case ? */
	if (*nptr == '0' && (nptr[1] == 'x' || nptr[1] == 'X')) {
		nptr += 2;
		working = hexnumber(&nptr, err);
		if (*nptr == 'P' || *nptr == 'p') {
			nptr++;
			exponent = inumber(&nptr, err);
			scale = 2.0;
		} else
			*err = 1;
	} else {
		/* Standard form */
		working = number(&nptr);
		if (*nptr == '.') {
			nptr++;
			working += fraction(&nptr);
		}
		/* Now worry about exponents */
		if (*nptr == 'E' || *nptr == 'e') {
			nptr++;
			exponent = inumber(&nptr, err);
		}
	}
	if (sign)
		working = -working;
	/* Normalise it all. Once our base FP routines do exceptions
	   and overflows then all will work as expected on errors */
	while(exponent < 0) {
		working /= scale;
		exponent++;
	}
	while(exponent > 0) {
		working *= scale;
		exponent--;
	}
out:
	if (endptr)
		*endptr = (char *)nptr;
	return working;
}

double strtod(const char *nptr, char **endptr)
{
	unsigned err = 0;
	double r = __strtod(nptr, endptr, &err);
	if (err)
		errno = ERANGE;
	return r;
}

/* Yes atof returns doubles, the C standard was apparently drunk that
   afternoon */

double atof(const char *nptr)
{
	unsigned err;
	return __strtod(nptr, NULL, &err);
}

#ifdef TEST

#include <stdio.h>

int main(int argc, char *argv[])
{
	char buf[256];
	double d;

	while(fgets(buf, 255, stdin)) {
		errno = 0;
		d = strtod(buf, NULL);
		if (errno)
			printf("!");
		printf("%16.16e\n", d);
	}
	return 0;
}
#endif
