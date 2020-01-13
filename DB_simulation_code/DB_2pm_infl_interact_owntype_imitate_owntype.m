function result = DB_2pm_infl_interact_owntype_imitate_owntype(pm1, pm2, r, con_matrix, alpha, iter, N, p_ini, b)
% Two atrributes of users are considered: influence and preference.
% For influence, users can be classified into super user (with baseline
% fitness b1) and normal user (with baseline fitness b2).
% For prefrence, users can be classified into interested (preference1) or
% not interested (preference2).
% Thus, there are 4 types: [preference1 + baseline1, preference1 + baseline2, preferece2 + baseline1, preference2 + baseline2].
% Each user only interacts with the neighbors who have the same preference.
% They also imitate strategy from same type neighbors
% 2019.12.31
% Yuejiang Li
% ==========================
% inputs:
% pm1, pm2: two payoff matrices of the two corresponding types of users;
% r : 1*4 vectors, each repre. the percentages of corresponding types of users;
% con_matrix: adjacency list of the graph structure;
% alpha: selection intensity;
% iter: iteration rounds;
% N: total users numbers;
% p_ini: 1*4 vectors, indicating the initial Sf adopters within each types
% b: 1*2 vectors, the baseline fitness of super and normal users.
% --------------------------
% outputs
% result: 4*iter matrix, the simulation results
% ==========================

    uff1 = pm1.uff * alpha; uff2 = pm2.uff * alpha;
    ufn1 = pm1.ufn * alpha; ufn2 = pm2.ufn * alpha;
    unf1 = pm1.unf * alpha; unf2 = pm2.unf * alpha;
    unn1 = pm1.unn * alpha; unn2 = pm2.unn * alpha;
    
    % index interval for each type
    type1_start = 1; type1_end = round(N*r(1));
    type2_start = type1_end + 1; type2_end = type1_end + round(N*r(2));
    type3_start = type2_end + 1; type3_end = type2_end + round(N*r(3));
    type4_start = type3_end + 1; type4_end = N;
    type1Num = type1_end - type1_start + 1;
    type2Num = type2_end - type2_start + 1;
    type3Num = type3_end - type3_start + 1;
    type4Num = type4_end - type4_start + 1;
    
    action_table = zeros(1, N);
    result = zeros(4, iter);  % result is xf of users

    degree_table = single(sum(con_matrix ~= 0, 2).');  % calculate degree of each nodes
    baseline_table = zeros(1, N);
    baseline_table([type1_start:type1_end, type3_start:type3_end]) = b(1) * (1-alpha);
    baseline_table([type2_start:type2_end, type4_start:type4_end]) = b(2) * (1-alpha);
    
    % strategy Initialization
    ini1_user = randperm(type1Num, round(type1Num * p_ini(1)));
    ini2_user = type1_end + randperm(type2Num, round(type2Num * p_ini(2)));
    ini3_user = type2_end + randperm(type3Num, round(type3Num * p_ini(3)));
    ini4_user = type3_end + randperm(type4Num, round(type4Num * p_ini(4)));
    action_table([ini1_user ini2_user ini3_user ini4_user]) = 1;
    
    fit_table = zeros(1, N);  % recording each user's fitness
    for i = 1:N
        neigh_list = con_matrix(i, 1:degree_table(i));
        if i <= type2_end
            same_type_neigh = neigh_list(neigh_list <= type2_end);
        else
            same_type_neigh = neigh_list(neigh_list > type2_end);
        end
        str_same_neigh = action_table(same_type_neigh);
        sf_neigh_num = sum(str_same_neigh);  % count how many neighbors use sf
        sn_neigh_num = length(str_same_neigh) - sf_neigh_num;
        if action_table(i)
            if i <= type2_end
                fit_table(i) = baseline_table(i) + sf_neigh_num * uff1 + sn_neigh_num * ufn1;
            else
                fit_table(i) = baseline_table(i) + sf_neigh_num * uff2 + sn_neigh_num * ufn2;
            end
        else
            if i <= type2_end
                fit_table(i) = baseline_table(i) + sf_neigh_num * unf1 + sn_neigh_num * unn1;
            else
                fit_table(i) = baseline_table(i) + sf_neigh_num * unf2 + sn_neigh_num * unn2;
            end
        end
    end
    
    count = 1;
    result(1, count) = sum(action_table(type1_start: type1_end))/type1Num;
    result(2, count) = sum(action_table(type2_start: type2_end))/type2Num;
    result(3, count) = sum(action_table(type3_start: type3_end))/type3Num;
    result(4, count) = sum(action_table(type4_start: type4_end))/type4Num;
    count = count + 1;
    
    while count <= iter
        for p = 1:N
            i = randi(N);  % pick a central user
            friend_number = degree_table(i);  % find friends
            friend_list = con_matrix(i, 1:friend_number);
            if i <= type2_end
                same_type_friend = friend_list(friend_list <= type2_end);
            else
                same_type_friend = friend_list(friend_list > type2_end);
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
                    if i <= type2_end
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
                    if i <= type2_end
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
        result(1, count) = sum(action_table(type1_start: type1_end))/type1Num;
        result(2, count) = sum(action_table(type2_start: type2_end))/type2Num;
        result(3, count) = sum(action_table(type3_start: type3_end))/type3Num;
        result(4, count) = sum(action_table(type4_start: type4_end))/type4Num;
        count = count + 1;                  
    end
    
end