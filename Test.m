dataFileName = 'mdvrpData0050.txt';
data = load(['.\Data\' dataFileName]);                                      % 

% numOfPoints = size(data, 1);
model.numOfCustomer = size(data, 1);                                 % 
model.coordinateOfCustomer = data(:, 1: 2);                          % 
model.demandOfCustomer = data(:, end);                               % 