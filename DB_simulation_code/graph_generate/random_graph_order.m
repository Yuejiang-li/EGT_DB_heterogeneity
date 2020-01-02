function graph = random_graph_order(graph_A)
%   2019.05.27
%    parameter:
%    graph_A is the input graph adjacent list
    [n, ~] = size(graph_A);
    graph = zeros(n, n, 'single');
%    random the order of the users;
%   this is especially convenient for the SF graph
    new_order = randperm(n);
%     ori_order = zero(1, n);
%     for i = 1:n
%         ori_order(new_order(i)) = i;
%     end
    for i = 1:n
        l = 1;
        while graph_A(i, l) ~= 0
            graph(new_order(i), l) = new_order(graph_A(i, l));
            l = l +1;
        end
    end
end