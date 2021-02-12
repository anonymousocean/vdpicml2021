# Installation 
Install the haskell tool stack. For generic Linux systems, the installation instructions can be found [here](https://docs.haskellstack.org/en/stable/install_and_upgrade/#linux)


## Run on a single VDP puzzle with no timeout

> stack build
> stack exec icml21-exe 0 path/to/puzzle

## Run on all puzzles in a directory with 60s timeout

> stack build
> stack exec icml21-exe 1 path/to/puzzle/dir

In particular, to run on the same data included in Table from the
paper:

> stack build
> stack exec icml21-exe 1 path/to/naturalscenes_ir

This should yield output similar to the included "output.txt" file,
which logged the run for the data included in Table 2 of our ICML
submission.

# Notes

The bottom-up solver is not designed to solve VDP puzzles per se. It
takes a set of labelled models and a grammar, and searches for a
separator in the grammar. We can reduce from VDP to this setting by
fixing a grammar and running the solver once for each choice of target
image. If a particular choice of target is wrong and there is no
separator, then (for large grammars) it can take very long to exhaust
the search space. Thus we run the solver for each possible choice of
target image concurrently, and return the first solution found, or
wait until all runs fail to find a solution. This models the intuition
that humans are unlikely to fix an order in which to search; instead
it seems likely that a more sporadic search is conducted.

The solver works by iteratively building larger formulas from smaller
formulas. It is essentially a brute force search in the grammar, with
one exception. It avoids all formulas which do not effectively use
their connectives. For instance, a conjunction of formulas phi1 and
phi2 should strictly decrease the number of viable variable
assignments over the constituent formulas. Similar considerations
govern exploration of the other connectives. This acts as a
surprisingly good filter on formulas which need not be considered. For
instance, on the "allcatsonsofas_1" puzzle with combinator "close
(base \/ base)" and *without* progress, a separator is found in ~1000
seconds (Exists x1 Forall x0 (sofa(x0) \/ within(x0,x1))). With
progress, the same separator is found in 80 seconds.
