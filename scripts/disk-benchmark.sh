#!/bin/bash

# Hard Disk USB 2.0 Lacei
LACEI_DISK="/srv/dev-disk-by-uuid-E60A-2B1D"
dd if=/dev/zero of="$LACEI_DISK/output" conv=fdatasync bs=384k count=1k; rm -f "$LACEI_DISK/output"

# Pendrive Kingston DataTraveler 3.0
DATA_TRAVELER_DISK="/srv/dev-disk-by-uuid-98B0-9A51"
dd if=/dev/zero of="$DATA_TRAVELER_DISK/output" conv=fdatasync bs=384k count=1k; rm -f "$DATA_TRAVELER_DISK/output"
