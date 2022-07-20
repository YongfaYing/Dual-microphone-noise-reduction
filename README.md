# Dual-microphone-noise-reduction
Speech noise reduction method applied to dual microphones.


## Description of the directory structure

  ### GCC-PHAT
  
  - **gcc_apply.m** 
  
      Code actually used by GCC-PHAT method using binaural audio.
  - **gcc_simulation.m** 
  
      The GCC-PHAT method predicts the simulation code of the sound source direction by setting the sound source position and the microphone position simulation time delay.
  - **gcc_simulation_vis.m**
  
      Visualization code for gcc_simulation.m.
      
  ### gcc_lcmv.m
  Combining GCC-PHAT sound source localization with LCMV beamforming method and obtain after-gain audio.
  
  


