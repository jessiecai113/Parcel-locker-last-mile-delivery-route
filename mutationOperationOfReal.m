function [newPopulation] = mutationOperationOfReal(population, stepSize, rateOfProgress)
% 
    stepSize = stepSize * (1 - rateOfProgress);
    populationSize= size(population, 1);
    newPopulation = zeros(size(population));
    for i = 1 : populationSize
        individual = population(i, :);
        newPopulation(i, :) = mutateIndividual(individual, stepSize, rateOfProgress);
    end

end

%% 
function [individual] = mutateIndividual(individual, stepSize, rateOfProgress)
    D = size(individual, 2);
    lower = -stepSize;
    upper = stepSize;
    
%     
    if rateOfProgress < 0.5
        r = rand(1, D);
        r = r .* (upper - lower) + lower;                       % 
    else
        r = zeros(1, D);
        mutationRate = 1 / D;
        for i = 1: D
            if rand() < mutationRate
                r(i) = rand() .* (upper - lower) + lower;       %     
            end
        end
    end
    
    individual = individual + r;
    for i = 1 : D
        if individual(i) > 1
            individual(i) = 1;
%             
        elseif individual(i) < 0
            individual(i) = 0;
        end
    end
end
