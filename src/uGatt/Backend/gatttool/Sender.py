backend = ['gatttool', '-t', 'random', '-l', 'high', '-I']
quit_backend = 'exit'
read_attribute = 'char-read-uuid'
write_attribute = 'char-write-req'
connect = 'connect'
disconnect = 'disconnect'
connected = 'help'

def get_backend():
    return backend

def connect_device(mac):
    return [connect + " " + mac + " random"]

def disconnect_device(mac):
    return [disconnect + " " + mac]

def read(uuid):
    return [read_attribute + " " + uuid]

def write(dataset):
    return [write_attribute + ' ' + dataset[0] + ' ' + dataset[1]]

def device_connected(mac):
    return [connected]

def quit_interactive():
    return [quit_backend]