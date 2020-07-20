#!/bin/bash

set -e
set -o pipefail

if [ -z "${linting_path}" ] ; then
  echo " [!] Missing required input: linting_path"

  exit 1
fi

FLAGS=""
if [ "${strict}" = "yes" ] ; then
  FLAGS="--strict $FLAGS"
fi

if [ -s "${lint_config_file}" ] ; then
  FLAGS="--config ${lint_config_file} $FLAGS"
fi

cd "${linting_path}"

output="$(swiftlint lint --reporter "${reporter}" ${FLAGS})"
envman add --key "SWIFTLINT_REPORT" --value "${output}"
echo "Saved swiftlint output in SWIFTLINT_REPORT"

filename="${report_file}"
case $reporter in
    xcode|emoji)
      filename="${filename}.txt"
      ;;
    markdown)
      filename="${filename}.md"
      ;;
    csv|html)
      filename="${filename}.${reporter}"
      ;;
    checkstyle|junit)
      filename="${filename}.xml"
      ;;
    json|sonarqube)
      filename="${filename}.json"
      ;;
esac

report_path="${BITRISE_DEPLOY_DIR}/${filename}"
echo "${output}" > $report_path
envman add --key "SWIFTLINT_REPORT_PATH" --value "${report_path}"
echo "Saved swiftlint output in file, it's path is saved in SWIFTLINT_REPORT_PATH"

# Bitrise test reports support
case $reporter in
    junit)
      echo "Exporting test report for the test reports add-on..."
      ;;
    *)
      echo "Generating results for the test reports add-on..."
      output="$(swiftlint lint --reporter junit ${FLAGS})"
      filename="${report_file}.xml"
      report_path="${BITRISE_DEPLOY_DIR}/${filename}"
      echo "${output}" > $report_path
      ;;
esac

# Creating the sub-directory for the test run within the BITRISE_TEST_RESULT_DIR:
test_run_dir="$BITRISE_TEST_RESULT_DIR/Swiftlint"
mkdir "$test_run_dir"

# Exporting the JUnit XML test report:
cp $report_path "$test_run_dir/UnitTest.xml"

# Creating the test-info.json file with the name of the test run defined:
echo '{"test-name":"Swiftlint"}' >> "$test_run_dir/test-info.json"
echo "Done"
