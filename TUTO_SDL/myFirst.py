#!/usr/bin/env python3
#coding: utf-8
#

import sys;
import threading;

def temp():
    with open("/sys/devices/platform/coretemp.0/hwmon/hwmon3/temp1_input")as f:
        print("%s" % f.readline())

def do_every (interval, worker_func, iterations = 0):
    global timer
    # launch new timer
    if ( iterations != 1):
        timer = threading.Timer (
            interval,
            do_every, [interval, worker_func, 0 if iterations == 0 else iterations-1] );
        timer.start()
            # launch worker function
        worker_func();


def main():
    ''' comment related to the function '''
    print("M2siame");
    do_every(10,temp,10)
  
    sys.exit(0);
    


## Execution or import
if __name__ == "__main__":
    # Start executing
    main()
    sys.exit(0)
