# SubCorticalBeats-model
Identifies beat timing and musical tempo based on simulated sub-cortical neural activity.

This suite of programs can be used to simulate subcortical neural activity in response to sounds and identify the frequency and timing of musical beats.  The programs are referred to in:

> Zuk, N.J., Carney, L.H., and Lalor, E.C. (2018) Preferred tempo and low-audio-frequency bias emerge from simultaed sub-cortical processing of sounds with a musical beat. *Front Neurosci* 12:349. doi: [10.3389/fnins.2018.00349](https://www.frontiersin.org/articles/10.3389/fnins.2018.00349/full)

Sub-cortical neural activity is simulated using a cascade of two models: A model of cochlear and auditory nerve fiber processing, which was most recently updated in:

> Zilany, M.S.A., Bruce, I.C., and Carney, L.H. (2014), Updated parameters and expanded simulation options for a model of the auditory periphery. *J Acoust Soc Am* 135(1):283-286.

and a model of synaptic processing in the ventral cochlear nucleus and inferior colliculus, originally from:

> Nelson, P.C., and Carney, L.H. (2004), A phenomenological model of peripheral and central neural responses to amplitude-modulated tones. *J Acoust Soc Am* 116:2173-2186.

Both models can be found in the [UR Ear](https://www.urmc.rochester.edu/MediaLibraries/URMCMedia/labs/carney-lab/codes/UR_Ear_v1_0.zip) toolbox.  **These models must be downloaded and added to the Matlab path before SubCorticalBeats-model can be used**.

To use these programs, you should add the directory and subdirectories to your Matlab path.

*The code in this git repository is currently provided as is at the time of the publication of the manuscript.  I plan to create a set of programs to demo how the functions can be used.  Several of the main programs that ran the simulations (WavRhy.m for example) had parameters set in batch scripts that executed the programs. Some of the variables that are commented out need to be set in Matlab or in a batch script that executes the function. (NZ, 5/2018)*