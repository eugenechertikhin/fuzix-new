#include <hardware/spi.h>
#include <hardware/gpio.h>
#include "picosdk.h"
#include <net_w5x00.h>
#include <printf.h>

#define W5X00_SPI spi0

/* RP2040 Pico / W5500-EVB-Pico hard wired GPIO Pins */
#define W5X00_SCK 18
#define W5X00_TX  19
#define W5X00_RX  16
#define W5X00_CS  17
#define W5X00_INT 21

static spi_inst_t *wiz_spi = spi0;
volatile uint8_t wiz_irq_pending;

static void w5x00_gpio_irq(uint gpio, uint32_t events)
{
    (void)gpio;
    (void)events;
    wiz_irq_pending = 1;
}

void wiz_spi_init(void)
{
    gpio_init(W5X00_SCK);
    gpio_init(W5X00_TX);
    gpio_init(W5X00_RX);
    gpio_init(W5X00_CS);

    gpio_init(W5X00_INT);
    gpio_set_dir(W5X00_INT, GPIO_IN);
    gpio_pull_up(W5X00_INT);

    gpio_set_function(W5X00_SCK, GPIO_FUNC_SPI);
    gpio_set_function(W5X00_TX, GPIO_FUNC_SPI);
    gpio_set_function(W5X00_RX, GPIO_FUNC_SPI);

    gpio_set_dir(W5X00_CS, GPIO_OUT);
    gpio_put(W5X00_CS, 1);

    spi_init(W5X00_SPI, 1000000);
    spi_set_format( W5X00_SPI, 8, SPI_CPOL_0, SPI_CPHA_0, SPI_MSB_FIRST);

    gpio_set_irq_callback(w5x00_gpio_irq);
    gpio_set_irq_enabled(W5X00_INT, GPIO_IRQ_EDGE_FALL, true);
    irq_set_enabled(IO_IRQ_BANK0, true);
}

uint8_t wiz_spi_xfer(uint8_t v)
{
    uint8_t rx;
    spi_write_read_blocking(wiz_spi, &v, &rx, 1);
    return rx;
}

void wiz_spi_select(void)
{
    gpio_put(W5X00_CS, 0);
}

void wiz_spi_deselect(void)
{
    gpio_put(W5X00_CS, 1);
}
