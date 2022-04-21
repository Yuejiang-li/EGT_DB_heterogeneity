"""
基于图演化博弈的动力学过程控制.

基本模型: 给定网络结构, 用户根据图演化博弈的DB规则来更新决策 (即是否参与案件), 
最终演化达到稳定状态

控制策略: (政府)控制个别节点的策略恒定为0 (即永远不参与案件). 在能够控制的节点
数量有限的情况下, 应当选取哪些节点? 本方案采用贪婪策略, 逐个选取节点, 使得稳定
状态的值最小

"""

import numpy as np
import numpy as np
import matplotlib.pyplot as plt
import networkx as nx
from functools import partial
import multiprocessing


def simDBWithControl(payoff, adj_list, str_init, con_nodes,
    num_iter, alpha):
    """
    带有受控节点的DB决策更新仿真函数.
    
    @params:
        payoff (Tuple)            : 四元组, 包含了uAA, uAB, uBA, uBB四个博弈矩阵中的参数
        adj_list (Dict[int:List]) : 节点->邻居列表的邻接表
        str_init (np.array)       : 所有用户的初始策略. shape=(N)
        con_nodes (List)          : 所选择的被控节点的编号
        num_iter (int)            : 仿真的迭代次数
        alpha (float)             : 选择系数

    @return:
        percent_A (np.array)      : 每一时刻选取策略A (参与案件的人) 的比例. shape=(num_iter)
    """
    uAA, uAB, uBA, uBB = payoff
    uAA, uAB, uBA, uBB = alpha * uAA, alpha * uAB, alpha * uBA, alpha * uBB
    N = len(adj_list)
    fitness_list = (1 - alpha) * np.ones(N)   # 基准健康值baseline fitness = 1.0
    action_list = np.copy(str_init)

    # 初始计算所有用户的fitness值
    for i in range(N):
        neighbors = adj_list[i]
        # print(neighbors)
        # print(action_list)
        # print(action_list[neighbors])
        num_neighbors_A = np.sum(action_list[neighbors])
        num_neighbors_B = len(neighbors) - num_neighbors_A
        if action_list[i] == 1:
            fitness_list[i] += uAA * num_neighbors_A + uAB * num_neighbors_B
        else:
            fitness_list[i] += uBA * num_neighbors_A + uBB * num_neighbors_B

    percent_A = np.zeros(num_iter)
    it = 0

    while it < num_iter:
        percent_A[it] = 1.0 * np.sum(action_list) / N
        it += 1

        # 一轮DB规则的更新
        # 1. 选择一个中心用户
        focal = np.random.randint(N)    
        if focal in con_nodes:
            continue
        else:
            # 2. 计算中心用户的A, B两种策略邻居用户的fitness value总和
            neighbors = adj_list[focal]
            neighbors_A = neighbors[action_list[neighbors] == 1]
            neighbors_B = neighbors[action_list[neighbors] == 0]
            neighbor_fit_A = np.sum(fitness_list[neighbors_A])
            neighbor_fit_B = np.sum(fitness_list[neighbors_B])

            # 3. 策略调整
            if action_list[focal] == 1:
                threshold = neighbor_fit_B / (neighbor_fit_A + neighbor_fit_B)
                if np.random.rand() < threshold:
                    # focal用户本来是A，结果变成了B策略，造成了它和周围邻居fitness value的变化
                    action_list[focal] = 0
                    fitness_list[focal] = fitness_list[focal] + len(neighbors_A) * (uBA - uAA) + len(neighbors_B) * (uBB - uAB)
                    fitness_list[neighbors_A] = fitness_list[neighbors_A] + (uAB - uAA)
                    fitness_list[neighbors_B] = fitness_list[neighbors_B] + (uBB - uBA)
            else:
                threshold = neighbor_fit_A / (neighbor_fit_A + neighbor_fit_B)
                if np.random.rand() < threshold:
                    # focal用户本来是B，结果变成了A策略，造成了它和周围邻居fitness value的变化
                    action_list[focal] = 1
                    fitness_list[focal] = fitness_list[focal] + len(neighbors_A) * (uAA - uBA) + len(neighbors_B) * (uAB - uBB)
                    fitness_list[neighbors_A] = fitness_list[neighbors_A] + (uAA - uAB)
                    fitness_list[neighbors_B] = fitness_list[neighbors_B] + (uBA - uBB)

    return percent_A


def repeatSimu(payoff, adj_list, str_init, con_nodes,
    num_iter, alpha, repeat_num, pool=None):
    """Repeat the simulation."""
    mean_res = np.zeros(num_iter)
    if pool is None:
        for i in range(repeat_num):
            mean_res += simDBWithControl(payoff, adj_list, str_init, con_nodes, num_iter, alpha) * 1.0 / repeat_num
    else:
        alpha_list = [alpha for _ in range(repeat_num)]
        parfunc = partial(simDBWithControl, payoff, adj_list, str_init, con_nodes, num_iter)
        pool = multiprocessing.Pool(4)
        res = pool.map(parfunc, alpha_list)
        pool.close()
        pool.join()
        for r in res:
            mean_res = mean_res + r / repeat_num

    return mean_res


if __name__ == "__main__":
    payoff = 0.6, 0.8, 0.8, 0.4
    G = nx.gnp_random_graph(100, 0.2)
    adj_mat = nx.to_numpy_array(G)
    adj_list = dict()
    for i in range(adj_mat.shape[0]):
        adj_list[i] = (np.where(adj_mat[i] == 1))[0]

    str_init = np.random.binomial(1, 0.5, (100,))
    con_nodes = []
    num_iters = 3000
    alpha = 0.99

    mean_res = repeatSimu(payoff, adj_list, str_init, con_nodes, num_iters, alpha, 50)
