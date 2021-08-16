from Backend import set_backend, get_backend_exec, start_backend, force_backend, start_listening, stop_listening, stop_interactive, send_expect
import shlex
import os
import time
from datetime import datetime

verbose = False

backend = None
process = None
listener = None


def init():
    try:
        init_backend = set_backend()
        if init_backend == True:
            global process, backend
            backend = get_backend_exec()
            process = start_backend()
            if process != None:
                global listener
                listener = start_listening(process, True)

                global start_scan, stop_scan, connect_device, device_connected, disconnect_device, pair_device, device_paired, unpair_device, read, write, quit_interactive
                global get_connected_filter, get_connection_success_filter, get_disconnect_success_filter, get_new_device_filter, get_pair_successful_filter, get_read_value_filter, get_write_value_filter, get_remove_device_filter, get_device_paired_filter

                from Backend.bluetoothctl import start_scan
                from Backend.bluetoothctl import stop_scan
                from Backend.bluetoothctl import pair_device
                from Backend.bluetoothctl import connect_device
                from Backend.bluetoothctl import get_connection_success_filter
                from Backend.bluetoothctl import get_new_device_filter
                from Backend.bluetoothctl import get_pair_successful_filter
                from Backend.bluetoothctl import device_connected
                from Backend.bluetoothctl import get_connected_filter
                from Backend.bluetoothctl import device_paired
                from Backend.bluetoothctl import get_remove_device_filter
                from Backend.bluetoothctl import unpair_device
                from Backend.bluetoothctl import get_device_paired_filter

                if backend == "gatttool":
                    from Backend.gatttool import connect_device
                    from Backend.gatttool import disconnect_device
                    from Backend.gatttool import read
                    from Backend.gatttool import write
                    from Backend.gatttool import get_connection_success_filter
                    from Backend.gatttool import get_disconnect_success_filter
                    from Backend.gatttool import get_read_value_filter
                    from Backend.gatttool import get_write_value_filter
                    from Backend.gatttool import quit_interactive
                else:
                    from Backend.bluetoothctl import disconnect_device
                    from Backend.bluetoothctl import read
                    from Backend.bluetoothctl import write
                    from Backend.bluetoothctl import get_disconnect_success_filter
                    from Backend.bluetoothctl import get_read_value_filter
                    from Backend.bluetoothctl import quit_interactive

                return True
            else:
                return False
        else:
            print("Backend was not initialized")
            return False
    except Exception as e:
        print("Init Error:")
        print(e)
        return False


def getBackend():
    return backend


def scan():
    if process != None:
        print("Backend initialized")
        p = None
        if backend != "bluetoothctl":
            p = force_backend("bluetoothctl")

        time.sleep(1)
        l = start_listening(p, True)

        l.log_verbose(verbose)
        print("Listening...")
        send_expect(l, get_new_device_filter())
        l.send_input(None, start_scan(), 0)
        time.sleep(5)
        l.send_input(None, stop_scan(), 0)
        l.send_input(None, quit_interactive(), 0)

        stop_listening(l)
        stop_interactive(p)

        return l.get_output()

    else:
        print("Backend not initialized")


def connect(mac):
    if process != None:
        if listener != None:
            if(is_connected(mac) == False):
                listener.log_verbose(verbose)
                scan()
                send_expect(listener, get_connection_success_filter())
                listener.send_input(connect_device, mac, 0)

                time.sleep(2)

                if len(listener.get_output()) > 0:
                    return True
                else:
                    return False
            else:
                return True


def is_connected(mac):
    if process != None:
        p = None
        if backend != "bluetoothctl":
            p = force_backend("bluetoothctl")
        else:
            p = process

        time.sleep(1)
        l = start_listening(p, True)
        l.log_verbose(False)
        send_expect(l, get_connected_filter())
        l.send_input(device_connected, mac, 0)

        time.sleep(1)

        l.send_input(None, quit_interactive(), 0)

        stop_listening(l)
        stop_interactive(p)

        out = l.get_output()

        print(out)

        if len(out) > 0:
            return True
        else:
            return False


def disconnect(mac):
    if process != None:
        if listener != None:
            listener.log_verbose(verbose)
            send_expect(listener, get_disconnect_success_filter())
            listener.send_input(disconnect_device, mac, 0)

            time.sleep(3)

            if len(listener.get_output()) > 0:
                return True
            else:
                return False


def pair(mac):
    if process != None:
        if is_paired(mac) is not True:
            p = None
            if backend != "bluetoothctl":
                p = force_backend("bluetoothctl")
            else:
                p = process

            time.sleep(1)
            l = start_listening(p, True)
            l.log_verbose(verbose)
            send_expect(l, get_pair_successful_filter())
            l.send_input(pair_device, mac, 0)
            time.sleep(3)
            l.send_input(disconnect_device, mac, 0)
            time.sleep(1)
            l.send_input(None, quit_interactive(), 0)

            stop_listening(l)
            stop_interactive(p)

            if len(l.get_output()) > 0:
                return True
            else:
                return False
        else:
            return True


def is_paired(mac):
    if process != None:
        p = None
        if backend != "bluetoothctl":
            p = force_backend("bluetoothctl")
        else:
            p = process

        time.sleep(1)
        l = start_listening(p, True)
        l.log_verbose(verbose)
        send_expect(l, get_device_paired_filter())
        l.send_input(device_paired, mac, 0)
        time.sleep(1)
        l.send_input(None, quit_interactive(), 0)

        stop_listening(l)
        stop_interactive(p)

        if len(l.get_output()) > 0:
            return True
        else:
            return False


def unpair(mac):
    if process != None:
        if is_paired(mac) is True:
            p = None
            if backend != "bluetoothctl":
                p = force_backend("bluetoothctl")
            else:
                p = process

            time.sleep(2)
            l = start_listening(p, True)
            l.log_verbose(verbose)
            send_expect(l, get_remove_device_filter())
            l.send_input(unpair_device, mac, 0)
            time.sleep(1)
            l.send_input(None, quit_interactive(), 0)

            stop_listening(l)
            stop_interactive(p)

            if len(l.get_output()) > 0:
                return True
            else:
                return False
        else:
            return True


def write_value_uuid(uuid, value):
    if process != None:
        if backend == "bluetoothctl":
            if listener != None:
                listener.log_verbose(verbose)
                send_expect(listener, [])
                listener.send_input(write, [uuid, value], 0)

                time.sleep(3)


def write_handle(handle, value):
    if process != None:
        if backend == "gatttool":
            if listener != None:
                listener.log_verbose(verbose)
                send_expect(listener, get_write_value_filter())
                listener.send_input(write, [handle, value], 0)

                time.sleep(3)


def read_value(uuid):
    if process != None:
        if listener != None:
            send_expect(listener, get_read_value_filter())
            listener.log_verbose(True)
            listener.send_input(read, uuid, 0)

            time.sleep(3)

            output = listener.get_output()

            if len(output) > 0:
                return output
            else:
                return None


def format_input(input):
    retVal = ''

    if len(input) > 1:
        for val in input:
            if backend == 'gatttool':
                retVal += '' + val
            elif backend == 'bluetoothctl':
                retVal += '0x' + val + ' '

    return retVal
