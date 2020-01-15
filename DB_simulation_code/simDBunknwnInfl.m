function result = simDBunknwnInfl(pm1, pm2, r, con_matrix, alpha, iterate_time, N, p_ini, b)
% simulation code for users with two attribute: preference and influence
% each user can know whether a neighbor is influenctial but don't know his
% preference
% =========== input =============
% pm1, pm2: payoff matrices for two types of preference
% r: 1*4 ratio table [preference1+baseline1, preference1+baseline2, prefenrece2+baseline1, preference2+baseline2]
% con_matrix: adjacency list of graph
% alpha: slecetion intensity
% iteration_time: iteration_times
% N: total user number
% p_ini: 1*4 initial Sf adopter ratio table of the corresponding four types
% b: 1*2 baseline fitness table of two types
% =========== output =============
% result: 4*iteration_time matrix of pf evolution
% ================================
% 2019.12.04
% liyuejiang

    uff1 = pm1.uff * alpha; uff2 = pm2.uff * alpha;
    ufn1 = pm1.ufn * alpha; ufn2 = pm2.ufn * alpha;
    unn1 = pm1.unn * alpha; unn2 = pm2.unn * alpha;
    b = b * (1 - alpha);
    
    action_table = zeros(1, N);
    result = zeros(4, iterate_time);  % result is xf of users
    
    % start and end of each type of users
    type1_start = 1; type1_end = round(r(1)*N);
    type2_start = type1_end + 1; type2_end = type2_start + round(r(2)*N) - 1;
    type3_start = type2_end + 1; type3_end = type3_start + round(r(3)*N) - 1;
    type4_start = type3_end + 1; type4_end = N;
    type1Num = type1_end - type1_start + 1;
    type2Num = type2_end - type2_start + 1;
    type3Num = type3_end - type3_start + 1;
    type4Num = type4_end - type4_start + 1;
    
    degree_table = single(sum(con_matrix ~= 0, 2).');  % calculate degree of each nodes
    baseline_table = zeros(1, N);
    baseline_table([type1_start:type1_end type3_start:type3_end]) = b(1);
    baseline_table([type2_start:type2_end type4_start:type4_end]) = b(2);
    
    % strategy initialization
    ini1_user = randperm(type1Num, round(type1Num * p_ini(1)));
    ini2_user = type2_start - 1 + randperm(type2Num, round(type2Num * p_ini(2)));
    ini3_user = type3_start - 1 + randperm(type3Num, round(type3Num * p_ini(3)));
    ini4_user = type4_start - 1 + randperm(type4Num, round(type4Num * p_ini(4)));
    action_table([ini1_user ini2_user ini3_user ini4_user]) = 1;
    
    fit_table = zeros(2, N);  % 2 rows repre. fitness from different type neighbors.
    for i = 1:N
        neigh_list = con_matrix(i, 1:degree_table(i));
        str_neigh = action_table(neigh_list);
        sf_neigh_num = sum(str_neigh); % count how many neighbors use sf
        if action_table(i)
            fit_table(1, i) = baseline_table(i) + sf_neigh_num * uff1 + (degree_table(i) - sf_neigh_num) * ufn1;
            fit_table(2, i) = baseline_table(i) + sf_neigh_num * uff2 + (degree_table(i) - sf_neigh_num) * ufn2;
        else
            fit_table(1, i) = baseline_table(i) + sf_neigh_num * ufn1 + (degree_table(i) - sf_neigh_num) * unn1;
            fit_table(2, i) = baseline_table(i) + sf_neigh_num * ufn2 + (degree_table(i) - sf_neigh_num) * unn2;
        end
    end
    
    count = 1;
    result(1, count) = sum(action_table(type1_start: type1_end))/type1Num;
    result(2, count) = sum(action_table(type2_start: type2_end))/type2Num;
    result(3, count) = sum(action_table(type3_start: type3_end))/type3Num;
    result(4, count) = sum(action_table(type4_start: type4_end))/type4Num;
    count = count + 1;
    
    % begin DB update rule
    while count <= iterate_time
        for p = 1:N
            i = randi(N);  % pick a central user
            friend_number = degree_table(i);  % find friends
            friend_list = con_matrix(i, 1:friend_number);
            fit_f = 0;
            fit_n = 0;
            if i <= type2_end  % choose a user with preference 1 as focal user
                for j = friend_list
                    if action_table(j)
                        fit_f = fit_f + fit_table(1, j);
                    else
                        fit_n = fit_n + fit_table(1, j);
                    end
                end
            else  % choose a user with preference 2 as focal user
                for j = friend_list
                    if action_table(j)
                        fit_f = fit_f + fit_table(2, j);
                    else
                        fit_n = fit_n + fit_table(2, j);
                    end
                end
            end
            
            if action_table(i) == 1  % strategy update
                judge = fit_n/(fit_f + fit_n);
                if rand <= judge
                    action_table(i) = 0;
                    for j = friend_list  % update correlated fitness
                        if action_table(j)
                            fit_table(1, i) = fit_table(1, i) + ufn1 - uff1;
                            fit_table(2, i) = fit_table(2, i) + ufn2 - uff2;
                            fit_table(1, j) = fit_table(1, j) + ufn1 - uff1;
                            fit_table(2, j) = fit_table(2, j) + ufn2 - uff2;
                        else
                            fit_table(1, i) = fit_table(1, i) + unn1 - ufn1;
                            fit_table(2, i) = fit_table(2, i) + unn2 - ufn2;
                            fit_table(1, j) = fit_table(1, j) + unn1 - ufn1;
                            fit_table(2, j) = fit_table(2, j) + unn2 - ufn2;
                        end
                    end
                end
            else
                judge = fit_f/(fit_f + fit_n);
                if rand <= judge
                    action_table(i) = 1;
                    for j = friend_list
                        if action_table(j)
                            fit_table(1, i) = fit_table(1, i) + uff1 - ufn1;
                            fit_table(2, i) = fit_table(2, i) + uff2 - ufn2;
                            fit_table(1, j) = fit_table(1, j) + uff1 - ufn1;
                            fit_table(2, j) = fit_table(2, j) + uff2 - ufn2;
                        else
                            fit_table(1, i) = fit_table(1, i) + ufn1 - unn1;
                            fit_table(2, i) = fit_table(2, i) + ufn2 - unn2;
                            fit_table(1, j) = fit_table(1, j) + ufn1 - unn1;
                            fit_table(2, j) = fit_table(2, j) + ufn2 - unn2;
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