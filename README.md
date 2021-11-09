
<img src="https://static.scarf.sh/a.png?x-pxid=6fda9435-f3b2-42be-af5c-eaec10ee39d8" />
<p align="center">
        <img alt="logo" src="assets/logo.png" width=150>
        <h1 align="center">HyperC<br/>Planning Database</h1>
</p>

## About HyperCDB

HyperC Planning Database enables processing of data and business rules with autonomous algorithms. HyperCDB finds best-effort-optimal plans in retail, logistics, robotics, IT infrastructure and others using action schema defined with an easy domain-independent language. 

HyperCDB reads stored PostgreSQL procedures written in Python and applies only relevant of them repeatedly to reach a desired end state. It achieves this by gradually lowering the logic order of defined procedures to selected grounded states. The math behind HyperC lies in realms of [AI planning](https://en.wikipedia.org/wiki/Automated_planning_and_scheduling), [automatic proof](https://en.wikipedia.org/wiki/Automated_theorem_proving) and [type theory](https://en.wikipedia.org/wiki/Type_theory).

## Transitional Database vs. Transactional Database

HyperCDB is a transitional, or planning database. This means that instead of blindly accepting an `UPDATE` to the stored data, HyperCDB calculates if it is possible to reach the new proposed state using the allowed transitions. This transitional property is useful in several scenarios:

- Validating every change to the data to be in compliance with defined business process
- Generating missing data and performing consistency healing automatically
- Planning restocking, checking manufacturing timings, allocating workforce, etc.
- Rebalancing cloud clusters with complex resource dependencies and constraints
- Robotic motion planning for 3D printers, cutters, and multi-axis robots
- Automatic website design
- Creating spacecraft launch sequences
- etc.

## Getting Started with HyperCDB

### Installation

```
docker run -p 8493:8493 hypercdb/hypercdb
```

Then connect to the database using [pgAdmin](https://www.pgadmin.org/) or your favorite PostgreSQL admin tool. Demo project user is `pguser` and password is `123`.

To run with persistent data, use:

```
docker run --name hyperc -p 8493:8493 -v <path to your local folder>:/opt/hyperc/db/data hypercdb/hypercdb
```

### Create your first plan

HyperCDB docker image comes with a demo database with vehicles in `trucks` table and map defined in `location_adjacency` table.

To create a plan for the trucks to move, issue the `TRANSIT` query:

```
$ psql -h localhost --port 8493 -U pguser testdb
```

```SQL
testdb=> SELECT * FROM trucks;
  name   | odometer | location 
---------+----------+----------
 Truck 2 |        0 | Office
 Truck 1 |        0 | Home

testdb=> TRANSIT UPDATE trucks SET location = 'Office';

step_num   |  proc_name 
-----------+-------------
         0 |  move_truck
         1 |  move_truck
          ...

testdb=> SELECT * FROM trucks;
  name   | odometer | location 
---------+----------+----------
 Truck 2 |        0 | Office
 Truck 1 |        7 | Office

```

`TRANSIT` queries tell HyperC to calculate transition plan instead of 'just' accepting the change. You will also notice that `odometer` reading was updated automatically, as `move_truck` procedure was also counting mileage at every execution.

## Preparing Database From Scratch

### Initializing database

HyperCDB requires special table `hc_plan` and procedure `hyperc_transit` to be initialized in the database so you must always explicitly issue this command:

```SQL
TRANSIT INIT;
```

You must be connected to correct database before issuing `TRANSIT INIT`.

### Creating tables

Creating tables works exactly the same as in any PostgreSQL database with additional requirement that all tables must have `PRIMARY KEY` defined:

```SQL
CREATE TABLE public.trucks (
    name character varying(50) PRIMARY KEY NOT NULL,
    odometer integer,
    location character varying(50) NOT NULL
);
```

### Creating transition procedures

All transition procedures must have language `'hyperc'` and define one or more input parameters. Column names must be all capital letters in current edition of HyperCDB procedure language:

```SQL
CREATE PROCEDURE move_truck(t trucks, l location_adjacency)
LANGUAGE 'hyperc'
AS $BODY$

assert t.LOCATION == l.LOC_A
t.LOCATION = l.LOC_B
t.ODOMETER += l.DISTANCE

$BODY$;
```

Procedure `move_truck(t truck, l location_adjacency)` takes two rows as input: any row from `trucks` table as local variable `t` and any row from `location_adjacency` table with local name `l`. Additional information on defining stored procedures can be found in [PostgreSQL manual](https://www.postgresql.org/docs/14/sql-createprocedure.html).

HyperC will automatically define which rows have the best match to reach end state in least steps.

The body of the procedure is defined in Python-like dialect:

```python
assert t.LOCATION == l.LOC_A
t.LOCATION = l.LOC_B
t.ODOMETER += l.DISTANCE
```

The first line, `assert t.LOCATION == l.LOC_A` means that only such two rows (`t` from `trucks` and `l` from `location_adjacency`) that have equal values in columns `location` and `loc_a` respectively can be used in this procedure. The business logic behind this assertion is that we want to 'JOIN' tables `trucks` and `location_adjacency` by columns `LOCATION` and `LOC_A` because the truck can only move to the next adjacent location, defined in columns `LOC_A` and `LOC_B` in locations adjacency map table.

The second and third lines define the effects of the procedure: updating location of the truck to next hop from the table, and increasing the odometer.

## Documentation

HyperCDB is based on [PostgreSQL database v.14](https://www.postgresql.org/docs/14/index.html) and most functions of the database work as expected.

The HyperC Planning Database extends SQL language with the `TRANSIT *` set of commands:

---

```
TRANSIT INIT
```

Prepares the database for planning function.

---

```
[ EXPLAIN [ TO table_name1[.column], table_name2, ... ]] TRANSIT UPDATE table_name
   SET { column = { expression | DEFAULT } |
          ( column [, ...] ) = ( { expression | DEFAULT } [, ...] ) } [, ...]
    [ WHERE condition ]
```

`TRANSIT UPDATE` initiates transition to the state defined by UPDATE statement with familiar SQL syntax of [UPDATE](https://www.postgresql.org/docs/14/sql-update.html). It returns the table of the plan with unique plan_id that can be remembered and used to query `hc_plan` table to recall this plan at any later time. 

`EXPLAIN TRANSIT ...` - initiates calculation of the plan, stores and outputs the plan table but does not do any actual updates to the state.

`EXPLAIN TO *table_name*, ... TRANSIT ...` - instructs the solver to only write down changes to tables (and possibly columns) specified after `TO` keyword.

Examples:

Calculate transition plan but only write down `odometer` reading, leaving truck at its original location:

```SQL
EXPLAIN TO trucks.odometer TRANSIT UPDATE trucks SET location = 'Office';
```

---

### hc_plan table

HyperCDB defines a special table `hc_plan` to incrementally store all plans with called procedure names and input/output parameters in JSONB objects.

The purpose of hc_plan table is to easily extract additional information from the plans like tracing the truck travel path, measuring fuel consumption, etc. When TRANSIT command completes it outputs back to the user connection the table with plan summary where plan_id can be extracted and remembered by the client application.

# Status

HyperC in under active development. It is used in several production environments but has scalability limitations that are being addressed using various machine learning techniques. 

# Support

HyperCDB is supported by HyperC team. Feel free to write at andrew@hyperc.com.
