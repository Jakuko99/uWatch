try:
    from .ExecutionHandler import execute, process_worker, execute_interactive, stop_interactive
except:
    from ExecutionHandler import execute, process_worker, execute_interactive, stop_interactive

import time

# default to bluetoothctl as this is the preferred backend - gatttool is deprecated
backend = "bluetoothctl"


def set_backend():
    global backend

    process = execute_interactive(["bluetoothctl"])

    listener = start_listening(process, False)
    # Expect the string "Version" in output
    listener.expect_output(["Version"])
    # Send sub command to bluetooth ctl to read the current version
    listener.send_input(None, ["version"], True, 0)
    # Exit bluetoothctl cleanly to be able to join the thread. This is not supposed to be a continously running process as it is just to determin which backend to use.
    listener.send_input(None, ['exit'], True, 0)

    #if not listener.is_alive():
    #    print(listener.get_output())

    stop_listening(listener)
    stop_interactive(process)

    ###
    # If bluetoothctl version is lower than 5.48 use gatttool
    # The GATT commands in bluetoothctl < 5.48 are not working reliable
    ###
    version = listener.get_output()[0].split(' ')[1]
    print("Ver: " + version)
    if float(version) >= 5.48:
        backend = "bluetoothctl"
        return load_bluetoothctl_backend()
    else:
        backend = "gatttool"
        return load_gatttool_backend()



def get_backend_exec():
    return backend


def load_bluetoothctl_backend():
    try:
        global get_backend
        from .bluetoothctl import get_backend
        return True
    except Exception as e:
        print("Could not import backend:" + e)
        return False


def load_gatttool_backend():
    try:
        global get_backend
        from .gatttool import get_backend
        return True
    except Exception as e:
        print("Could not import backend:" + e)
        return False


def start_backend():
    return execute_interactive(get_backend())


def force_backend(backend):
    return execute_interactive(backend)


def stop_backend(process):
    process.terminate()


def start_listening(process, daemon):
    listen = process_worker(process)
    listen.daemon = daemon
    listen.start()

    return listen


def stop_listening(listener):
    listener.stop()


def send_expect(listener, expectList):
    listener.clear_output()
    listener.expect_output(expectList)
