#!/bin/bash

DISK="/srv/dev-disk-by-uuid-c497dd5c-e3cc-48fb-b67c-a6cb0865cf53"

sudo chmod 755 -R "$DISK/data"
sudo chown alejandro -R "$DISK/data"
sudo chgrp alejandro -R "$DISK/data"
