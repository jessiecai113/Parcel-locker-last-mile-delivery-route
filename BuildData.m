numOfPoints = 400;                                                           % number of  point(PL/CL+customers)

coordinateOfPoints = rand(numOfPoints, 2) * (100 - 0) + 0;                  % Generate coordiante(PL/CL customers position)
demandOfPoints = rand(numOfPoints, 1) * (100 - 0) + 1;                      %Generate demand


%% save
fileName = sprintf('./data/mdvrpData%04d.txt', numOfPoints);
fid = fopen(fileName, 'w');
for i = 1 : numOfPoints
	fprintf(fid,'%.2f %.2f %.1f\n', coordinateOfPoints(i, 1), coordinateOfPoints(i, 2), demandOfPoints(i));
end
fclose(fid);