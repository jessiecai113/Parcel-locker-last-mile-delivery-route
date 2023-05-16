

%%
clear;                                                                      % 
close all;                                                                  % 
clc;                                                                        % 
%% 
addpath(genpath('.\'));                                                     % 
% rand('state', 0);
populationSize = 100;                                                      	% 
maxGeneration = 200;                                                      	% 
crossoverRate = 0.6;                                                        % 
mutationRate = 0.1;                                                         %
stepSize = 0.1;                                                          	% 

numOfSupplyCentre = 20;                                                      % 
dataFileName = 'mdvrpData0400.txt';
[model] = initModel(numOfSupplyCentre, dataFileName);

%% 
population = initialPopulation(populationSize, model);                      % 
popFitness = getFitness(population, model);                                 % 
numOfDecVariables = size(population, 2);                                    % 

bestIndividualSet = zeros(maxGeneration, numOfDecVariables);                % 
bestFitnessSet = zeros(maxGeneration, 1);                                   % 
avgFitnessSet = zeros(maxGeneration, 1);                                    % 

%% 
for i = 1 : maxGeneration
    rateOfProgress = 1 / maxGeneration;
    newPopulation = selectionOperationOfTournament(population, popFitness);	% 
    newPopulation = crossoverOperation(newPopulation, crossoverRate);	% 
    newPopulation = mutationOperationOfReal(newPopulation, stepSize, rateOfProgress);   % 
    newPopFitness = getFitness(newPopulation, model);                       % 
    [population, popFitness] = eliteStrategy(population, popFitness, newPopulation, newPopFitness, 2); % 
 
    
    [bestIndividual, bestFitness, avgFitness] = getBestIndividualAndFitness(population, popFitness);
    bestIndividualSet(i, :) = bestIndividual;                               % 
    bestFitnessSet(i) = bestFitness;                                        % 
    avgFitnessSet(i) = avgFitness;                                          % 
     fprintf('The %ith optimal value£º%.3f\n', i, -bestFitness);
   
    if mod(i, 200) == 0                                                     % 
        close all;
        subplot(1,2,1);
        showIndividual(bestIndividual, model);                                 % 
        subplot(1,2,2);
        showEvolCurve(1, i, -bestFitnessSet, -avgFitnessSet);                 % 
        model.printResult(bestIndividual, model);
    end
end









