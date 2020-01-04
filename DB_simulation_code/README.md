# 仿真代码

在独立运行代码之前，请先运行 ‘setup.m’ 来添加一些必要代码的路径

## 代码说明

### payoff matrix 的封装

For the clearance of code, we encode the payoff matrix as a "struct" variable with "wrapPayoff" function, e.g.:

```matlab
uff = 0.8; ufn = 0.6; unf = 0.6; unn = 0.4
pm = wrapPayoff(uff, ufn, unf, unn);
```

Here `pm` is the packed payoff matrix.



### 人工网络结构的产生

Up to now, we provide three types of synthetic network generation code. The corresponding three graph structures are *random regular network*, *ER random network* and *BA scale free network*.

- random regular network

  random regular network requires 2 parameters: total nodes number ($N$) and the degree ($k$). The corresponding generation code is `createRandRegGraph`. For example, generate a random regular network with $N=1000$ nodes, and degree $k=10$ .

  ```  
  g = createRandRegGraph(1000, 10)
  ```

  The output `g` is the **adjacency matrix** of the graph in sparse matrix form. one can use `full` to transform it into a full matrix form. 

- ER random network

  ...

- BA scale free network

  ...

For the convenience of using in the following simulation code, we can transform the graph from **adjacency matrix** form into **adjacency list** form with `graph_change`. e.g.:

```
g = graph_change(full(createRandRegGraph(1000, 10)))
```



### Simulation Code

Simulation code in different scenarios are provided

- DBsim.m: simulation code for pure DB update rule over homogeneous networks. The details can be founded in this code.
- DB_2pm_interact_owntype: simulation code for the scenario, where only 2 types of users with different payoff matrix exist. Each user only imitate his/her same-type neighbor's strategy.

### Simulation Control Script Code

Usually, the simulation need to be repeated several times under the same settings (which is often called *Monte-Carlo* method). Then, the mean-field results are drown through averaging the simulation results. 

Here, we provide simulation control script code to repeat the corresponding simulation with the same settings, and obtain the mean result.

- DBsim_CtrlScrpt.m: control script for `DBsim.m`
- DB_2pm_interact_owntype_ctrlScrpt: control script for `DB_2pm_interact_owntype.m`

