new_devices = ["NEW"]
connection_success = ["Connection successful"]
connected = ["Connected: yes"]
disconnect_success = ["Successful disconnected"]
request_pair = ["Request passkey"]
pair_successful = ["Pairing successful"]
device_paired = ["Paired: yes"]
remove_device = ["Device has been removed"]
read_value = ["\x1b[K  "]
write_value = []


def get_new_device_filter():
    return new_devices


def get_connection_success_filter():
    return connection_success


def get_connected_filter():
    return connected


def get_disconnect_success_filter():
    return disconnect_success


def get_device_paired_filter():
    return device_paired


def get_request_pair_filter():
    return request_pair


def get_pair_successful_filter():
    return pair_successful


def get_remove_device_filter():
    return remove_device


def get_read_value_filter():
    return read_value


def get_write_value_filter():
    return write_value
