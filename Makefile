# NGUYEN VAN THUC - 24161421
# LUT-ALM V0 | ZYBO XC7Z010 | FPGA LUT-only reproducible benchmark
#make help       # Xem danh sách lệnh
#make deps       # Kiểm tra Vivado, Yosys, OpenSTA, Icarus
#make check      # Kiểm tra cấu hình project và golden vectors
#make clean      # Xóa các file build và report đã tạo

#make verify          # Kiểm tra mô hình Python và golden vectors
#make accuracy        # Tính sai số của LUT-ALM
#make sim             # Mô phỏng LUT-ALM signed và unsigned
#make sim-baseline    # Mô phỏng bộ nhân exact signed

#make fpga TOP=lutalm_mul_s8 LOW_W=3
#make fpga TOP=lutalm_mul_u8 LOW_W=3
#make fpga TOP=exact_mul_s8

#make fpga-pair   // cả hai bộ nhân có dấu 

#tương tự asic và sta thì thay fpga thành asic hoặc sta





SHELL := /bin/bash
.DEFAULT_GOAL := help

TOP ?= lutalm_mul_s8
LOW_W ?= 3
PART ?= xc7z010clg400-1
CLOCK_NS ?= 10.0
IO_DELAY_NS ?= 2.0

export TOP LOW_W PART CLOCK_NS IO_DELAY_NS
.PHONY: help deps check verify accuracy sim sim-baseline asic asic-baseline \
    sta sta-baseline fpga fpga-baseline fpga-pair asic-pair sta-pair compare clean

help:
	@echo 'mul_int8 V0: ZYBO Z-7010 / FPGA LUT-only / DSP=0 enforced'
	@echo 'make check             - project invariants + Python golden-vector regression'
	@echo 'make deps              - report installed toolchain'
	@echo 'make sim               - exhaustive signed and unsigned V0 RTL tests'
	@echo 'make sim-baseline      - exact signed RTL reference test'
	@echo 'make accuracy          - signed approximation error'
	@echo 'make fpga              - LUT-ALM signed V0 (post-synth FPGA)'
	@echo 'make fpga-baseline     - signed exact (post-synth FPGA)'
	@echo 'make fpga-pair         - both FPGA variants, DSP=0 asserted'
	@echo 'make asic-pair         - Nangate45 area for both'
	@echo 'make sta-pair          - ASIC timing for both'
	@echo 'make compare           - full regression and paired PPA reports'
	@echo 'make clean             - remove generated artifacts'
	@echo 'Options: TOP=lutalm_mul_s8|lutalm_mul_u8|exact_mul_s8 LOW_W=3|4'
	@echo '         PART=xc7z010clg400-1 CLOCK_NS=10 IO_DELAY_NS=2'

check:
	@python3 scripts/check_project.py
	@python3 scripts/verify_model.py

deps:
	@bash scripts/check_env.sh

verify:
	@python3 scripts/verify_model.py

accuracy:
	@python3 scripts/analyze_accuracy.py

sim:
	@bash scripts/run_sim.sh

sim-baseline:
	@bash scripts/run_sim_baseline.sh

asic:
	@bash scripts/run_yosys.sh

asic-baseline:
	@$(MAKE) asic TOP=exact_mul_s8 LOW_W=3

asic-pair:
	@$(MAKE) asic TOP=lutalm_mul_s8 LOW_W=3
	@$(MAKE) asic-baseline

sta: asic
	@bash scripts/run_sta.sh

sta-baseline:
	@$(MAKE) sta TOP=exact_mul_s8 LOW_W=3

sta-pair:
	@$(MAKE) sta TOP=lutalm_mul_s8 LOW_W=3
	@$(MAKE) sta-baseline

fpga:
	@bash scripts/run_vivado.sh

fpga-baseline:
	@$(MAKE) fpga TOP=exact_mul_s8 LOW_W=3

fpga-pair:
	@$(MAKE) fpga TOP=lutalm_mul_s8 LOW_W=3
	@$(MAKE) fpga-baseline
	@python3 scripts/compare_reports.py

compare:
	@$(MAKE) check
	@$(MAKE) sim
	@$(MAKE) sim-baseline
	@$(MAKE) sta-pair
	@$(MAKE) fpga-pair
	@python3 scripts/compare_reports.py

clean:
	@find build reports -mindepth 1 ! -name .gitkeep -type f -delete
	@rm -rf .Xil .xil vivado.jou vivado.log vivado_*.backup.*
	@echo 'Generated products cleaned. RTL, SDC, NAND45 library and vectors kept.'
