from Backend import set_backend, get_backend_exec, start_backend, force_backend, start_listening, stop_listening, stop_interactive, send_expect
import Backend.bluetoothctl as ctl
import Backend.gatttool as ttt
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
            global process, backend, listener
            backend = get_backend_exec()
            process = start_backend()
            if process != None:
                listener = start_listening(process, True)
                listener.log_verbose(verbose)
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


def connect(mac):
    if process != None:
        if listener != None:
            if(is_connected(mac) == False):
                listener.log_verbose(verbose)
                #scan()
                send_expect(listener, ttt.get_connection_success_filter())
                listener.send_input(ttt.connect_device, mac, True, 0)

                time.sleep(2)

                if len(listener.get_output()) > 0:
                    return True
                else:
                    return False
            else:
                return True


def is_connected(mac):
    if process != None:
        send_expect(listener, ttt.get_connected_filter())
        listener.send_input(ttt.device_connected, mac, True, 0)

        time.sleep(1)

        #listener.send_input(None, ctl.quit_interactive(), True, 0)

        out = listener.get_output()

        if len(out) > 0:
            return True
        else:
            return False


def disconnect(mac):
    if process != None:
        if listener != None:
            listener.log_verbose(verbose)
            send_expect(listener, ctl.get_disconnect_success_filter())
            listener.send_input(ctl.disconnect_device, mac, True, 0)

            time.sleep(3)

            if len(listener.get_output()) > 0:
                return True
            else:
                return False


def list_paired():
    if process != None:
        p = force_backend("bluetoothctl")

        time.sleep(1)
        l = start_listening(p, True)
        l.log_verbose(verbose)
        send_expect(l, ctl.get_paired_devices_filter())
        l.send_input(None, ctl.get_paired_devices(), True, 0)
        time.sleep(1)
        #l.send_input(None, ctl.quit_interactive(), True, 0)

        #stop_listening(l)
        #stop_interactive(process)


        return l.get_output()


def unpair(mac):
    if process != None:
        if is_paired(mac) is True:

            time.sleep(2)
            l = start_listening(process, True)
            send_expect(l, ctl.get_remove_device_filter())
            l.send_input(ctl.unpair_device, mac, True, 0)
            time.sleep(1)
            l.send_input(None, ctl.quit_interactive(), True, 0)

            stop_listening(l)
            stop_interactive(process)

            if len(l.get_output()) > 0:
                return True
            else:
                return False
        else:
            return True

def connected_devices():
    if process != None:
        send_expect(listener, ctl.get_connected_devices_filter())
        listener.send_input(None, ctl.get_connected_devices(), True, 0)
        time.sleep(1)

        output = listener.get_output()

        if len(output) > 0:
            return output
        else:
            return ""

def write_value_uuid(uuid, value):
    if process != None:
        send_expect(listener, [])
        listener.send_input(ctl.write, [uuid, value], True, 0)

        time.sleep(3)


def write_value_handle(mac, handle, value):
    if process != None:
        if backend == "gatttool":
            if listener != None:
                if is_connected(mac) == False:
                    connect(mac)
                    time.sleep(1)

                send_expect(listener, ttt.get_write_value_filter())
                listener.send_input(ttt.write, [handle, value], True, 0)

                time.sleep(3)


def read_value(mac, uuid):
    if process != None:
        if is_connected(mac) == False:
            connect(mac)
            time.sleep(1)

        send_expect(listener, ttt.get_read_value_filter())
        listener.send_input(ttt.read, uuid, True, 0)

        time.sleep(1.5)

        output = listener.get_output()

        if len(output) > 0:
            return output
        else:
            return ""


def format_input(input):
    retVal = ''

    if len(input) > 1:
        for val in input:
            #if backend == 'gatttool':
            retVal += '' + val
            #elif backend == 'bluetoothctl':
                #retVal += '0x' + val + ' '

    print(retVal)
    return retVal
