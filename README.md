# SubCorticalBeats-model
Identifies beat timing and musical tempo based on simulated sub-cortical neural activity.

This suite of programs can be used to simulate subcortical neural activity in response to sounds and identify the frequency and timing of musical beats.  The programs are referred to in:
> Zuk, N.J., Carney, L.H., and Lalor, E.C. (under review), Assessing musical beat perception using simulated sub-cortical neural activity. *Front Neurosci*

Sub-cortical neural activity is simulated using a cascade of two models: A model of cochlear and auditory nerve fiber processing, which was most recently updated in:
> Zilany, M.S.A., Bruce, I.C., and Carney, L.H. (2014), Updated parameters and expanded simulation options for a model of the auditory periphery. *JASA* 135(1):283-286
and a model of synaptic processing in the ventral cochlear nucleus and inferior colliculus, originally from:
> Nelson, P.C., and Carney, L.H. (2004), A phenomenological model of peripheral and central neural responses to amplitude-modulated tones. *JASA* 116:2173-2186
Both models can be found in the [UR Ear](https://www.urmc.rochester.edu/MediaLibraries/URMCMedia/labs/carney-lab/codes/UR_Ear_v1_0.zip) toolbox.  **These models must be downloaded first before SubCorticalBeats-model can be used**.
