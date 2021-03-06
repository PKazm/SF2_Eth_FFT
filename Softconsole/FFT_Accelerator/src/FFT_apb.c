
#include "FFT_apb.h"
#include "../firmware/hal/hal.h"
#include "../firmware/hal/hal_assert.h"


void fft_init
(
    fft_instance_t * fft_inst,
    addr_t base_addr
)
{
    fft_inst->address = base_addr;
}

uint8_t fft_get_status(fft_instance_t * fft_inst)
{
    return HW_get_8bit_reg(fft_inst->address + FFT_STAT_ADDR);
}

void fft_load_smpl
(
    fft_instance_t * fft_inst,
    uint16_t real,
    uint16_t imag
)
{
    uint8_t ctrl_val;

    HW_set_16bit_reg(fft_inst->address + FFT_DIN_R_ADDR, real);
    HW_set_16bit_reg(fft_inst->address + FFT_DIN_I_ADDR, imag);

    ctrl_val = HW_get_8bit_reg(fft_inst->address + FFT_CTRL_ADDR);

    ctrl_val |= CTRL_WRITE_EN;
    HW_set_8bit_reg(fft_inst->address + FFT_CTRL_ADDR, ctrl_val);
}

void fft_set_DMA
(
    fft_instance_t * fft_inst,
    uint8_t val
)
{
    uint8_t ctrl_val;
    ctrl_val = HW_get_8bit_reg(fft_inst->address + FFT_CTRL_ADDR);

    if(val == 0){
        // use bus interface
        ctrl_val &= ~CTRL_DMA;
    }
    else
    {
        // use direct wire connections
        ctrl_val |= CTRL_DMA;
    }
    
    HW_set_8bit_reg(fft_inst->address + FFT_CTRL_ADDR, ctrl_val);
}


uint8_t fft_get_ctrl
(
    fft_instance_t * fft_inst
)
{
    return HW_get_8bit_reg(fft_inst->address + FFT_CTRL_ADDR);
}

void fft_load_done(fft_instance_t * fft_inst)
{
    uint8_t ctrl_val;

    ctrl_val = HW_get_8bit_reg(fft_inst->address + FFT_CTRL_ADDR);

    ctrl_val |= CTRL_LOAD_DONE;
    HW_set_8bit_reg(fft_inst->address + FFT_CTRL_ADDR, ctrl_val);
}

void fft_read_done(fft_instance_t * fft_inst)
{
    uint8_t ctrl_val;

    ctrl_val = HW_get_8bit_reg(fft_inst->address + FFT_CTRL_ADDR);

    ctrl_val |= CTRL_READ_DONE;
    HW_set_8bit_reg(fft_inst->address + FFT_CTRL_ADDR, ctrl_val);
}

void fft_int_clr(fft_instance_t * fft_inst)
{
    uint8_t ctrl_val;

    ctrl_val = HW_get_8bit_reg(fft_inst->address + FFT_CTRL_ADDR);

    ctrl_val |= CTRL_INT_CLR;
    HW_set_8bit_reg(fft_inst->address + FFT_CTRL_ADDR, ctrl_val);
}

void fft_set_output_smpl
(
    fft_instance_t * fft_inst,
    uint16_t smpl_addr
)
{
    HW_set_16bit_reg(fft_inst->address + FFT_DOUT_ADR_ADDR, smpl_addr);
}

int16_t fft_get_real_out
(
    fft_instance_t * fft_inst
)
{
    return (int16_t)HW_get_16bit_reg(fft_inst->address + FFT_DOUT_R_ADDR);
}

int16_t fft_get_imag_out
(
    fft_instance_t * fft_inst
)
{
    return (int16_t)HW_get_16bit_reg(fft_inst->address + FFT_DOUT_I_ADDR);
}

uint16_t fft_get_abs_val_out
(
    fft_instance_t * fft_inst
)
{
    return HW_get_16bit_reg(fft_inst->address + ABS_VAL_ADDR);
}

/*
int fft_read_smpl
(
    fft_instance_t * fft_inst,
    uint16_t smpl_addr,
    uint16_t * real,
    uint16_t * imag,
    uint16_t * abs_val
)
{
    HW_set_16bit_reg(fft_inst->address + FFT_DOUT_ADR_ADDR, smpl_addr);

    *real = HW_get_16bit_reg(fft_inst->address + FFT_DOUT_R_ADDR);
    *imag = HW_get_16bit_reg(fft_inst->address + FFT_DOUT_I_ADDR);
    *abs_val = HW_get_16bit_reg(fft_inst->address + ABS_VAL_ADDR);

    return 1;
}
*/