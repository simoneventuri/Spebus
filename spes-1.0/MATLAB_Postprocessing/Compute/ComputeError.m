function [RMSE, MUE] = ComputeError(NPointss, Rangee, EData, EPred)
  
  NData = size(EData,1);

  MUE=zeros(5,1);
  RMSE=zeros(5,1);
  for iData = 1:NData
    MUE(Rangee(iData))  = MUE(Rangee(iData))  + abs(EPred(iData)-EData(iData));
    RMSE(Rangee(iData)) = RMSE(Rangee(iData)) + (EPred(iData)-EData(iData)).^2;
  end
  MUE  = MUE       ./ NData;
  RMSE = sqrt(RMSE ./ NData);
  
end