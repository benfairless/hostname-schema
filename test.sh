#!/usr/bin/env bash

################################################################################
############################## GENERAL FUNCTIONS ###############################
################################################################################

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
DEFAULT_COLOUR='\033[0m'

output() {
  local COLOUR=${BLUE}
  local RESET=${DEFAULT_COLOUR}   # Standard
  local LABEL='TESTER'
  local MSG=${2}
  case ${1} in
      ERROR) local COLOUR=${RED}    ;; # Red
    SUCCESS) local COLOUR=${GREEN}  ;; # Green
       WARN) local COLOUR=${YELLOW} ;; # Yellow
       INFO) local COLOUR=${BLUE}   ;; # Blue
  esac
  echo -e "${COLOUR}[${LABEL}] ${MSG}${RESET}"
}

error()
{
   output ERROR "${1}"
   exit 1
}

################################################################################
############################### INPUT VALIDATION ###############################
################################################################################

# Ensure a script is specified
[ -z ${1} ] && error 'No script specified to test!'

# Check script actually exists
[ -f ${1} ] || error 'The specified path does not exist!'

COMMAND=${1}
echo $command

################################################################################
################################### TESTING ####################################
################################################################################

SCENARIOS=() # Array of test situations
ITEM=0 # Increasing counter of which test is being ran
FAIL=0 # Used to indicate whether any test fails for exit status

SCENARIOS+=('0:dc-servce-roles-c01.domain.local:MATCH - Valid max for each field')
SCENARIOS+=('0:DC-SERVCE-ROLES-C01.DOMAIN.LOCAL:MATCH - Case should be ignored')
SCENARIOS+=('1:generic.domain.local:NO MATCH - Has a single field')
SCENARIOS+=('1:dc1-servce-roles-c01.domain.local:NO MATCH - Field 1 < 2')
SCENARIOS+=('1:d-servce-roles-c01.domain.local:NO MAARGUMENTTCH - Field 1 < 2')
SCENARIOS+=('1:dc-service-roles-c01.domain.local:NO MATCH - Field 2 < 6')
SCENARIOS+=('0:dc-srv-roles-c01.domain.local:MATCH - Field 2 < 6')
SCENARIOS+=('1:dc-servce-rolesgo-c01.domain.local:NO MATCH - Field 3 < 5')
SCENARIOS+=('0:dc-servce-role-c01.domain.local:MATCH - Field 3 < 5')
SCENARIOS+=('1:dc-servce-roles-101.domain.local:NO MATCH - Field 4 is not Alpha')
SCENARIOS+=('1:dc-servce-roles-cA1.domain.local:NO MATCH - Field 5 not numeric')
SCENARIOS+=('1:dc-servce-roles-c1A.domain.local:NO MATCH - Field 5 not numeric')
SCENARIOS+=('1:dc-servce-roles-c01:NO MATCH - Not a valid FQDN')
SCENARIOS+=('1:dc-servce-roles-c01.fail.local:NO MATCH - Not a valid domain')

output INFO "Running ${#SCENARIOS[@]} test scenarios..."
# Main loop to run through each test scenario
for SCENARIO in "${SCENARIOS[@]}"; do
  ITEM=$((ITEM+1))
  # Split desired exit status from test argument
  DESIRED=$(echo ${SCENARIO} | cut -d ':' -f 1)
  ARGUMENT=$(echo ${SCENARIO} | cut -d ':' -f 2)
  STATEMENT=$(echo ${SCENARIO} | cut -d ':' -f 3)
  # Run test scenario
  ./${COMMAND} ${ARGUMENT}
  STATE=$?
  # Check exit status
  [ ${DESIRED} -eq ${STATE} ] && \
     output INFO "[${ITEM}/${#SCENARIOS[@]}] Test '${STATEMENT}' passed ${GREEN}✓${DEFAULT_COLOUR}" || \
     ( output WARN "[${ITEM}/${#SCENARIOS[@]}] Test '${STATEMENT}' failed ${RED}✗${DEFAULT_COLOUR}"; FAIL=$((FAIL+1)) )
done

# Check to see if any failures were generated
PERCENT=$((200*${FAIL}/${#SCENARIOS[@]} % 2 + 100*${FAIL}/${#SCENARIOS[@]})) # Witchcraft
[ $FAIL -gt 0 ] && \
   error "$(tput bold)${PERCENT}% of tests failed to pass!$(tput sgr0)" || \
   output INFO "$(tput bold) 100% of tests passed successfully!$(tput sgr0)"
exit 0
