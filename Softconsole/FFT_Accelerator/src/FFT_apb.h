

#include <stdlib.h>


#include "../firmware/hal/CortexM3/GNU/cpu_types.h"

#define BIT0        0x01u
#define BIT1        0x02u
#define BIT2        0x04u
#define BIT3        0x08u
#define BIT4        0x10u
#define BIT5        0x20u
#define BIT6        0x40u
#define BIT7        0x80u


#define FFT_CTRL_ADDR           0x00 //0 << 2
#define FFT_STAT_ADDR           0x04 //1 << 2
#define FFT_DIN_R_ADDR          0x08 //2 << 2
#define FFT_DIN_I_ADDR          0x0C //3 << 2
#define FFT_DOUT_R_ADDR         0x10 //4 << 2
#define FFT_DOUT_I_ADDR         0x14 //5 << 2
#define ABS_VAL_ADDR            0x18 //6 << 2
#define FFT_DOUT_ADR_ADDR       0x1C //7 << 2


#define CTRL_WRITE_EN           BIT0
#define CTRL_LOAD_DONE          BIT1
#define CTRL_READ_DONE          BIT2

#define STAT_W_READY            BIT0
#define STAT_W_FULL             BIT1
#define STAT_R_READY            BIT2
#define STAT_R_VALID            BIT3
#define STAT_ABS_VALID          BIT4


typedef struct fft_instance
{
    addr_t address;
} fft_instance_t;



void fft_init
(
    fft_instance_t * fft_inst,
    addr_t base_addr
);

uint8_t fft_get_status
(
    fft_instance_t * fft_inst
);

void fft_load_smpl
(
    fft_instance_t * fft_inst,
    uint16_t real,
    uint16_t imag
);

uint8_t fft_get_ctrl
(
    fft_instance_t * fft_inst
);

void fft_load_done
(
    fft_instance_t * fft_inst
);

void fft_read_done
(
    fft_instance_t * fft_inst
);

void fft_set_output_smpl
(
    fft_instance_t * fft_inst,
    uint16_t smpl_addr
);

int16_t fft_get_real_out
(
    fft_instance_t * fft_inst
);

int16_t fft_get_imag_out
(
    fft_instance_t * fft_inst
);

uint16_t fft_get_abs_val_out
(
    fft_instance_t * fft_inst
);

/*
int fft_read_smpl
(
    fft_instance_t * fft_inst,
    uint16_t smpl_addr,
    uint16_t * real,
    uint16_t * imag,
    uint16_t * abs_val
);
*/
