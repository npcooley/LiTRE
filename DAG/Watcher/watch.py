#!/usr/bin/python3

import sys
from time import time,sleep

try:
    import htcondor
except:
    print("Error: Failed to import htcondor module")
    sys.exit(1)

# Handle passed Args
argc = len(sys.argv)
if argc != 3:
    cmd = " ".join(sys.argv)
    print(f"Error: Invalid number of arguments ({argc}): {cmd}")
    sys.exit(1) 

try:
    ID = int(sys.argv[1])
except ValueError:
    print(f"Error: Invalid Cluster Id provided: {sys.argv[1]}")
    sys.exit(1)

valid_timeout = True
try:
    TIMEOUT = int(sys.argv[2])
    valid_timeout = TIMEOUT > 0
except ValueError:
    valid_timeout = False
if not valid_timeout:
    print(f"Error: Invalid timeout provided: {sys.argv[2]}")
    sys.exit(1)

# Get Schedd Object
schedd = htcondor.Schedd()

# Query information from this jobs Ad
ads = schedd.query(f"ClusterId=={ID}", ["DAGManJobId"])
if len(ads) != 1:
    print("Error: Invalid number of ads returned")
    sys.exit(1)

# Get Parent DAGMan proper job that submitted this job
dag_id = int(ads[0].get("DAGManJobId", -1))

# Get information from Parent DAGMan Job
ads = schedd.query(f"ClusterId=={dag_id}", ["ShadowBday","DAG_NodesTotal"])
if len(ads) != 1:
    print("Error: Invalid number of ads returned with DAGManJobId")
    sys.exit(1)

# Store DAGMan number of nodes (not including Service) and start time
start_t = int(ads[0].get("ShadowBday", 0))
nodes_total = int(ads[0].get("DAG_NodesTotal", 0))

# Wait for timeout to be reached
while time()-start_t < TIMEOUT:
    sleep(1)

# output information
print(f"""
--------
DAG: Id={dag_id} StartTime={start_t} NumNodes={nodes_total}
General: Cluster={ID} Timeout={TIMEOUT} EndTime={int(time())}
--------
""")

# Check history for node clusters (doesn't handle multi-proc jobs)
ads = schedd.history(f"DAGManJobId=={dag_id} && ClusterId=!={ID}", ["ExitCode"])

# Check returned Ads:
#     A) All jobs accounted for
#     B) All jobs exited successfully
all_exit_zero = True
num_jobs = 0
for ad in ads:
    print(ad)
    num_jobs += 1
    if ad["ExitCode"] != 0:
        all_exit_zero = False

success = num_jobs > 0 and all_exit_zero
print(f"Success={success}")

# If successful then don't abort DAG but exit 0
sys.exit(0 if success else 2)
