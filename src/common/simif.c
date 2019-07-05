// Glue for detecting if we are running under the simulator

#include "common/simif.h"


// __rom
#define SIF_ADDRESS_SPACE_NAME	"rom"
#define SIF_ADDRESS_SPACE	
#define SIF_ADDRESS		0xffff

unsigned char SIF_ADDRESS_SPACE * volatile sif = (unsigned char SIF_ADDRESS_SPACE *) SIF_ADDRESS;

enum sif_command {
  DETECT_SIGN	        = '!',	// answer to detect command
  SIFCM_DETECT		= '_',	// command used to detect the interface
  SIFCM_COMMANDS	= 'i',	// get info about commands
  SIFCM_IFVER		= 'v',	// interface version
  SIFCM_SIMVER		= 'V',	// simulator version
  SIFCM_IFRESET		= '@',	// reset the interface
  SIFCM_CMDINFO		= 'I',	// info about a command
  SIFCM_CMDHELP		= 'h',	// help about a command
  SIFCM_STOP		= 's',	// stop simulation
  SIFCM_PRINT		= 'p',	// print character
  SIFCM_FIN_CHECK	= 'f',	// check input file for input
  SIFCM_READ		= 'r',	// read from input file
  SIFCM_WRITE		= 'w',	// write to output file
};

// Return true if we are running under a simulator
char simif_simulated(void)
{
  *sif= SIFCM_DETECT;
  return *sif == DETECT_SIGN;
}

// Print a string to the simulator console
void simif_print(const char *s)
{
  while (*s)
    {
      *sif= SIFCM_PRINT;
      *sif= *s++;
    }
}