#ifndef __DEBUG_H
#define __DEBUG_H

#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Vfft_2d.h"

#ifdef __cplusplus
extern "C" {
#endif

void enable_trace_to(const char* path);
void finish();
void init();
void event_record(uint64_t event_time);

#ifdef __cplusplus
}
#endif

#endif