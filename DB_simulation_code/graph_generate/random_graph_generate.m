function gen_graph = random_graph_generate(N, k)
%     we use this code to randomly generate the different types of graphs.
%     For each type of graph, we generate 1000 samples to use.
    graph_num = 1000;
    gen_graph = zeros(N, N, graph_num);
% ----------------------regular graph----------------------------------
%     for kk = 1:graph_num
%         kk
%         graph_sample = createRandRegGraph(N, k);
%         graph_sample = graph_change(graph_sample);
%         gen_graph(:, :, kk) = graph_sample;
%     end
% ---------------------------------------------------------------------
% ---------------------------sf graph----------------------------------
    seed = seed_produce(k + 1);
    for kk = 1:graph_num
        kk
        graph_sample = sf_gen(N, k/2, seed);
        graph_sample = graph_change(graph_sample);
        gen_graph(:, :, kk) = graph_sample;
    end
% ---------------------------------------------------------------------
% ---------------------------er graph----------------------------------
%     for kk = 1:graph_num
%         kk
%         graph_sample = ERRandomGraphGenerate(N, k);
%         graph_sample = graph_change(graph_sample);
%         gen_graph(:, :, kk) = graph_sample;
%     end
% ---------------------------------------------------------------------
    gen_graph = single(gen_graph);
end