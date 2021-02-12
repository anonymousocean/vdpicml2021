# vdpicml2021
Supplementary material for submission to ICML 2021.
This readme is divided into X sections.
1. Understanding the output of `vdpsolve.py`
1. Installation


## Understanding the output of `vdpsolve.py`

Lets take the example of the following puzzle:
![clevr-sample.png](clevr-sample.png)

The solver yields the following concept for this puzzle.
```plaintext
   "Exists q0: sphere!0. Exists q1: sphere!1. And(same_color!0!1 same_color!1!0)"
```
This concept can be interpreted as:
```plaintext
   "Exists x: sphere. Exists y: sphere. And(same_color(x, y), same_color(y, x))"
```

## Installation
Installation instructions are presented below.
1. Clone this repository.
    ```bash
    $ git clone https://github.com/anonymousocean/vdpicml2021.git
    ```
2. Go into the project directory and install the requirements for the solver.
    ```bash
    $ pip install -r requirements.txt
    ```
3. To run the symbolic solver on a particular IR use the following command
    ```bash
     $ python scripts/vdpsolve.py
    ```
