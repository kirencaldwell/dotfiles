#!/bin/bash
# Run marvel curvature response simulation

./sim/launch.sh marvel planner vis/controls_analysis/sim_tests:curvature_response --simulator_args="--params-kv sim/enable_cas=false --params-kv sim/terminate_on=none"
