import os
import subprocess

# env = os.environ
# newpath = r'D:\Earthquake\myStudy\OpenSees3.3.0\bin;'+env['PATH']
# env['PATH'] = newpath  

r = subprocess.run('C:/Users/user/Downloads/MKT+V1.24.2/MKT.exe',shell=True, capture_output=True, text=True)    
# CompletedProcess returned
print(r.args)
print(r.returncode)
print(r.stderr)
print(r.stdout)