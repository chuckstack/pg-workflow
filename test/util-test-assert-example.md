
# The purpose of this file is to offer examples when asserting test conditions.

## Summary of Operators
```bash
- `==`: Equal to (string comparison)
- `!=`: Not equal to (string comparison)
- `<`: Less than (string comparison)
- `>`: Greater than (string comparison)
- `-eq`: Equal to (numeric comparison)
- `-ne`: Not equal to (numeric comparison)
- `-lt`: Less than (numeric comparison)
- `-le`: Less than or equal to (numeric comparison)
- `-gt`: Greater than (numeric comparison)
- `-ge`: Greater than or equal to (numeric comparison)
- `-z`: Check if a string is empty
- `-n`: Check if a string is not empty
- `-e`: Check if a file exists
- `-d`: Check if a directory exists
- `-f`: Check if a file exists and is a regular file
- `=~`: Check if a string matches a regular expression
- `&&`: Logical AND
- `||`: Logical OR
```

## How to Form an Assert Statement from an Operator
```bash
assert_string="Assert strings are equal"
[[ "$string1" == "$string2" ]] && echo "Passed: $assert_string" || echo "Failed: $assert_string"; exit 1
```

## Example of Operators

Use any of the following examples to form an assertion like the one above.

Checking if two strings are equal:
```bash
if [[ "$string1" == "$string2" ]]; then
    echo "Strings are equal"
else
    echo "Strings are not equal"
fi
```

Checking if a file exists:
```bash
if [[ -e "$file_path" ]]; then
    echo "File exists"
else
    echo "File does not exist"
fi
```

Checking if a variable is empty:
```bash
if [[ -z "$variable" ]]; then
    echo "Variable is empty"
else
    echo "Variable is not empty"
fi
```

Checking if a number is greater than another:
```bash
if [[ "$num1" -gt "$num2" ]]; then
    echo "num1 is greater than num2"
else
    echo "num1 is not greater than num2"
fi
```


Checking if a string starts with a specific substring:
```bash
if [[ "$string" == "prefix"* ]]; then
    echo "String starts with 'prefix'"
else
    echo "String does not start with 'prefix'"
fi
```

Checking if a number is within a range:
```bash
if [[ "$number" -ge 1 && "$number" -le 10 ]]; then
    echo "Number is between 1 and 10"
else
    echo "Number is not between 1 and 10"
fi
```

Checking if a string matches a regular expression:
```bash
if [[ "$string" =~ ^[0-9]+$ ]]; then
    echo "String contains only digits"
else
    echo "String does not contain only digits"
fi
```

Using double brackets `[[` and `]]` has some advantages over the single brackets `[` and `]`:

- Double brackets allow you to use more advanced syntax and operators, such as `&&` (and), `||` (or), `<` (less than), `>` (greater than), etc.
- Double brackets provide better handling of empty variables and prevent unintended word splitting.
- Double brackets support pattern matching using the `=~` operator for regular expressions.

Using double brackets provides a more expressive and powerful way to write assertions in Bash scripts. However, keep in mind that double brackets are specific to Bash and may not be available in other shells.

