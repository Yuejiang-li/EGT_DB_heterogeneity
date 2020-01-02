function mean_result = DBsim_CtrlScrpt(pm, N, k, alpha, iter, p_ini, b, g_type, varargin)
% =========================
% DB update rule simulation code
% inputs:
% pm: the payoff matrix of the game;
% N: size of the network;
% k: average degree of the network;
% alpha: selection intensity;
% iter: iteration times;
% p_ini: initial percentage of Sf adopters;
% b: the baseline fitness of users;
% g_type: social network types, currently including 'regular', 'scale-free' and 'custom'
% argin: if gtype == 'custom' then the adjacent matrix of the customized
% graph should given as an input arguement.
% -------------------------
% outputs:
% mean_result: the averaged results of all simulation runs.
% =========================
%   2019.12.27
%   liyuejiang
    tic
    rand_graph_num = 5;
    sim_run_num = 48;
    result_all = zeros(sim_run_num, iter, rand_graph_num, 'single');  % 3-d matrices to record every simulation results
    graph_all = zeros(N, N, rand_graph_num, 'single');
    uff = pm.uff; ufn = pm.ufn; unf = pm.unf; unn = pm.unn;
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
    
    for i = 1:rand_graph_num
        i
        graph = graph_all(:, :, i);
        parfor j = 1: sim_run_num
            result_all(j,:,i) = DBsim(uff, ufn, unf, unn, graph, alpha, iter, N, p_ini, b);
        end
    end
    
    mean_graph_result = mean(result_all, 3);  % Expectation calculation w.r.t graph
    mean_result = mean(mean_graph_result);  % Expectation calcaulation w.r.t simulation run
    toc
end