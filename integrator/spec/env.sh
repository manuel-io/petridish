NULL=/dev/null
ERROR=/dev/stderr
CROSS_COMPILE=$1

function test_env {
  echo -n "Test enviornment"
  for program in qemu-system-arm \
    "${CROSS_COMPILE}gcc" \
    "${CROSS_COMPILE}as" \
    "${CROSS_COMPILE}ld" \
  egrep read test echo
  do
    which $program &> $NULL || {
      echo -e "\nError: ${program} not found" > $ERROR
      return 1
    }
  done
  return 0
}

function tests_main {
  for com in \
    test_env
  do
    $com && echo " ...done" || echo " ...error"
  done
  return 0
}

tests_main
