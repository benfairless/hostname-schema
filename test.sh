#!/usr/bin/env bash

################################################################################
############################## GENERAL FUNCTIONS ###############################
################################################################################

output() {
  local COLOUR='\033[0m' # Blue
  local RESET='\033[0m'   # Standard
  local LABEL='TESTER'
  case ${1} in
      ERROR) local COLOUR='\033[31m' ;; # Red
    SUCCESS) local COLOUR='\033[32m' ;; # Green
       WARN) local COLOUR='\033[33m' ;; # Yellow
       INFO) local COLOUR='\033[34m' ;; # Blue
  esac
  while read LINE; do
    echo -e "${COLOUR}[${LABEL}] ${LINE}${RESET}"
  done
}

################################################################################
############################### INPUT VALIDATION ###############################
################################################################################

# Ensure a script is specified
if [[ -z ${1} ]]; then
  echo 'No script specified to test!' | output ERROR
  exit 1
elif [[ ! -f ${1} ]]; then # Check script actually exists
  echo 'The specified path does not exist!' | output ERROR
  exit 1
else
  COMMAND=$1
fi

################################################################################
################################### TESTING ####################################
################################################################################

SCENARIOS=() # Array of test situations
ITEM=0 # Increasing counter of which test is being ran
FAIL=0 # Used to indicate whether any test fails for exit status

SCENARIOS+=('0:dc-servce-roles-c01.domain.local:MATCH - Valid max for each field')
SCENARIOS+=('0:DC-SERVCE-ROLES-C01.DOMAIN.LOCAL:MATCH - Case should be ignored')
SCENARIOS+=('1:generic.domain.local:NO MATCH - Has a single field')
SCENARIOS+=('1:dc1-servce-roles-c01.domain.local:NO MATCH - Field 1 > 2')
SCENARIOS+=('1:d-servce-roles-c01.domain.local:NO MATCH - Field 1 < 2')
SCENARIOS+=('1:dc-service-roles-c01.domain.local:NO MATCH - Field 2 > 6')
SCENARIOS+=('0:dc-srv-roles-c01.domain.local:MATCH - Field 2 <= 6')
SCENARIOS+=('1:dc-servce-rolesgo-c01.domain.local:NO MATCH - Field 3 > 5')
SCENARIOS+=('0:dc-servce-role-c01.domain.local:MATCH - Field 3 <= 5')
SCENARIOS+=('1:dc-servce-roles-101.domain.local:NO MATCH - Field 4 is not Alpha')
SCENARIOS+=('1:dc-servce-roles-cA1.domain.local:NO MATCH - Field 5 not numeric')
SCENARIOS+=('1:dc-servce-roles-c1A.domain.local:NO MATCH - Field 5 not numeric')
SCENARIOS+=('1:dc-servce-roles-c01:NO MATCH - Not a valid FQDN')
SCENARIOS+=('1:dc-servce-roles-c01.fail.local:NO MATCH - Not a valid domain')

echo -e "Running ${#SCENARIOS[@]} test scenarios..." | output
# Main loop to run through each test scenario
for SCENARIO in "${SCENARIOS[@]}"; do
  ITEM=$((ITEM+1))
  # Split desired exit status from test argument
  DESIRED=$(echo ${SCENARIO} | cut -d ':' -f 1)
  ARGUMENT=$(echo ${SCENARIO} | cut -d ':' -f 2)
  STATEMENT=$(echo ${SCENARIO} | cut -d ':' -f 3)
  # Run test scenario
  $(bash $COMMAND $ARGUMENT)
  STATE=$?
  # Check exit status
  if [[ ${DESIRED} == ${STATE} ]]; then
    echo -e "[${ITEM}/${#SCENARIOS[@]}] Test '${STATEMENT}' passed \033[32m✓\033[0m" | output
  else
    echo -e "[${ITEM}/${#SCENARIOS[@]}] Test '${STATEMENT}' failed \033[31m✗\033[0m" | output WARN
    FAIL=$((FAIL+1))
  fi
done

# Check to see if any failures were generated
if [[ $FAIL -gt 0 ]]; then
  PERCENT=$((200*${FAIL}/${#SCENARIOS[@]} % 2 + 100*${FAIL}/${#SCENARIOS[@]})) # Witchcraft
  echo "$(tput bold)${PERCENT}% of tests failed to pass!$(tput sgr0)" | output ERROR
  exit 1
else
  echo "$(tput bold) 100% of tests passed successfully!$(tput sgr0)" | output SUCCESS
  exit 0
fi
