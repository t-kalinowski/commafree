# commafree

<!-- badges: start -->

<!-- badges: end -->

{commafree} is an R package that provides the "comma-free call" operator:
`%(%`. Use it to call a function with arguments, but without commas
separating the arguments. Just replace the `(` with `%(%` in a function
call, supply your arguments as standard R expressions enclosed by `{ }` and
be free of commas (for that call).

It is especially useful for long multi-line function calls with many
arguments, like a shiny UI definition, an R6 class definition, or
similar.

`%(%` merely does a syntax transformation, so that a call like this:

``` r
func %(% {
  a
  b
  c
}
```

is equivalent to writing this:

``` r
func(
  a,
  b,
  c
)
```

## Installation

You can install {commafree} like so:

``` r
install.packages("commafree")
## Install the dev version:
# remotes::install_github("t-kalinowski/commafree")
```

## Example

``` r
library(commafree)

writeLines(c %(% {
  "I write, erase, rewrite"
  "Erase again, and then"
  "A poppy blooms."
})
```

    I write, erase, rewrite
    Erase again, and then
    A poppy blooms.

Haiku by Katsushika Hokusai
