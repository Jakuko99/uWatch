backend = 'bluetoothctl'
enable_gatt_commands = 'menu gatt'
quit_gatt = 'back'
quit_backend = 'quit'
use_attribute = "select-attribute"
read_attribute = 'read'
write_attribute = 'write'
scan_start = 'scan on'
scan_stop = 'scan off'
paired_device = 'info'
paired_devices = 'paired-devices'
connect = 'connect'
connected = 'info'
disconnect = 'disconnect'
pair = 'pair'
remove = 'remove'
agent = 'agent KeyboardOnly'


def get_backend():
    return [backend]


def set_agent():
    return [agent]


def pair_device(mac):
    return [pair + " " + mac]


def device_paired(mac):
    return [paired_device + " " + mac]


def get_paired_devices():
    return paired_devices


def unpair_device(mac):
    return [remove + " " + mac]


def connect_device(mac):
    return [connect + " " + mac]


def device_connected(mac):
    return [connected + " " + mac]


def disconnect_device(mac):
    return [disconnect + " " + mac]


def read(uuid):
    return [enable_gatt_commands + "\n"] + [use_attribute + " " + uuid + "\n"] + [read_attribute + "\n"] + [quit_gatt + "\n"]


def write(dataset):
    return [enable_gatt_commands + "\n"] + [use_attribute + " " + dataset[0] + "\n"] + [write_attribute + ' "' + dataset[1] + '"' + "\n"] + [quit_gatt + "\n"]


def start_scan():
    return [scan_start]


def stop_scan():
    return [scan_stop]


def quit_interactive():
    return [quit_backend]
