function result = DB_2pm_interact_owntype(pm1, pm2, r, con_matrix, alpha, iter, N, p_ini, b)
% two types of users with different payoff matrix, and they only interact
% with their own types of neighbors.
% 2019.12.31
% Yuejiang Li
% ==========================
% inputs:
% pm1, pm2: two payoff matrices of the two corresponding types of users;
% r : 1*2 vectors the percentage of two types of users;
% con_matrix: adjacency list of the graph structure;
% alpha: selection intensity;
% iter: iteration rounds;
% N: total users numbers;
% p_ini: 1*2 vectors, indicating the initial Sf adopters within each types
% --------------------------
% outputs
% result: 2*iter matrix, the simulation results
% ==========================
    uff1 = pm1.uff * alpha; uff2 = pm2.uff * alpha;
    ufn1 = pm1.ufn * alpha; ufn2 = pm2.ufn * alpha;
    unf1 = pm1.unf * alpha; unf2 = pm2.unf * alpha;
    unn1 = pm1.unn * alpha; unn2 = pm2.unn * alpha;
    b = b * (1 - alpha);
    
    action_table = zeros(1, N);
    result = zeros(2, iter);  % result is xf of users

    degree_table = single(sum(con_matrix ~= 0, 2).');  % calculate degree of each nodes
    baseline_table = b * ones(1, N);
    
    % assign type
    type1Num = round(N * r(1));
    type2Num = N - type1Num;
    
    % strategy Initialization
    ini1_user = randperm(type1Num, round(type1Num * p_ini(1)));
    ini2_user = type1Num + randperm(type2Num, round(type2Num * p_ini(2)));
    action_table([ini1_user ini2_user]) = 1;
    
    fit_table = zeros(1, N);  % recording each user's fitness
    for i = 1:N
        neigh_list = con_matrix(i, 1:degree_table(i));
        if i <= type1Num
            same_type_neigh = neigh_list(neigh_list <= type1Num);
        else
            same_type_neigh = neigh_list(neigh_list > type1Num);
        end
        str_same_neigh = action_table(same_type_neigh);
        sf_neigh_num = sum(str_same_neigh);  % count how many neighbors use sf
        sn_neigh_num = length(sf_neigh_num) - sf_neigh_num;
        if action_table(i)
            if i <= type1Num
                fit_table(i) = baseline_table(i) + sf_neigh_num * uff1 + sn_neigh_num * ufn1;
            else
                fit_table(i) = baseline_table(i) + sf_neigh_num * uff2 + sn_neigh_num * ufn2;
            end
        else
            if i <= type1Num
                fit_table(i) = baseline_table(i) + sf_neigh_num * unf1 + sn_neigh_num * unn1;
            else
                fit_table(i) = baseline_table(i) + sf_neigh_num * unf2 + sn_neigh_num * unn2;
            end
        end
    end
    
    count = 1;
    result(1, count) = sum(action_table(1: type1Num))/type1Num;
    result(2, count) = sum(action_table(type1Num+1: end))/type2Num;
    count = count + 1;
    
    while count <= iter
        for p = 1:N
            i = randi(N);  % pick a central user
            friend_number = degree_table(i);  % find friends
            friend_list = con_matrix(i, 1:friend_number);
            if i <= type1Num
                same_type_friend = friend_list(friend_list <= type1Num);
            else
                same_type_friend = friend_list(friend_list > type1Num);
            end
            fit_f = 0;
            fit_n = 0;
            for j = same_type_friend
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
                    if i <= type1Num
                        for j = same_type_friend
                            if action_table(j)
                                fit_table(i) = fit_table(i) + unf1 - uff1;
                                fit_table(j) = fit_table(j) + ufn1 - uff1;
                            else
                                fit_table(i) = fit_table(i) + unn1 - ufn1;
                                fit_table(j) = fit_table(j) + unn1 - unf1;
                            end
                        end
                    else
                        for j = same_type_friend
                            if action_table(j)
                                fit_table(i) = fit_table(i) + unf2 - uff2;
                                fit_table(j) = fit_table(j) + ufn2 - uff2;
                            else
                                fit_table(i) = fit_table(i) + unn2 - ufn2;
                                fit_table(j) = fit_table(j) + unn2 - unf2;
                            end
                        end
                    end
                end
            else
                judge = fit_f/(fit_f + fit_n);
                if rand <= judge
                    action_table(i) = 1;
                    if i <= type1Num
                        for j = same_type_friend
                            if action_table(j)
                                fit_table(i) = fit_table(i) + uff1 - unf1;
                                fit_table(j) = fit_table(j) + uff1 - ufn1;
                            else
                                fit_table(i) = fit_table(i) + ufn1 - unn1;
                                fit_table(j) = fit_table(j) + unf1 - unn1;
                            end
                        end
                    else
                        for j = same_type_friend
                            if action_table(j)
                                fit_table(i) = fit_table(i) + uff2 - unf2;
                                fit_table(j) = fit_table(j) + uff2 - ufn2;
                            else
                                fit_table(i) = fit_table(i) + ufn2 - unn2;
                                fit_table(j) = fit_table(j) + unf2 - unn2;
                            end
                        end
                    end
                end
                
            end
        end
        result(1, count) = sum(action_table(1: type1Num))/type1Num;
        result(2, count) = sum(action_table(type1Num+1: end))/type2Num;
        count = count + 1;
    end
    
end