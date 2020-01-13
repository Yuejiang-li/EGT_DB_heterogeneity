import networkx as nx
import numpy as np
import numpy.random as rd
import multiprocessing
import os
import copy


def graph_matrix2list(g):
    '''
    function for changing graph from matrix form to adjacency list form
    :param g: networkx-form graph
    :return: graph_list: N*N nparray each row indicates the neighbors of row index, others are filled with zero
    '''
    N = len(g)
    graph_list = np.zeros((N, N))
    for i in g.node:
        l = 0
        for j in g[i]:
            graph_list[i, l] = j
            l += 1
    return graph_list

def simDB(uff, ufn, unn, iteration, b, p_ini, alpha, g_ori):
    '''
    Simple DB one time simulation
    '''
    g_list = graph_matrix2list(g_ori)
    g = copy.deepcopy(g_ori)
    N = len(g_ori)
    uff = uff * alpha
    ufn = ufn * alpha
    unn = unn * alpha

    # strategy initialization
    p_ini_idx = rd.permutation(N)[:round(N * p_ini)]
    baseline_table = b * (1 - alpha) * np.ones(N)
    fit_table = baseline_table.copy()
    deg_table = np.zeros(N)
    for i in g_ori.degree:
        deg_table[i[0]] = i[1]

    act_table = np.zeros(N)
    act_table[p_ini_idx] = 1

    # calculate each user's fitness
    for i in range(N):
        if act_table[i] == 1:
            for neighbor in g_ori[i]:
                if act_table[neighbor] == 1:
                    fit_table[i] += uff
                else:
                    fit_table[i] += ufn
        else:
            for neighbor in g_ori[i]:
                if act_table[neighbor] == 1:
                    fit_table[i] += ufn
                else:
                    fit_table[i] += unn

    result = np.zeros(iteration)
    itnum = 0
    result[itnum] = act_table.sum() / N
    itnum += 1
    while itnum < iteration:
        focal_table = rd.randint(N, size=N)
        for focal in focal_table:
            fit_f = 0
            fit_n = 0
            if act_table[focal] == 1:  # focal user use Sf
                for neighbor in g_ori[focal]:
                    if act_table[neighbor] == 0:  # neighbor use Sn
                        fit_n += fit_table[neighbor]
                    else:  # neighbor use Sf
                        fit_f += fit_table[neighbor]
                if rd.rand() < fit_n / (fit_f + fit_n):  # change strategy
                    act_table[focal] = 0
                    for neighbor in g_ori[focal]:  # fitness update
                        if act_table[neighbor] == 0:
                            fit_table[focal] += unn - ufn
                            fit_table[neighbor] += unn - ufn
                        else:
                            fit_table[focal] += ufn - uff
                            fit_table[neighbor] += ufn - uff
            else:  # focal user use Sn
                for neighbor in g_ori[focal]:
                    if act_table[neighbor] == 0:  # neighbor use Sn
                        fit_n += fit_table[neighbor]
                    else:  # neighbor use Sf
                        fit_f += fit_table[neighbor]
                if rd.rand() < fit_f / (fit_f + fit_n):
                    act_table[focal] = 1
                    for neighbor in g_ori[focal]:  # fitness update
                        if act_table[neighbor] == 0:
                            fit_table[focal] += ufn - unn
                            fit_table[neighbor] += ufn - unn
                        else:
                            fit_table[focal] += uff - ufn
                            fit_table[neighbor] += uff - ufn

        result[itnum] = act_table.sum() / N
        itnum += 1
    return result




def simDB_control(uff, ufn, unn, iteration, b, p_ini, alpha, graph_type, graph_params, rand_graph_num, sim_num):
    '''
    repeated simulation for simDB control script
    :param uff:
    :param ufn:
    :param unn:
    :param iteration:
    :param b:
    :param p_ini:
    :param alpha:
    :param g:
    :return:
    '''
    core_num = os.cpu_count() // 2
    pool = multiprocessing.Pool(processes=core_num)  # core number

    if graph_type == 'regular':
        N = graph_params[0]
        k = graph_params[1]
        graph_gen_params = [(k, N)] * rand_graph_num
        gen_g = (pool.starmap_async(nx.random_regular_graph, graph_gen_params)).get()
    elif graph_type == 'scale-free':
        pass
    else:
        pass

    graph_mean = np.zeros((rand_graph_num, iteration))
    for i in range(rand_graph_num):
        sim_params = [(uff, ufn, unn, iteration, b, p_ini, alpha, gen_g[i])] * sim_num
        sim_results = np.array(pool.starmap_async(simDB, sim_params).get())
        graph_mean[i, :] = sim_results.mean(axis=0)

    mean_result = graph_mean.mean(axis=0)
    pool.close()
    pool.join()

    return mean_result
