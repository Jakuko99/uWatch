import subprocess
import os
import time
import shlex
import errno
import threading


class process_worker(threading.Thread):
    def __init__(self, process):
        threading.Thread.__init__(self)
        self.process = process
        self.expect = []
        self.input = []
        self.waiting_input = False
        self.waiting_input_timeout = 10000
        self.not_expect = []
        self.errorList = []
        self.out = []
        self.timeout = 0
        self.verbose = False

    def run(self):
        while True:
            # Wait for input if input is expected and timeout not reached
            while self.waiting_input and self.waiting_input_timeout != 0:
                self.waiting_input_timeout -= 1

                # Stop waiting if timeout is reached. Loop will stop when
                # timeout reaches 0 but to avoid possible problems, set waiting
                # to false
                if self.waiting_input_timeout == 0:
                    self.waiting_input = False
                    print("Stop waiting for input because of timeout.")

            output = self.process.stdout.readline()
            if self.process.poll() is not None:
                break
            if output:
                if len(self.not_expect) > 0:
                    if not any(exp in output for exp in self.not_expect):
                        self.append_output(output.strip())
                        if self.verbose == True:
                            print("Pushing to output: " + output)
                            print("Output is now:")
                            print(self.out)
                elif len(self.expect) > 0:
                    if self.verbose == True:
                        print("Expecting in " + output.strip())
                        print(self.expect)
                    if any(exp in output for exp in self.expect):
                        self.append_output(output.strip())
                        if self.verbose == True:
                            print("Pushing to output: " + output.strip())
                            print("Output is now:")
                            print(self.out)

                    elif len(self.errorList) > 0:
                        if any(err in output for err in self.errorList):
                            print("error")

    def send_input(self, func, input, linebreak, timeout):
        if func != None and input == None:
            input = func
        elif func != None and input != None:
            input = func(input)

        self.timeout = timeout
        try:
            for line in input:
                self.process.stdin.write(line)

            if linebreak:
                self.process.stdin.write('\n')

            if self.waiting_input:
                # Reset expecting input and input timeout if it is set.
                self.waiting_input = False
                self.waiting_input_timeout = 10000
                print("Starting to wait for input with timeout of", self.waiting_input_timeout)
        except IOError as e:
            if e.errno == errno.EPIPE or e.errno == errno.EINVAL:
                # Stop loop on "Invalid pipe" or "Invalid argument".
                # No sense in continuing with broken pipe.
                return "Error"
            else:
                # Raise any other error.
                raise "Error"

    def wait_for_input(self, timeout):
        self.waiting_input = True
        self.waiting_input_timeout = timeout

    def expect_output(self, arr):
        self.expect = arr

    def expect_error(self, errorList):
        self.erroList = errorList

    def remove_expect(self):
        del self.expect

    def append_output(self, output):
        try:
            if self.out == None:
                self.out = [output]
            else:
                self.out.append(output)
        except:
            print('Error appending output')

    def get_output(self):
        return self.out

    def clear_output(self):
        self.out.clear()

    def stop(self):
        self.join()

    def log_verbose(self, verbose):
        self.verbose = verbose

# Execute one command that is not interactive and return output


def execute(command):
    stream = subprocess.Popen(command,
                              stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE,
                              universal_newlines=True,
                              bufsize=0)

    stream.wait()

    return stream.stdout.read()

# Execute one command that is interactive and let it run until stopped


def execute_interactive(executable):
    stream = subprocess.Popen(executable,
                              stdin=subprocess.PIPE,
                              stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE,
                              universal_newlines=True,
                              bufsize=0)

    return stream


def stop_interactive(process):
    process.terminate()
