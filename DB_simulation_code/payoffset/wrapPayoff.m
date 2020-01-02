function payoff = wrapPayoff(uff, ufn, unf, unn)
% wrap the payoff values as a struct var.
% Inputs are four payoff values
    payoff = struct();
    payoff.uff = uff;
    payoff.ufn = ufn;
    payoff.unf = unf;
    payoff.unn = unn;
end
