# m61r-cli

Data manipulation in command line with use of pipes.

`m61r-cli` runs with R-package [`m61r`](https://github.com/pv71u98h1/m61r), `Rscript` and `shell` to manipulate `csv` and `rds` files.

Motivation was not dealing with large datasets. Instead, I was looking for a simple CLI tool to quickly manipulate data without having to install several packages.

Why with `R`? Because I will test with other languages as well.

## Examples:

```shell
./m61r --input "CO2.csv" --manip select --argument "~c(Plant,Type)" --output x
```
```
Plant        Type
1    Qn1      Quebec
2    Qn1      Quebec
3    Qn1      Quebec
4    Qn1      Quebec
5    Qn1      Quebec
6    Qn1      Quebec
7    Qn1      Quebec
8    Qn2      Quebec
...
```

```shell
./m61r --input "books.csv" --input "authors.csv" -c inner_join -p "by.x='name'" --param "by.y='surname'" --output x
```
```
name                         title other.author nationality deceased
1   McNeil     Interactive Data Analysis         <NA>   Australia       no
2   Ripley            Spatial Statistics         <NA>          UK       no
3   Ripley         Stochastic Simulation         <NA>          UK       no
4  Tierney                     LISP-STAT         <NA>          US       no
5    Tukey     Exploratory Data Analysis         <NA>          US      yes
6 Venables Modern Applied Statistics ...       Ripley   Australia       no
```

```shell
./m61r -i "CO2.csv" -i "CO2b.csv" -m group_by -a "group=~c(Type,Treatment)" | ./m61r -m summarise -a "mean=~mean(uptake)" -a "sd=~sd(uptake)" -o x
```
```
Type  Treatment     mean       sd
1      Quebec nonchilled  8.50000 2.121320
2      Quebec    chilled 15.81429 4.058976
3 Mississippi nonchilled 31.75238 9.644823
4 Mississippi    chilled 28.33333 7.637626
5         Foo nonchilled 25.95238 7.402136
6         Bar    chilled 35.33333 9.596371
```

## Usage

``` shell
Usage: ./m61r [-i input] [-e extra] [-c combine] [-p param] [-m manip] [-a arguments] [-o output]
  -i, --input    Input file
  -e, --extra    Extra file
  -c, --combine  Input combination
  -p, --param    Parameters regarding the combination
  -m, --manip    Data manipulation
  -a, --argument Arguments regarding the manipulation
  -o, --output   Type of output
  -h, --help     Help
```

List of combine options:
- rbind
- cbind
- inner_join
- left_join
- right_join
- full_join
- semi_join
- anti_join

List of manip options:
- filter
- select
- group_by
- mutate
- transmutate
- summarise
- arrange
- desange
- gather
- spread
- values
- modify

List of output options:
- x: terminal
- csv:
- rds

## Installation

Install `R >=3.4` , install the package [`m61r >=0.0.3`](https://cran.r-project.org/web/packages/m61r/) from `CRAN`.

Clone this repository and add rights to `m61r` shell file to be executable.
```shell
cd /tmp
git clone https://git.nilu.no/pv71u98h1/m61r-cli.git
cd m61r-cli
chmod +x m61r
```

## Limitations

Only work on linux with bash shell.


## Check-list. Completed: 7/12

### 1/12 -- With one file as input and manip: [OK]
```shell
./m61r --input "CO2.csv" # -> [OK]
```
```shell
./m61r --input "CO2.csv" --output x # -> [OK]
```
```shell
./m61r --input "CO2.csv" --output csv # -> [OK]
```
```shell
./m61r --input "CO2.csv" --manip filter --argument "~Type=='Quebec'" # -> [OK]
```
```shell
./m61r --input "CO2.csv" --manip filter --argument "~Type=='Quebec'" --output x # -> [OK]
```
```shell
./m61r --input "CO2.csv" --manip filter --argument "~conc==95" --output x # -> [OK]
```
```shell
./m61r --input "CO2.csv" --manip filter --argument "~conc>=300" --output x # -> [OK]
```
```shell
./m61r --input "CO2.csv" --manip select --argument "~Type" --output x # -> [OK]
```
```shell
./m61r --input "CO2.csv" --manip select --argument "~c(Plant,Type)" --output x # -> [OK]
```
```shell
./m61r --input "CO2.csv" --manip select --argument "~-Type" --output x # -> [OK]
```
```shell
./m61r --input "CO2.csv" --manip select --argument "~-(Plant:Treatment)" --output x # -> [OK]
```
```shell
./m61r --input "CO2.csv" --manip mutate --argument "z=~conc/uptake" --output x # -> [OK]
```
```shell
./m61r --input "CO2.csv" --manip arrange --argument "~c(conc)" --output x # -> [OK]
```
```shell
./m61r --input "CO2.csv" --manip arrange --argument "~c(Treatment,conc,uptake)" --output x # ->
```shell
[OK]
```
```shell
./m61r --input "CO2.csv" --manip desange --argument "~c(Treatment,conc,uptake)" --output x # ->
```shell
[OK]
```
### 2/12 -- With one file, manip and arguments of length >1 [OK]

```shell
./m61r --input "CO2.csv" --manip mutate --argument "z1=~uptake/conc" --argument "y=~conc/100" --output x # -> [OK]
```
```shell
./m61r --input "CO2.csv" --manip transmutate --argument "z2=~uptake/conc" --argument "y2=~conc/100" --output x # -> [OK]
```
```shell
./m61r --input "CO2.csv" --manip summarise --argument "mean=~mean(uptake)" --argument "sd=~sd(uptake)" --output x # -> [OK]
```
```shell
./m61r -i "CO2.csv" -m summarise -a "mean=~mean(uptake)" -a "sd=~sd(uptake)" -o x # -> [OK]
```
### 3/12 -- With input of length >1, and combine as rbind and cbind [OK]

```shell
./m61r --input "CO2.csv" --input "CO2b.csv" --output x # -> [OK]
```
```shell
./m61r --input "CO2.csv" --input "CO2b.csv" --combine rbind --output x # -> [OK]
```
```shell
./m61r --input "CO2.csv" --input "CO2.csv" --combine cbind --output x # -> [OK]
```
```shell
./m61r -i "CO2.csv" -i "CO2.csv" -c cbind -o x # -> [OK]
```
### 4/12 -- With join as combine [OK]

```shell
./m61r --input "books.csv" --input "authors.csv" -c left_join -p "by.x='name'" --param "by.y='surname'" --output x # -> [OK]
```
```shell
./m61r --input "books.csv" --input "authors.csv" -c inner_join -p "by.x='name'" --param "by.y='surname'" --output x # -> [OK]
```
```shell
./m61r --input "books.csv" --input "authors.csv" -c full_join -p "by.x='name'" --param "by.y='surname'" --output x # -> [OK]
```
```shell
./m61r --input "books.csv" --input "authors.csv" -c right_join -p "by.x='name'" --param "by.y='surname'" --output x # -> [OK]
```
```shell
./m61r --input "books.csv" --input "authors.csv" -c semi_join -p "by.x='name'" --param "by.y='surname'" --output x # -> [OK]
```
```shell
./m61r --input "books.csv" --input "authors.csv" -c anti_join -p "by.x='name'" --param "by.y='surname'" --output x # -> [OK]
```
```shell
./m61r -i "books.csv" -i "authors.csv" -c anti_join -p "by.x='name'" -p "by.y='surname'" -o x # -> [OK]
```
### 5/12 -- With pipe [OK]

```shell
./m61r --input "CO2.csv" | ./m61r --extra "CO2b.csv" --output x # -> [OK]
```
```shell
./m61r --input "CO2.csv" | ./m61r --manip filter --argument "~Type=='Quebec'" --output x # -> [OK]
```
```shell
./m61r --input "CO2.csv" --input "CO2b.csv" | ./m61r --manip filter --argument "~Treatment=='chilled'" --output x # -> [OK]
```
```shell
./m61r --input "CO2.csv" --manip group_by --argument "group=~c(Type,Treatment)" | ./m61r --manip summarise --argument "mean=~mean(uptake)" --argument "sd=~sd(uptake)" --output x # -> [OK]
```
```shell
./m61r --input "CO2.csv" --input "CO2b.csv" --manip group_by --argument "group=~c(Type,Treatment)" | ./m61r --manip summarise --argument "mean=~mean(uptake)" --argument "sd=~sd(uptake)" --output x # -> [OK]
```
```shell
./m61r -i "CO2.csv" -i "CO2b.csv" -m group_by -a "group=~c(Type,Treatment)" | ./m61r -m summarise -a "mean=~mean(uptake)" -a "sd=~sd(uptake)" -o x # -> [OK]
```
### 6/12 -- reshape [OK]

```shell
./m61r --input "df3.csv" --manip gather -a "pivot=c('id','age')" -o x # -> [OK]
```
```shell
./m61r --input "df5.csv" --manip spread -a "col_name='parameters'" -a "col_values='values'" -a "pivot=c('id','age')" -o x # -> [OK]
```
```shell
./m61r -i "df5.csv" -m spread -a "col_name='parameters'" -a "col_values='values'" -a "pivot=c('id','age')" -o x # -> [OK]
```
### 7/12 -- path as input [OK]

```shell
./m61r --input "~/tmp/m61r-cli/folder_test" -o x # -> [OK]
```
```shell
./m61r --input "~/tmp/m61r-cli/folder_test" -i "CO2b.csv" -o x # -> [OK]
```
```shell
./m61r --input "~/tmp/m61r-cli/folder_test" | ./m61r --extra "CO2b.csv" --output x # -> [OK]
```
```shell
./m61r -i "~/tmp/m61r-cli/folder_test" | ./m61r -e "CO2b.csv" -o x # -> [OK]
```
### 8/12 -- homegeneous code with '~' in join/reshape as done in filter/select [Not completed]
...

### 9/12 -- improve help: --help [Not completed]

```shell
$./m61r --help combine
```
```shell
$./m61r --help manip
```
### 10/12 -- manipulate cache [Not completed]
list and clear

examples:

```shell
$./m61r --cache list
```
>foo.rds  ./m61r --input "~/tmp/m61r-cli/folder_test" | ./m61r --extra "CO2b.csv" --output x

```shell
$./m61r --cache reset
```
### 11/12 -- multi-thread [Not completed]
...

### 12/12 -- distributed [Not completed]
...

## Inspirations
  - [awk](https://en.wikipedia.org/wiki/AWK) - text processing and typically used as a data extraction
  - [dplyr-cli](https://github.com/coolbutuseless/dplyr-cli) - r-based dplyr-cli
  - [miller](http://johnkerl.org/miller/doc/) - go-based dataframe manipulation
