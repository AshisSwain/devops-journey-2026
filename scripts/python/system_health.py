#!/usr/bin/env python3

import shutil
import socket

hostname = socket.gethostname()

total, used, free = shutil.disk_usage("/")

disk_usage = used / total * 100

print("===== SYSTEM HEALTH =====")
print(f"Hostname: {hostname}")
print(f"Disk Usage: {disk_usage:.2f}%")

if disk_usage > 80:
    print("WARNING: Disk usage is above 80%")
else:
    print("Disk status: OK")
