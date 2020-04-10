


import math


ofile = open('samples.vhd', 'w')


def main():
    smpl_width = 10
    smpl_depth = 8
    smpl_cycles = 2
    sin_smpls = get_sin_data(smpl_width, smpl_depth, smpl_cycles)

    for val in sin_smpls :
        ofile.write('std_logic_vector(to_unsigned(' + str(val) + ', ' + str(smpl_depth) + ')),\n')

def get_sin_data(N_exp, data_width, cycles):
    sin_samples = []
    data_cnt = 2**(N_exp)

    for i in range(0, data_cnt):
        sin_val = math.sin(2*math.pi*cycles*i/data_cnt)
        sin_val = round(sin_val * (2 ** (data_width - 1) - 1) + (2 ** (data_width - 1) - 1))
        sin_samples.append(sin_val)
    return sin_samples


main()