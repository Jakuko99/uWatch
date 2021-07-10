connection_success = ["Connection successful"]
disconnect_success = ["Invalid file descriptor"]
read_value = ["value:"]
write_value = ["Characteristic value was written successfully"]
connected = ['\x1b[K']

def get_connection_success_filter():
    return connection_success

def get_disconnect_success_filter():
    return disconnect_success

def get_read_value_filter():
    return read_value

def get_write_value_filter():
    return write_value

def get_connected_filter():
    return connected

