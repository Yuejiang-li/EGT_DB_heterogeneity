function graph = sf_gen(n, m, seed)
% 2019.07.24
% This function is used to generate Barabasi-Albert scale-free network
% with preferential attachment algorithm.
% input
% n: total numbers of nodes
% m: the edges generated when each new node is added
% seed: the seed graph adjacency matrix for generating the whole network
% output
% graph: the adjacency matrix of BA scale free network
% liyuejiang

    [m0, ~] = size(seed);
    deg_tab = sum(seed);
    deg_tot = sum(deg_tab);
    if (m0 < m) || (m > n) || (m0 > n)
        error('Input parameters error!')
    else
        graph = zeros(n, n);
        graph(1:m0, 1:m0) = seed;
        c_num = m0 + 1;
        while c_num <= n
            pdf_tab = [deg_tab; 1 : c_num-1];
            for i = 1:m
                cdf_tab = cumsum(pdf_tab(1, :));
                cdf_tab = [0, cdf_tab / cdf_tab(end)];
                connect_idx = sum(rand >= cdf_tab);
                true_idx = pdf_tab(2, connect_idx);
                graph(c_num, true_idx) = 1;
                graph(true_idx, c_num) = 1;
                pdf_tab(:, connect_idx) = [];
            end
            deg_tot = deg_tot + 2*m;
            deg_tab = sum(graph(1: c_num, 1: c_num));
            c_num = c_num + 1;
        end
    end
end