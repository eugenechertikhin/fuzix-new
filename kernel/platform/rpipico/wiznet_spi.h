#ifndef WIZNET_SPI_H
#define WIZNET_SPI_H

#include <stdint.h>

extern volatile uint8_t wiz_irq_pending;

void wiz_spi_init(void);
uint8_t wiz_spi_xfer(uint8_t v);
void wiz_spi_select(void);
void wiz_spi_deselect(void);

#endif
