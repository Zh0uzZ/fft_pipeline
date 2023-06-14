#include "debug.h"

extern VerilatedContext *contextp;
extern Vfft_2d *top;
extern VerilatedVcdC *m_trace;

void enable_trace_to(const char* path) {
  contextp->traceEverOn(true);
  top->trace(m_trace, 0);
  m_trace->open(path);
}

void finish() {
  m_trace->close();
  top->final();
  delete top;
  delete contextp;
  delete m_trace;
}

void __event_record(uint64_t reset_time, uint64_t wait_time) {
  while (contextp->time() < wait_time && !contextp->gotFinish()) {
    contextp->timeInc(1);
    if (contextp->time() > reset_time) {
      top->rst_ni = 1;
    }
    if (contextp->time() % 5 == 0) {
      top->clk_i = (top->clk_i == 1 ? 0 : 1);
    }
    top->eval();
    m_trace->dump(contextp->time());
  }
}

void init() {
  // init clock and reset
  top->rst_ni = 1;
  top->clk_i = 0;
  top->start_i = 0;
  top->eval();
  top->clk_i = 1;
  top->rst_ni = 0;
  top->eval();
  m_trace->dump(contextp->time());
  // reset and wait
  __event_record(20, 27);
}

void event_record(uint64_t event_time) {
  uint64_t wait_time = contextp->time() + event_time;
  __event_record(20, wait_time);
}