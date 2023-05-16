function [model] = initModel(numOfSupplyCentre, dataFileName)
    data = load(['.\Data\' dataFileName]); 
    
    model.costOfUnitBuild = 1000;                                           % 
    model.costRetentionOfUnitTime = 0.02;                                   % 
    model.speed = 5;                                                        % 
    model.priceOfUnitKm = 1;                                                % 
    model.rateCostOfUnitCO2 = 0.3;                                              % 

    model.numOfCustomer = size(data, 1);                                    % 
    model.coordinateOfCustomer = data(:, 1: 2);                             % 
    model.demandOfCustomer = data(:, end);                                  % 
    model.numOfSupplyCentre = numOfSupplyCentre;                            %
    model.numOfDecVariables = numOfSupplyCentre * 2;                        % 
    [model.lower, model.upper] = getLowerAndUpper(model.coordinateOfCustomer, model.numOfDecVariables);     % 
    
    
    model.initIndividual = @initIndividual;                                 % 
	model.getIndividualFitness = @getIndividualFitness;                     % 
    model.showIndividual = @showIndividual;                                 % 
    model.zoomDec = @zoomDec;                                               % 
    model.repairIndividual = @repairIndividual;                             % 
    model.getDistanceOfCityMat = @getDistanceOfCityMat;
    model.printResult = @printResult;                                       % 
end

%% 
function [individual] = initIndividual(model)
	numOfDecVariables = model.numOfDecVariables;                            % 
    individual = rand(1, numOfDecVariables);
end

%% 
function [individualFitness] = getIndividualFitness(individual, model)
    numOfSupplyCentre = model.numOfSupplyCentre;                            % 
    coordinateOfCustomer = model.coordinateOfCustomer;                      % 
    
    X = zoomDec(individual, model);
    coordinateOfSupplyCentre = reshape(X, [numOfSupplyCentre, 2]);          % 
    [distanceOfCityMat] = getDistanceOfCityMat(coordinateOfSupplyCentre, coordinateOfCustomer);
    [minD, ~] = min(distanceOfCityMat, [], 2);
    allRouteDistance = sum(minD);
    
    [cost1] = getCost1(numOfSupplyCentre, model);                           % build cost
    [cost2] = getCost2(allRouteDistance, model);                            % costRetentionOfUnitTime
    [cost3] = getCost3(allRouteDistance, model);                            % cost for distance
    [cost4] = getCost4(allRouteDistance, model);                            % CO2
    
%     costTotal = sum(demandOfCustomer .* minD);
    individualFitness = - cost1 - cost2 - cost3 - cost4;
end

% print result
function printResult(individual, model)
    numOfSupplyCentre = model.numOfSupplyCentre;                            % 
    coordinateOfCustomer = model.coordinateOfCustomer;                      % 

    X = zoomDec(individual, model);
    coordinateOfSupplyCentre = reshape(X, [numOfSupplyCentre, 2]);          % 
    [distanceOfCityMat] = getDistanceOfCityMat(coordinateOfSupplyCentre, coordinateOfCustomer);
    [minD, ~] = min(distanceOfCityMat, [], 2);
    allRouteDistance = sum(minD);
    
    [cost1] = getCost1(numOfSupplyCentre, model);                           % 
    [cost2] = getCost2(allRouteDistance, model);                            % 
    [cost3] = getCost3(allRouteDistance, model);                            %
    [cost4] = getCost4(allRouteDistance, model);                            % CO2
    
%     costTotal = sum(demandOfCustomer .* minD);
    individualFitness = - cost1 - cost2 - cost3 - cost4;
    fprintf('buildcost:%.2f costRetentionOfUnitTime:%.2f distancecost:%.2f CO2:%.2f objective:%.2f\n',cost1, cost2, cost3, cost4, -individualFitness);
end

% build cost
function [cost1] = getCost1(numOfSupplyCentre, model)
    cost1 = numOfSupplyCentre * model.costOfUnitBuild;                      % 
end

% costRetentionOfUnitTime
function [cost2] = getCost2(distanceOfCityMat, model)
    demandOfCustomer = model.demandOfCustomer;                              % 
    [minD, ~] = min(distanceOfCityMat, [], 2);
    cost2 = sum(demandOfCustomer .* minD / model.speed * model.costRetentionOfUnitTime);	% 
end

% distance cost
function [cost3] = getCost3(allRouteDistance, model)
    cost3 = allRouteDistance * model.priceOfUnitKm;                         % 
end

% CO2
function [cost4] = getCost4(allRouteDistance, model)
    cost4 = allRouteDistance * model.rateCostOfUnitCO2;
end


%% Calculate the distance matrix between the delivery center and the customer
function [distanceOfCityMat] = getDistanceOfCityMat(coordinateOfSupplyCentre, coordinateOfCustomer)
    numOfSupplyCentre = size(coordinateOfSupplyCentre, 1);                 	% 
    numOfCustomer = size(coordinateOfCustomer, 1);                          % 
    distanceOfCityMat = zeros(numOfCustomer, numOfSupplyCentre);

    for i = 1 : numOfCustomer
        pointI = coordinateOfCustomer(i, :);                               	% 
        for j = 1 : numOfSupplyCentre
            pointJ = coordinateOfSupplyCentre(j, :);                       	% 
            distanceOfCityMat(i, j) = LpNorm(pointI, pointJ,2);             % 
        end
    end
end


%% 
function showIndividual(individual, model)
    numOfSupplyCentre = model.numOfSupplyCentre;                            % 
    coordinateOfCustomer = model.coordinateOfCustomer;                      % 
    
    X = zoomDec(individual, model);
    coordinateOfSupplyCentre = reshape(X, [numOfSupplyCentre, 2]);          % 
    [distanceOfCityMat] = getDistanceOfCityMat(coordinateOfSupplyCentre, coordinateOfCustomer);
    [~, I] = min(distanceOfCityMat, [], 2);
    hold on;
    grid on;
    plot(coordinateOfSupplyCentre(:, 1), coordinateOfSupplyCentre(:, 2), 'r*');
    plot(coordinateOfCustomer(:, 1), coordinateOfCustomer(:, 2), 'bo');
    for i = 1 : length(coordinateOfCustomer)
        X = [coordinateOfCustomer(i, 1); coordinateOfSupplyCentre(I(i), 1)];
        Y = [coordinateOfCustomer(i, 2); coordinateOfSupplyCentre(I(i), 2)];
        plot(X, Y, 'g-');
    end
    hold off;
end

%% 
function [lower, upper] = getLowerAndUpper(coordinateOfCustomer, numOfDecVariables)
    X = coordinateOfCustomer(:, 1);
    Y = coordinateOfCustomer(:, 2);
    xMin = min(X);
    xMax = max(X);
    yMin = min(Y);
    yMax = max(Y);
    
    temp = zeros(1, numOfDecVariables / 2);
    lower = [temp + xMin, temp + yMin];
    upper = [temp + xMax, temp + yMax];
end

%% 
function [X] = zoomDec(individual, model)
    lower = model.lower;
    upper = model.upper;
    X = individual .* (upper - lower) + lower;
end

%% 
function [newIndividual] = repairIndividual(individual, model)
    newIndividual = individual;
    for i = 1 : length(individual)
        if newIndividual(i) > 1
            newIndividual(i) = 1;
        elseif newIndividual(i) < 0
            newIndividual(i) = 0;
        end
    end
end
