import socket
import os
import math
import datetime
import matplotlib.pyplot as plt
import numpy as np


log_file = open('python_eth_log.txt', 'w')
print(os.path.realpath(log_file.name))



def main():

    print('Things to do:')
    print('0 = exit')
    print('1 = send data')
    print('2 = get fft data')
    print('3 = set data read finished')
    print('4 = get fft status')
    print('5 = plot input samples')
    print('6 = get ethernet status')
    print('7 = send data forever (throughput test)')
    print('9 = dump MAC and PHY registers')

    try:
        thing_do = int(input('what do?: '))
    except:
        print('invalid input, closing')
        thing_do = 0

    samples = get_sin_data(10, 9, 100)
    plt.plot(samples)
    byte_data = build_UDP_frames(samples, 2)
    while(thing_do != 0):
        
        if(thing_do == 1):
            send_UDP_data(byte_data, 0xDA7A)
        elif(thing_do == 2):
            send_UDP([0,0,0,1], 0xC0DE)     # return data
        elif(thing_do == 3):
            send_UDP([0,0,0,2], 0xC0DE)     # set data read finished
        elif(thing_do == 4):
            send_UDP([0,0,0,3], 0xC0DE)     # get fft status
        elif(thing_do == 5):
            plt.show()
        elif(thing_do == 6):
            send_UDP([0,0,0,4], 0xC0DE)     # get eth status
        elif(thing_do == 7):
            big_data = bytearray([0xD0]*(1472*20))
            big_data_cycles = 10000
            while(big_data_cycles != 0):
                big_data_cycles -= 1
                send_UDP(big_data, 0xDA7A)
        elif(thing_do == 9):
            send_UDP([0,0,0,5], 0xC0DE)     # get MAC and PHY status
            

        try:
            thing_do = int(input('now what?: '))
        except:
            print('invalid input, closing')
            thing_do = 0
    


def send_UDP_data(data_to_send, port):
    for i in data_to_send:
        MESSAGE = i
        send_UDP(MESSAGE, port)

def send_UDP(data_to_send, port):
    
    # embedded device found with
    # cmd prompt > arp -a
    # hard coded into main.c

    UDP_IP = "100.100.100.200"
    UDP_PORT = port
    MESSAGE = bytes(data_to_send)

    log_file.write('opening socket: ' + UDP_IP + ' : ' + str(UDP_PORT) + '\n')

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.sendto(MESSAGE, (UDP_IP, UDP_PORT))
    sock.close()


def build_UDP_frames(data_list, bytes_per_item):
    data_cnt = len(data_list)
    items_per_frame = math.floor(1024 / bytes_per_item)
    data_list_pos = 0
    frame_list = []


    while(data_list_pos != data_cnt):
        frame_data = []
        for i in range(0, min(items_per_frame, data_cnt - data_list_pos)):
            temp_bytes = data_list[data_list_pos].to_bytes(bytes_per_item, 'big', signed=True)
            frame_data[len(frame_data):len(frame_data)] = (temp_bytes)
            data_list_pos += 1
        frame_list.append(frame_data)

    return frame_list
        


def get_sin_data(N_exp, data_width, cycles):
    log_file.write('=========================================\n')
    log_file.write(str(datetime.datetime.now().time()) + '\n')
    log_file.write('=========================================\n')
    log_file.write('get_sin_data: ' + str(N_exp) + ', ' + str(data_width) + ', ' + str(cycles) + '\n')
    sin_samples = []
    data_cnt = 2**(N_exp)

    
    sample2_amp = .5
    smpl2_per = 200
    sample3_amp = .5
    smpl3_per = 400
    noise_multi = .3
    noise = np.random.normal(0, noise_multi/3, data_cnt)
    carrier_amp = 3
    carrier_per = 75


    for i in range(0, data_cnt):
        sample2 = sample2_amp*math.sin(2*math.pi*smpl2_per*(i/data_cnt))
        sample3 = sample3_amp*math.sin(2*math.pi*smpl3_per*(i/data_cnt))
        sample1 = (carrier_amp - sample2_amp - sample3_amp - noise_multi)*math.sin(2*math.pi*carrier_per*i/data_cnt)

        signal_val = (sample1+sample2+sample3+noise[i])/carrier_amp
        #print(signal_val)

        #sin_val = math.sin(2*math.pi*cycles*i/data_cnt) * .5 + math.sin(2*math.pi*cycles*5*i/data_cnt) * .5
        #sin_val = round(sin_val * (2 ** (data_width - 1) - 1) + (2 ** (data_width - 1) - 1))       # unsigned
        #sin_val = round(sin_val * (2 ** (data_width - 1) - 1))                                      # signed
        signal_val = int(round(signal_val * (2 ** (data_width - 1) - 1)))                                      # signed
        log_file.write('signal_val of ' + str(i) + ': ' + hex(signal_val) + ' = ' + str(signal_val) + '\n')
        sin_samples.append(signal_val)

    log_file.write('min: ' + str(min(sin_samples)) + ', max: ' + str(max(sin_samples)) + '\n')
    log_file.write('get_sin_data finished\n')
    log_file.write('=========================================\n')
    return sin_samples


def startUDPserver():
    server = socketserver.UDPServer(('', 0xDA7A), MyUDPHandler)
    server.serve_forever()



main()
log_file.close()