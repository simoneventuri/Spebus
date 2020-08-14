# Training the NN:

##	1 - Change the following variables in ./NNInput.py
		- PathToSPES
		- PathToSPESOutput
	
		NOTE: PathToDataFldr must contain:
			- EOrig.csv (1  column  of energy data points)
			- R.csv     (nr columns of atom-atom distances data points (nr=3 for 3 atoms; nr=6 for 4 atoms))

##	2 - Execute the ./Main.py file and check the training process via "tensorboard dev upload --logdir CheckpointFldr (see NNInput.py for retrieving the value of the CheckpointFldr variable)
	
##	3 - The trained parameters can be found in PathToOutputFldr (see NNInput.py for retrieving the value of the PathToOutputFldr variable)

##	4 - For further postprocessing:
		
##		5 - Execute the Spebus/PESConstruction/Postprocessing/Exec/MSpebus_NN.m MATALB file

			NOTE: The Input.TrainingFldr in MSpebus_NN.m must be the same as PathToDataFldr   specified in NNInput.py
				  The Input.ParamsFldr   in MSpebus_NN.m must be the same as PathToOutputFldr specified in NNInput.py
				  The Input.TestingFldr  in MSpebus_NN.m must contain the output of CoarseAIR's PlotPES program for all the angles specified as Input.ThreeD.AngVec

##		6 - Open ParaView and Load the 3DPlots_MATLAB folder contained in PathToOutputFldr