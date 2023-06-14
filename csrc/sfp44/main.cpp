#include "sfp.hh"
// #include "pack.h"
#include <cstdio>
#include <iostream>
#include <ctime>
#include <cstdlib>
#include <iomanip>
using std::cout;
using std::endl;


#define num 32
int main(int argc, char *argv[])
{
//   auto p = SFP(3, 3);
//   for (unsigned i = 0; i < (unsigned)(1 << p.nBits()); i++) {
//       p.setBits(i);
//       p.print();
//   }

    SFP p[4] = {SFP(exponent,mantissa) , SFP(exponent,mantissa) , SFP(exponent,mantissa) , SFP(exponent,mantissa)};
    double input_real[num] = {7.015881e-04, 5.247174e-04, 2.195105e-04, 5.136553e-05, 6.723181e-06, 4.922258e-07, 2.015768e-08, 4.617462e-10, 5.916333e-12, 4.240221e-14, 1.699851e-16, 3.811711e-19, 4.780966e-22, 3.354269e-25, 1.316336e-28, 2.889495e-32, 3.547839e-36, 2.889495e-32, 1.316336e-28, 3.354269e-25, 4.780966e-22, 3.811711e-19, 1.699851e-16, 4.240221e-14, 5.916333e-12, 4.617462e-10, 2.015768e-08, 4.922258e-07, 6.723181e-06, 5.136553e-05, 2.195105e-04, 5.247174e-04};
    double input_imag[num] = {0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000,0.000000};

    double output_real[num][num];
    double output_imag[num][num];
    int length;
    length = sizeof(input_real) / sizeof(double);


    std::srand(std::time(nullptr));
    double array_real[num][num];
    double array_imag[num][num];
    for (int i = 0; i < num; ++i) {
        for (int j = 0; j < num; ++j) {
            array_real[i][j] = std::rand() % 8;  // 生成 0 到 99 之间的随机数
        }
    }

    for (int i = 0; i < num; ++i) {
        for (int j = 0; j < num; ++j) {
            array_imag[i][j] = std::rand() % 8;
        }
    }

    for (int i = 0; i < num; ++i) {
        FFT_1D_Double(array_real[i] , array_imag[i] , output_real[i] , output_imag[i] , num);
    }
    cout<<endl<<endl<<"output:"<<endl<<endl;

    for (int i = 0; i < num; ++i) {
        for (int j = 0; j < num; ++j) {
            cout << std::hex << std::setw(3) << std::setfill('0') << (p[0].set(output_real[i][j])).getBits()<<"  ";
        }
        cout << "  ";
        for (int j = 0; j < num; ++j) {
            cout << std::hex << std::setw(3) << std::setfill('0') << (p[0].set(output_imag[i][j])).getBits()<<"  ";
        }
        cout << endl;
    }
    




    return 0;
}
