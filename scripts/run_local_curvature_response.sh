#!/bin/bash
# Run local curvature response simulation

./sim/launch.sh local planner vis/controls_analysis/sim_tests:curvature_response --simulator_args="--params-kv sim/enable_cas=false --params-kv sim/terminate_on=none" --save_chum_nfs
