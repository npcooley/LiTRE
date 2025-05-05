#!/bin/bash

# nothing fancy, this script needs to always exit gracefully so the DAG
# can manage everything
Rscript Flight.R ${1} ${2} ${3}

exit 0

