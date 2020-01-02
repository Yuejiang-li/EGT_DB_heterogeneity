function result = DBsim(pm, con_matrix, alpha, iter, N, p_ini, b)
% The most orginal simulation code for DB update rule
% 2020.01.02
% Yuejiang_li
% =========================
% inputs
% pm: a struct variable representing payoff matrix value
% con_matrix: adjacency list of the given network structure
% alpha: the selection intensity
% iter: iteration numbers
% N: total user number
% p_ini: the initial percentage of Sf adopters
% b: baseline fitness of all users
% -------------------------
% outputs
% result: 1*iter vector, the simulation results
% =========================
    
	
    uff = pm.uff;
    ufn = pm.ufn;
    unf = pm.unf;
    unn = pm.unn;
    b = b * (1 - alpha);
    
    action_table = zeros(1, N);
    result = zeros(1, iter);  % result is xf of users

    degree_table = single(sum(con_matrix ~= 0, 2).');  % calculate degree of each nodes
    baseline_table = b * ones(1, N);
    
    % strategy Initialization
    ini_user = randperm(N, round(N * p_ini));
    action_table(ini_user) = 1;
    
    fit_table = zeros(1, N);  % fit_table: recording each user's fitness.
    for i = 1:N
        neigh_list = con_matrix(i, 1:degree_table(i));
        str_neigh = action_table(neigh_list);
        sf_neigh_num = sum(str_neigh); % count how many neighbors use sf
        if action_table(i)
            fit_table(i) = baseline_table(i) + sf_neigh_num * uff + (degree_table(i) - sf_neigh_num) * ufn;
        else
            fit_table(i) = baseline_table(i) + sf_neigh_num * unf + (degree_table(i) - sf_neigh_num) * unn;
        end
    end
    
    count = 1;
    result(count) = sum(action_table)/N;
    count = count + 1;
    
    % begin DB update rule
    while count <= iter
        for p = 1:N
            i = randi(N);  % pick a central user
            friend_number = degree_table(i);  % find friends
            friend_list = con_matrix(i, 1:friend_number);
            fit_f = 0;
            fit_n = 0;
            for j = friend_list
                if action_table(j)
                    fit_f = fit_f + fit_table(j);
                else
                    fit_n = fit_n + fit_table(j);
                end
            end
            
            if action_table(i) == 1  % strategy update
                judge = fit_n/(fit_f + fit_n);
                if rand <= judge
                    action_table(i) = 0;
                    for j = friend_list  % update correlated fitness
                        if action_table(j)
                            fit_table(i) = fit_table(i) + unf - uff;
                            fit_table(j) = fit_table(j) + ufn - uff;
                        else
                            fit_table(i) = fit_table(i) + unn - ufn;
                            fit_table(j) = fit_table(j) + unn - unf;
                        end
                    end
                end
            else
                judge = fit_f/(fit_f + fit_n);
                if rand <= judge
                    action_table(i) = 1;
                    for j = friend_list
                        if action_table(j)
                            fit_table(i) = fit_table(i) + uff - unf;
                            fit_table(j) = fit_table(j) + uff - ufn;
                        else
                            fit_table(i) = fit_table(i) + ufn - unn;
                            fit_table(j) = fit_table(j) + unf - unn;
                        end
                    end
                end
            end
            
        end
        result(count) = sum(action_table)/N;
        count = count + 1;
    end
    
end