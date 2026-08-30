#include <kernel.h>

#ifdef CONFIG_NET_WIZNET
#include <kdata.h>
#include <netdev.h>
#include <net_w5x00.h>
#include "wiznet_spi.h"

/*
 * W5500 socket bank mapping
 *
 * These macros match the definitions used by net_w5x00.c.
 * The W5500 uses bank information in the SPI control byte
 * rather than a flat address space.
 *
 * Duplicated here because the definitions in net_w5x00.c
 * are local to that compilation unit.
 */
#define _SLOT(x)        ((x) << 2)
#define SOCK2BANK_C(x)  ((_SLOT(x) | 1) << 3)
#define SOCK2BANK_W(x)  ((_SLOT(x) | 2) << 3)
#define SOCK2BANK_R(x)  ((_SLOT(x) | 3) << 3)

/*
 * ------------------------------------------------------------
 * W5500 register access (protocol layer)
 * NO hardware details here
 * ------------------------------------------------------------
 */

void w5x00_setup(void)
{
    wiz_spi_init();
}

static void w5x00_header(uint16_t off, uint16_t bank, uint8_t write)
{
    wiz_spi_xfer(off >> 8);
    wiz_spi_xfer(off & 0xFF);
    wiz_spi_xfer(bank | (write ? 0x04 : 0x00));
}

/*
 * Single byte register read
 */
uint8_t w5x00_readcb(uint16_t off)
{
    uint8_t r;
    wiz_spi_select();
    w5x00_header(off, 0, 0);
    r = wiz_spi_xfer(0xFF);
    wiz_spi_deselect();
    return r;
}

/*
 * Single byte register write
 */
void w5x00_writecb(uint16_t off, uint8_t val)
{
    wiz_spi_select();
    w5x00_header(off, 0, 1);
    wiz_spi_xfer(val);
    wiz_spi_deselect();
}

/*
 * Socket byte read
 */
uint8_t w5x00_readsb(uint8_t sock, uint16_t off)
{
    uint8_t r;

    wiz_spi_select();
    w5x00_header(off, SOCK2BANK_C(sock), 0);
    r = wiz_spi_xfer(0xFF);
    wiz_spi_deselect();

    return r;
}

/*
 * Socket byte write
 */
void w5x00_writesb(uint8_t sock, uint16_t off, uint8_t val)
{
    wiz_spi_select();
    w5x00_header(off, SOCK2BANK_C(sock), 1);
    wiz_spi_xfer(val);
    wiz_spi_deselect();
}

/*
 * Socket word read
 */

uint16_t w5x00_readsw(uint8_t sock, uint16_t off)
{
    uint16_t hi = w5x00_readsb(sock, off);
    uint16_t lo = w5x00_readsb(sock, off + 1);

    return (hi << 8) | lo;
}

/*
 * Block write
 */
void w5x00_bwrite(uint16_t bank, uint16_t off, void *p, uint16_t n)
{
    uint8_t *b = (uint8_t *)p;

    wiz_spi_select();
    w5x00_header(off, bank, 1);

    while (n--)
        wiz_spi_xfer(*b++);

    wiz_spi_deselect();
}

/*
 * Write socket word
 */
void w5x00_writesw(uint8_t sock, uint16_t off, uint16_t val)
{
    w5x00_writesb(sock, off, val >> 8);
    w5x00_writesb(sock, off + 1, val & 0xFF);
}

/*
 * Read block
 */
void w5x00_bread(uint16_t bank, uint16_t off, void *p, uint16_t n)
{
    uint8_t *b = (uint8_t *)p;

    wiz_spi_select();
    w5x00_header(off, bank, 0);

    while (n--)
        *b++ = wiz_spi_xfer(0xFF);

    wiz_spi_deselect();
}


/*
 * User-space read
 *
 * RP2040 has no MMU separation so treat this
 * same as normal reads for now.
 */
void w5x00_breadu(uint16_t bank, uint16_t off,
                  void *p, uint16_t n)
{
    w5x00_bread(bank, off, p, n);
}


/*
 * User-space write
 *
 * RP2040 has no MMU separation so treat this
 * same as normal writes for now.
 */
void w5x00_bwriteu(uint16_t bank, uint16_t off, void *p, uint16_t n)
{
    w5x00_bwrite(bank, off, p, n);
}

#endif
