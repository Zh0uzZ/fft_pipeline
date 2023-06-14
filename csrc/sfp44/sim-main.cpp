#include "sfp.hh"
#include "pack.h"
#include <cstdio>
#include <iostream>
#include <sstream>
#include <ctime>
#include <cstdlib>
#include <iomanip>

#include <verilated.h>
#include <verilated_vcd_c.h>
#include <verilated_dpi.h>

#include "Vfft_2d.h"
#include "Vfft_2d___024root.h"
#include "debug.h"


using std::cout;
using std::endl;

VerilatedContext* contextp = new VerilatedContext;
Vfft_2d* top = new Vfft_2d{contextp};
// Vfft_2d___024root* root = new Vfft_2d___024root{contextp};
VerilatedVcdC* m_trace = new VerilatedVcdC;

#define num 32

int sim_time = 0;

int array_label[8] = {0,4,1,5,2,6,3,7};

void printFixedWidthDouble(double number) {
    int width = 7;
    std::stringstream ss;
    ss << std::fixed << std::setprecision(2) << number;

    std::string formattedNumber = ss.str();
    int padding = width - formattedNumber.length();  // 计算需要补充的空格数量
    std::cout << std::setw(width) << std::setfill(' ') << formattedNumber << "  ";
}

void printRTLlable(double* mdc_real , double* mdc_imag , double * output_real , double* output_imag) {
    double difference;
    int lable;
    for(int j = 0; j < 4; j++) {
      difference = 20;
      lable = 0;
      for(int i = 0; i < num; i++) {
        if(difference > (abs(mdc_real[j]-output_real[i]) + abs(mdc_imag[j]-output_imag[i]))){
            lable = i;
            difference = (abs(mdc_real[j]-output_real[i]) + abs(mdc_imag[j]-output_imag[i]));
        }
      }
      cout <<std::dec<< lable << "    " << difference <<"    ";
      }
      cout<<endl;
}


int main(int argc, char *argv[])
{
    SFP p[4] = {SFP(EXP,MANT) , SFP(EXP,MANT) , SFP(EXP,MANT) , SFP(EXP,MANT)};

    double output_real[num][num];
    double output_imag[num][num];
    int length;
    std::srand(std::time(nullptr));
    double array_real[num][num];
    double array_imag[num][num];
    for (int i = 0; i < num; ++i) {
        for (int j = 0; j < num; ++j) {
            // array_real[i][j] = std::rand() % 8;  // 生成 0 到 99 之间的随机数
            // array_imag[i][j] = std::rand() % 8;
            if(j>15)
                array_real[i][j] = 1;  // 生成 0 到 99 之间的随机数
            else
                array_real[i][j] = 0;
            array_imag[i][j] = 0;
        }
    }

    for (int i = 0; i < num; ++i) {
        printmdcinput(array_real[i] , array_imag[i] , num);
    }
    for (int i = 0; i < num; ++i) {
        FFT_1D_Double(array_real[i] , array_imag[i] , output_real[i] , output_imag[i] , num);
    }


    cout<<endl<<endl<<"output stage1:"<<endl<<endl;
    for (int i = 0; i < num; ++i) {
        for (int j = 0; j < 16; ++j) {
            cout << std::hex << std::setw(3) << std::setfill('0') << (p[0].set(output_real[i][j])).getBits()<<"  ";
            if(j == 7) {cout<<"  ";}
        }
        cout << endl;
        for (int j = 0; j < 16; ++j) {
            cout << std::hex << std::setw(3) << std::setfill('0') << (p[0].set(output_imag[i][j])).getBits()<<"  ";
            if(j == 7) {cout<<"  ";}
        }
        cout << endl;
        for (int j = 16; j < 32; ++j) {
            cout << std::hex << std::setw(3) << std::setfill('0') << (p[0].set(output_real[i][j])).getBits()<<"  ";
            if(j == 23) {cout<<"  ";}
        }
        cout << endl;
        for (int j = 16; j < 32; ++j) {
            cout << std::hex << std::setw(3) << std::setfill('0') << (p[0].set(output_imag[i][j])).getBits()<<"  ";
            if(j == 23) {cout<<"  ";}
        }
        cout << endl<<endl;
    }

//     for (int i = 0; i < num; ++i) {
//         for (int j = 0; j < num; ++j) {
//             array_real[i][j] = output_real[j][i];
//             array_imag[i][j] = output_imag[j][i];
//         }
//     }
//     for (int i = 0; i < num; ++i) {
//         FFT_1D_Double(array_real[i] , array_imag[i] , output_real[i] , output_imag[i] , num);
//     }


// //print c code result
//     cout<<endl<<endl<<"output stage2:"<<endl<<endl;
//     for (int i = 0; i < num; ++i) {
//         for (int j = 0; j < 16; ++j) {
//             cout << std::hex << std::setw(3) << std::setfill('0') << (p[0].set(output_real[i][j])).getBits()<<"  ";
//             if(j == 7) {cout<<"  ";}
//         }
//         cout << endl;
//         for (int j = 0; j < 16; ++j) {
//             cout << std::hex << std::setw(3) << std::setfill('0') << (p[0].set(output_imag[i][j])).getBits()<<"  ";
//             if(j == 7) {cout<<"  ";}
//         }
//         cout << endl;
//         for (int j = 16; j < 32; ++j) {
//             cout << std::hex << std::setw(3) << std::setfill('0') << (p[0].set(output_real[i][j])).getBits()<<"  ";
//             if(j == 23) {cout<<"  ";}
//         }
//         cout << endl;
//         for (int j = 16; j < 32; ++j) {
//             cout << std::hex << std::setw(3) << std::setfill('0') << (p[0].set(output_imag[i][j])).getBits()<<"  ";
//             if(j == 23) {cout<<"  ";}
//         }
//         cout << endl<<endl;
//     }
    // cout << std::dec;
    cout<<"c program output double:" << endl;
    for(int i = 0; i < 32; i++){
        for(int j = 0; j < 32; j++) {
            // cout<<output_real[i][j]<<"  ";
            printf("%.2f  " , output_real[i][j]);
        }
        cout << "    ";
        for(int j = 0; j < 32; j++) {
            // cout<<output_imag[i][j]<<"  ";
            printf("%.2f  " , output_imag[i][j]);
        }
        cout << endl;
    }


//start verilator
    int column = 0;
    int row = 0;
    int mdc_count = 0;
    unsigned long int merged_data = 0;
    unsigned long int input_real [4];
    unsigned long int input_imag [4];

    unsigned mdc_real_stage1 [32][32];
    unsigned mdc_imag_stage1 [32][32];

    // enable trace, save vcd file to build/main.vcd
    enable_trace_to("build/main.vcd");
    init();

    cout<<"simulation :" << endl;
    sim_time = contextp->time();
    while(sim_time < 5300) {
        sim_time = contextp->time();
        if(sim_time <37){
            top->start_i = 1;

        } else {
            top->start_i = 0;
            for(int m=0;m < 4;m++){
                input_real[m] = uint64_t((p[0].set(array_real[row][column+8*m])).getBits());
                input_imag[m] = uint64_t((p[0].set(array_imag[row][column+8*m])).getBits());
            }
            merged_data =(input_real[0]<<SFPW*3 | input_real[1]<<SFPW*2 | input_real[2]<<SFPW | input_real[3]);
            top->dr_i = merged_data;
            merged_data =(input_imag[0]<<SFPW*3 | input_imag[1]<<SFPW*2 | input_imag[2]<<SFPW | input_imag[3]);
            top->di_i = merged_data;

// printf input real and imag
            if(0) {
            cout <<"input real : " ;
            for(int m = 0; m < 4; m++) {
                cout << std::hex << std::setw(3) << std::setfill('0') << input_real[m]<<"  ";
            }
            cout<< std::hex << std::setw(9) << std::setfill('0') <<top->dr_i<<" | ";
            cout <<"input imag : " ;
            for(int m = 0; m < 4; m++) {
                cout << std::hex << std::setw(3) << std::setfill('0') << input_imag[m]<<"  ";
            }
            cout<< std::hex << std::setw(9) << std::setfill('0') <<top->di_i<<"  "<<endl; }
// printf input real and imag

            column+=1;
            if(column==8){
                column = 0;
                row += 1;
            }
        }
        if(top->rootp->fft_2d__DOT__stage2) {
            // contextp->timeInc(1);
            // cout << top->dr_mdc_o << endl << top->di_mdc_o<<endl;
            mdc_real_stage1[mdc_count/8][array_label[mdc_count%8] + 8*0] =  top->dr_mdc_o >>SFPW*3;
            mdc_real_stage1[mdc_count/8][array_label[mdc_count%8] + 8*1] = (top->dr_mdc_o >>SFPW*2)& 0x1FF;
            mdc_real_stage1[mdc_count/8][array_label[mdc_count%8] + 8*2] = (top->dr_mdc_o >>SFPW*1)& 0x1ff;
            mdc_real_stage1[mdc_count/8][array_label[mdc_count%8] + 8*3] = (top->dr_mdc_o >>SFPW*0)& 0x1ff;


            mdc_imag_stage1[mdc_count/8][array_label[mdc_count%8] + 8*0] =  top->di_mdc_o >>SFPW*3;
            mdc_imag_stage1[mdc_count/8][array_label[mdc_count%8] + 8*1] = (top->di_mdc_o >>SFPW*2)& 0x1FF;
            mdc_imag_stage1[mdc_count/8][array_label[mdc_count%8] + 8*2] = (top->di_mdc_o >>SFPW*1)& 0x1ff;
            mdc_imag_stage1[mdc_count/8][array_label[mdc_count%8] + 8*3] = (top->di_mdc_o >>SFPW*0)& 0x1ff;

            // cout << mdc_count<<endl;

            // printFixedWidthDouble((p[0].setBits(mdc_real_stage1[mdc_count/8][array_label[mdc_count%8] + 8*0])).getDouble());
            // printFixedWidthDouble((p[0].setBits(mdc_real_stage1[mdc_count/8][array_label[mdc_count%8] + 8*1])).getDouble());
            // printFixedWidthDouble((p[0].setBits(mdc_real_stage1[mdc_count/8][array_label[mdc_count%8] + 8*2])).getDouble());
            // printFixedWidthDouble((p[0].setBits(mdc_real_stage1[mdc_count/8][array_label[mdc_count%8] + 8*3])).getDouble());
            // cout<<"    ";
            // printFixedWidthDouble((p[0].setBits(mdc_imag_stage1[mdc_count/8][array_label[mdc_count%8] + 8*0])).getDouble());
            // printFixedWidthDouble((p[0].setBits(mdc_imag_stage1[mdc_count/8][array_label[mdc_count%8] + 8*1])).getDouble());
            // printFixedWidthDouble((p[0].setBits(mdc_imag_stage1[mdc_count/8][array_label[mdc_count%8] + 8*2])).getDouble());
            // printFixedWidthDouble((p[0].setBits(mdc_imag_stage1[mdc_count/8][array_label[mdc_count%8] + 8*3])).getDouble());
            // cout<<endl;

            double mdc_real_double[4];
            double mdc_imag_double[4];
            for(int m = 0; m < 4; m++) {
                mdc_real_double[m] = (p[0].setBits(mdc_real_stage1[mdc_count/8][array_label[mdc_count%8] + 8*m])).getDouble();
                mdc_imag_double[m] = (p[0].setBits(mdc_imag_stage1[mdc_count/8][array_label[mdc_count%8] + 8*m])).getDouble();
            }
            // double mdc_real_double[4] = {, (p[1].setBits(mdc_real_stage1[mdc_count/8][array_label[mdc_count%8] + 8*1])).getDouble() , (p[2].setBits(mdc_real_stage1[mdc_count/8][array_label[mdc_count%8] + 8*2])).getDouble() , (p[3].setBits(mdc_real_stage1[mdc_count/8][array_label[mdc_count%8] + 8*3])).getDouble()};
            // double mdc_imag_double[4] = {(p[0].setBits(mdc_imag_stage1[mdc_count/8][array_label[mdc_count%8] + 8*0])).getDouble() , (p[1].setBits(mdc_imag_stage1[mdc_count/8][array_label[mdc_count%8] + 8*1])).getDouble() , (p[2].setBits(mdc_imag_stage1[mdc_count/8][array_label[mdc_count%8] + 8*2])).getDouble() , (p[3].setBits(mdc_imag_stage1[mdc_count/8][array_label[mdc_count%8] + 8*3])).getDouble()};
            // printRTLlable(mdc_real_double , mdc_imag_double , output_real[j] , output_imag[j]);
            mdc_count ++;
        }

        event_record(10);
        // cout <<top->dr_o<<endl;
        // cout <<top->di_o<<endl;
    }
    finish();
    cout<<"mdc output:"<<endl<<endl;
    for (int i = 0; i < num; ++i) {
        for (int j = 0; j < num; ++j) {
            cout <<  (p[0].setBits(mdc_real_stage1[i][j])).getDouble() <<"  ";
        }
        cout << "  ";
        for (int j = 0; j < num; ++j) {
            cout <<  (p[1].setBits(mdc_imag_stage1[i][j])).getDouble() <<"  ";
        }
        cout << endl;
    }
    cout<<"mdc output:"<<endl<<endl;
    for (int i = 0; i < num; ++i) {
        for (int j = 0; j < 16; ++j) {
            cout << std::hex << std::setw(3) << std::setfill('0') << mdc_real_stage1[i][j] <<"  ";
            if(j == 7) {cout<<"  ";}
        }
        cout << endl;
        for (int j = 0; j < 16; ++j) {
            cout << std::hex << std::setw(3) << std::setfill('0') << mdc_imag_stage1[i][j] <<"  ";
            if(j == 7) {cout<<"  ";}
        }
        cout << endl;
        for (int j = 16; j < 32; ++j) {
            cout << std::hex << std::setw(3) << std::setfill('0') << mdc_real_stage1[i][j] <<"  ";
            if(j == 23) {cout<<"  ";}
        }
        cout << endl;
        for (int j = 16; j < 32; ++j) {
            cout << std::hex << std::setw(3) << std::setfill('0') << mdc_imag_stage1[i][j] <<"  ";
            if(j == 23) {cout<<"  ";}
        }
        cout << endl<<endl;
    }

    cout<<"difference:"<<endl<<endl;
    for (int i = 0; i < num; ++i) {
        for (int j = 0; j < 16; ++j) {
            cout << std::dec<< int((p[0].set(output_real[i][j])).getBits() - mdc_real_stage1[i][j]) <<"  ";
            if(j == 7) {cout<<"  ";}
        }
        cout << endl;
        for (int j = 0; j < 16; ++j) {
            cout << std::dec<< int((p[0].set(output_imag[i][j])).getBits() - mdc_imag_stage1[i][j]) <<"  ";
            if(j == 7) {cout<<"  ";}
        }
        cout << endl;
        for (int j = 16; j < 32; ++j) {
            cout << std::dec<< int((p[0].set(output_real[i][j])).getBits() - mdc_real_stage1[i][j]) <<"  ";
            if(j == 23) {cout<<"  ";}
        }
        cout << endl;
        for (int j = 16; j < 32; ++j) {
            cout << std::dec<< int((p[0].set(output_imag[i][j])).getBits() - mdc_imag_stage1[i][j]) <<"  ";
            if(j == 23) {cout<<"  ";}
        }
        cout << endl<<endl;
    }



    cout<<"difference:"<<endl<<endl;
    for (int i = 0; i < num; ++i) {
        for (int j = 0; j < 16; ++j) {
            cout <<(output_real[i][j] - (p[0].setBits(mdc_real_stage1[i][j])).getDouble()) <<"  ";
            if(j == 7) {cout<<"  ";}
        }
        cout << endl;
        for (int j = 0; j < 16; ++j) {
            cout <<(output_imag[i][j] - (p[0].setBits(mdc_imag_stage1[i][j])).getDouble()) <<"  ";
            if(j == 7) {cout<<"  ";}
        }
        cout << endl;
        for (int j = 16; j < 32; ++j) {
            cout <<(output_real[i][j] - (p[0].setBits(mdc_real_stage1[i][j])).getDouble())<<"  ";
            if(j == 23) {cout<<"  ";}
        }
        cout << endl;
        for (int j = 16; j < 32; ++j) {
            cout << (output_imag[i][j] - (p[0].setBits(mdc_imag_stage1[i][j])).getDouble()) <<"  ";
            if(j == 23) {cout<<"  ";}
        }
        cout << endl<<endl;
    }



    return 0;
}
