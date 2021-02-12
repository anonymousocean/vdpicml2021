# vdpicml2021
Supplementary material for submission to ICML 2021.



## Directory Structure

```plaintext
.
├── bottom_up_solver
├── clevr-sample.png
├── data
├── README.md
└── satbasedsolver
```

The directory consists of:
+ The main SAT-based solver in the `satbasedsolver/` subdirectory
+ The solver used for ablating the Guarded Conjunctive Fragment in `bottom_up_solver/`
+ The First-Order models corresponding to puzzles in the Natural Scenes Dataset in `data/yolo_ir`
+ First-Order models for puzzles in the Synthetic CLEVR Dataset in `data/clevr_ir`

After following the installation instructions corresponding to either solver, one can call the solver(s) 
by giving the path of any puzzle folder in `data/yolo_ir` or `data/clevr_ir`. Each puzzle folder has a `train` and 
`test` subdirectory containing the FO models corresponding to the training and candidatate images (respectively) in JSON format.

The datasets and the results of our tool can be browsed at: [https://anonymousocean.github.io/](https://anonymousocean.github.io/)

