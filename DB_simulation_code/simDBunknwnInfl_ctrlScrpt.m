function mean_result = simDBunknwnInfl_ctrlScrpt(pm1, pm2, r, N, k, alpha, iteration_time, p_ini, b, g_type, varargin)

    tic
    rand_graph_num = 5;
    sim_run_num = 144;
%     result_all = zeros(sim_run_num, iteration_time, rand_graph_num, 'single');  % 3-d matrices to record every simulation results
    graph_all = zeros(N, N, rand_graph_num, 'single');
    result_all = cell(1, rand_graph_num);
    switch g_type  % choose graph type
        case 'regular'  % random regular network
            parfor i = 1:rand_graph_num
                graph_sample = full(createRandRegGraph(N, k));
                graph_all(:, :, i) = random_graph_order(graph_change(graph_sample));
            end
        case 'scale-free'  % scale-free network
            seed = seed_produce(k+1);
            parfor i = 1:rand_graph_num
                graph_sample = sf_gen(N, k/2, seed);
                graph_all(:, :, i) = random_graph_order(graph_change(graph_sample));
            end
        otherwise  % a customized network input is an adjacency matrix
            net = varargin{1, 1};
            for i = 1:rand_graph_num
                graph_all(:, :, i) = random_graph_order(graph_change(net));
            end
    end
    
    temp2 = zeros(4, iteration_time);
    for i = 1:rand_graph_num
        i
        graph = graph_all(:, :, i);
        graph_result = cell(1, sim_run_num);
        parfor j = 1: sim_run_num
            graph_result{1, j} = simDBunknwnInfl(pm1, pm2, r, graph, alpha, iteration_time, N, p_ini, b);
        end
        temp = graph_result{1, 1};
        for j = 2:sim_run_num
            temp = temp + graph_result{1, j};
        end
        result_all{1, i} = temp/sim_run_num;
        temp2 = temp2 + result_all{1, i};
    end
    
    mean_result = temp2/rand_graph_num;
%     mean_graph_result = mean(result_all, 3);  % Expectation calculation w.r.t graph
%     mean_result = mean(mean_graph_result);  % Expectation calcaulation w.r.t simulation run
    toc
end