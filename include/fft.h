// #include "sfp.hh"

#define EXP 4
#define MANT 4
#define SFPW 9


void FFT_1D(unsigned *input_real , unsigned *input_imag , unsigned *output_real , unsigned *output_imag , int length);

void FFT_1D_Double(double *input_real , double *input_imag , double *output_real , double *output_imag , int length);


void FFT_1D_SIZE4(unsigned *input_real, unsigned *input_imag, unsigned *output_real, unsigned *output_imag, int length);