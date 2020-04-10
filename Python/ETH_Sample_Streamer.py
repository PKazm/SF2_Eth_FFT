import socket
import os
import math
import datetime
import matplotlib.pyplot as plt



log_file = open('python_eth_log.txt', 'w')
print(os.path.realpath(log_file.name))



def main():

    try:
        thing_do = int(input('what do?\n0 = end\n1 = send data\n2 = get data\n3 = det data fin\n4 = fft status: '))
    except:
        print('invalid input, closing')
        thing_do = 0

    samples = get_sin_data(10, 9, 50)
    plt.plot(samples)
    plt.show()
    byte_data = build_UDP_frames(samples, 2)
    while(thing_do != 0):
        
        if(thing_do == 1):
            send_UDP_data(byte_data, 0xDEAD)
        elif(thing_do == 2):
            send_UDP(0, 0xBEEF)
        elif(thing_do == 3):
            send_UDP(0, 0xB00B)
        elif(thing_do == 4):
            send_UDP(0, 0xD00F)
            

        try:
            thing_do = int(input('now what?: '))
        except:
            print('invalid input, closing')
            thing_do = 0
    


def send_UDP_data(data_to_send, port):
    for i in data_to_send:
        MESSAGE = bytes(i)
        send_UDP(MESSAGE, port)

def send_UDP(data_to_send, port):
    
    # embedded device found with
    # cmd prompt > arp -a
    # hard coded into main.c

    UDP_IP = "169.254.255.255"
    UDP_PORT = port
    MESSAGE = bytes(data_to_send)

    log_file.write('opening socket: ' + UDP_IP + ' : ' + str(UDP_PORT) + '\n')

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.sendto(MESSAGE, (UDP_IP, UDP_PORT))


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

    for i in range(0, data_cnt):
        sin_val = math.sin(2*math.pi*cycles*i/data_cnt)# * .5 + math.sin(2*math.pi*cycles*2*i/data_cnt) * .5
        #sin_val = round(sin_val * (2 ** (data_width - 1) - 1) + (2 ** (data_width - 1) - 1))       # unsigned
        sin_val = round(sin_val * (2 ** (data_width - 1) - 1))                                      # signed
        log_file.write('sin_val of ' + str(i) + ': ' + hex(sin_val) + ' = ' + str(sin_val) + '\n')
        sin_samples.append(sin_val)

    log_file.write('min: ' + str(min(sin_samples)) + ', max: ' + str(max(sin_samples)) + '\n')
    log_file.write('get_sin_data finished\n')
    log_file.write('=========================================\n')
    return sin_samples


main()
log_file.close()