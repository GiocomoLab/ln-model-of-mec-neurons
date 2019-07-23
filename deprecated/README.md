# ln-model-of-mec-neurons
Code implements the LN model used to describe spike trains of MEC neurons based on the animal's position, head direction, speed, and theta phase information. Used in [Hardcastle et al., 2017.](http://www.cell.com/neuron/fulltext/S0896-6273(17)30237-4)

Run_me.m is the main script. This will load the data from a single cell, fit the 15 LN models (as described in Hardcastle et al., 2017), select the best model according to a forward search procedure, and then plot the results. Details for each step can be found in run_me.m, and the scripts listed within run_me.m. 

Questions can be directed to khardcas@stanford.edu
