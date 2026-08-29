#ifndef _SDXFER_H
#define _SDXFER_H
extern int nz80_sd_xfer(uint_fast8_t dev, bool is_read, uint32_t lba, uint8_t *dptr);
#endif
