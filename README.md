Hostname Schema Challenge
=========================

You must develop a simple command-line application which receives a single
command line argument which will be a fully-qualified hostname. The hostname
must be validated against the schema and then the application must exit; if the
hostname does not match the schema the exit status must be non-zero, only if the
hostname matches the schema should the application exit with a zero exit status.

The application can be written in any language commonly available on a POSIX
system but Ruby, Bash, or Java would be preferable for this solution.

## Rules

  - Hostnames should match a schema of:
  ```SQL
  [CHAR(2)]-[VARCHAR(<=6)]-[VARCHAR(<=5)]-[CHAR(1)][DECIMAL(2,0)].DOMAIN.LOCAL
  ```
  - The application should by default exit with a non-zero exit status.
    It should only exit with a zero status if the schema is matched correctly.
  - Your application should be able to pass 100% of tests using `test.sh`.
  - Your application should accept the hostname as a command-line arguement.
  - Hostnames are not case-sensitive and should match regardless of case.
  - Bonus points for `DOMAIN.LOCAL` being a variable which can be configured in some way.

## How to run the tests

In order to test if your application is behaving correctly you can test it by running the `test.sh` script in this directory.

```
$ ./test.sh path/to/application.bin

> Running test 1 of 12...
> Test passed.
> Running test 2 of 12...
> Test passed.
...
> All tests passed successfully.
```
