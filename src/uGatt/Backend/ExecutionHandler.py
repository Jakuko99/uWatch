import subprocess
import os
import time
import shlex
import errno
import threading

class process_worker(threading.Thread):
    def __init__ (self,process):
        threading.Thread.__init__(self)
        self.process    = process
        self.expect     = []
        self.not_expect = []
        self.errorList  = []
        self.out        = []
        self.timeout    = 0
        self.verbose    = False

    def run(self):
        while True:
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

    def send_input(self, func, input, timeout):
        if func != None and input == None:
            input = func
        elif func != None and input != None:
            input = func(input)
            
        self.timeout = timeout
        try:
            for line in input:
                self.process.stdin.write(line)
                self.process.stdin.write('\n')
        except IOError as e:
            if e.errno == errno.EPIPE or e.errno == errno.EINVAL:
                # Stop loop on "Invalid pipe" or "Invalid argument".
                # No sense in continuing with broken pipe.
                return "Error"
            else:
                # Raise any other error.
                raise "Error"

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
                        stdin =subprocess.PIPE,
                        stdout=subprocess.PIPE,
                        stderr=subprocess.PIPE,
                        universal_newlines=True,
                        bufsize=0)

    return stream

def stop_interactive(process):
    process.terminate()


