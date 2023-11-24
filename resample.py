import os
import sys
import shutil
import random
#import sox
import subprocess

#Revisa que el número de argumentos introducidos sea el correcto
if(len(sys.argv) != 4):
    print("Usage: <path_to_database> <path_to_database_output> <Sample rate>")
    sys.exit()

#Guarda las entradas de los argumentos en variables manipulables
dir_in = sys.argv[1]
dir_out = sys.argv[2]
sr = int(sys.argv[3])

print(dir_in)
print(dir_out)
print(sr)

files = os.listdir(dir_in)
print(files)
if(not os.path.exists(dir_out)):
    os.makedirs(dir_out)

for wav in files:
    #print(dir_in + "/" + wav)
    #print(dir_out + "/" + wav)
    os.system(("sox " + dir_in + "/" + wav + " -r " + str(sr) + " " + dir_out  + "/" + wav))