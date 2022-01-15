import os
import time
from datetime import datetime
# from datetime import timedelta  

import random

def my_function():  
  print("This prints once a minute.")
        

def lambda_handler(event, context):

    i = 1
    while i < 600:
        now = datetime.now()
        current_time = now.strftime("%H:%M:%S")
        print("Current Time =", current_time)        
        my_function()
        i += 1    
        # time.sleep(5)
        rand = random.randint(1, 60)
        print('Running for {} seconds'.format(rand))
        # time.sleep(rand)
    return "{} from Lambda!".format(os.environ['greeting'])




