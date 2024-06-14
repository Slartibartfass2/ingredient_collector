#!\bin\bash

find test/recipe_parser_tests/parser_test_files -iname "*.json" -exec bash -c '
   ret=0
   for file do
       ajv validate -s scripts/test-file-validation/recipe_schema.json -d "$file" --spec=draft2020 || ret=$?
   done
   exit "$ret"' bash {} +
