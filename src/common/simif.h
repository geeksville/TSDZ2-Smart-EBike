#pragma once 

// Return true if we are running under a simulator
char simif_simulated(void);

// Print a string to the simulator console
void simif_print(const char *s);