import socket
import matplotlib.pyplot as plt


#python github_repos/sf2_eth_fft/python/eth_py_server.py

#UDP_IP = '196.254.255.255'
#UDP_IP = '169.254.224.95'
UDP_IP = ''
UDP_PORT = 0xDA7A
serversocket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
serversocket.bind((UDP_IP, UDP_PORT))


limit = 0xff
cnt = 0


while True:
    er = 0
    print('hello, I\'m listening')
    try:
        data, addr = serversocket.recvfrom(1514)
    except:
        print('receive error')
        er = 1

    if(er == 0):
        print('========\n\tConnected by ', addr)
        if data and addr[0] == '100.100.100.200':
            print('\tdata bytes: ' + str(len(data)))
            plot_data = list(data)
            plt.plot(plot_data)
            plt.show()
        print('========')
