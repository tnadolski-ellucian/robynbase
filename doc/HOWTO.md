# HOWTO

## How to Restore the Robynbase DB locally

This command restores the dev database using the given SQL dump.

The dev database is dropped and recreated, so make sure the dump also recreates the schema.

```
./utilities/restore_dev_from_dump.sh <MYSQL dump file>
```

## Create backup of local db

This command writes a backup of the dev database (robyn_dev) to a backup database (robyn_dev_backup), which it. creates from scratch.

```
./utilities/create_backup.sh 
```

## Import a CSV file

This **must** be run from the `./import` directory 

```
RAILS_ENV=development ruby read_import_csv.rb <CSV file>
```
