# DISPLAY
export DISPLAY=`echo $SSH_CLIENT | awk '{print $1}'`:30.0

# cadence
export CADENCE_HOME=/opt/cadence
# cadence - license
export CDS_LIC_FILE=$CADENCE_HOME/license/license.dat
export CDS_LIC_ONLY=1
# cadence - ic618
export CDSHOME=$CADENCE_HOME/IC618
export PATH=$PATH:$CDSHOME/tools/bin
export PATH=$PATH:$CDSHOME/tools/dfII/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CDSHOME/tools/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CDSHOME/tools/dfII/lib
export CDS_SPECTRERF_FBENABLE=1
export CDS_AUTO_64BIT=ALL
export CDS_Netlisting_Mode=Analog
export CDS_ENABLE_VMS=1
export CDS_LOAD_ENV=CWD
export OA_UNSUPPORTED_PLAT=linux_rhel60
export OA_HOME=$CDSHOME/oa_v22.60.041
export OA_PLUGIN_PATH=${PATH}:$OA_HOME/data/plugins
export W3264_NO_HOST_CHECK=1
# cadence - spectre181
export SPECTRE_HOME=$CADENCE_HOME/SPECTRE181
export PATH=$PATH:$SPECTRE_HOME/bin
export PATH=$PATH:$SPECTRE_HOME/tools/bin
export CDS_SPECTRE_FBENABLE=1
# cadence - incisive152
export INCISIVE_HOME=$CADENCE_HOME/INCISIVE152
export PATH=$PATH:$INCISIVE_HOME/bin
export PATH=$PATH:$INCISIVE_HOME/tools/bin

# mentor
export MENTOR_HOME=/opt/mentor
# mentor - license
export MGLS_LICENSE_FILE=/tmp/mentor_license.dat
# mentor - calibre
export CALIBRE_HOME=$MENTOR_HOME/calibre2019/aoj_cal_2019.3_15.11
# export CALIBRE_HOME=$MENTOR_HOME/calibre2015/aoi_cal_2015.2_36.27
export MGC_HOME=$CALIBRE_HOME
export PATH=$PATH:$CALIBRE_HOME/bin
export MGC_LIB_PATH=$CALIBRE_HOME/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CALIBRE_HOME/shared/pkgs/icv/tools/calibre_client/lib/64
export CALIBRE_ENABLE_SKILL_PEXBA_MODE=1
export MGC_CALIBRE_REALTIME_VIRTUOSO_ENABLED=1
export MGC_CALIBRE_REALTIME_VIRTUOSO_SAVE_MESSENGER_CELL=1
export MGC_CALIBRE_SAVE_ALL_RUNSET_VALUES=1

# synopsys
export SYNOPSYS=/opt/synopsys
# synopsys - fm
export FM_HOME=$SYNOPSYS/fm/O-2018.06-SP1
export PATH=$PATH:$FM_HOME/bin
# synopsys - hspice
export HSPICE_HOME=$SYNOPSYS/hspice/N-2017.12-SP2
export PATH=$PATH:$HSPICE_HOME/hspice/bin
# synopsys - icc
export ICC_HOME=$SYNOPSYS/icc/O-2018.06-SP1
export PATH=$PATH:$ICC_HOME/bin
# synopsys - icc2
export ICC2_HOME=$SYNOPSYS/icc2/O-2018.06-SP1
export PATH=$PATH:$ICC2_HOME/bin
# synopsys - lc
export LC_HOME=$SYNOPSYS/lc/O-2018.06-SP1
export SYNOPSYS_LC_ROOT=$SYNOPSYS/lc/O-2018.06-SP1
export PATH=$PATH:$LC_HOME/bin
# synopsys - pts
export PT_HOME=$SYNOPSYS/pts/O-2018.06-SP1
export PATH=$PATH:$PT_HOME/bin
# synopsys - pwr
export PWR_HOME=$SYNOPSYS/pwr/O-2018.06-SP3
export PATH=$PATH:$PWR_HOME/bin
# synopsys - starrc
export STARRC_HOME=$SYNOPSYS/starrc/O-2018.06-SP1
export PATH=$PATH:$STARRC_HOME/bin
# synopsys - syn
export DC_HOME=$SYNOPSYS/syn/O-2018.06-SP1
export PATH=$PATH:$DC_HOME/bin
# synopsys - vsc-mx
export VCS_HOME=$SYNOPSYS/vcs-mx/O-2018.09-SP2
export PATH=$PATH:$VCS_HOME/bin
export DVE_HOME=$VCS_HOME/gui/dve
export PATH=$PATH:$DVE_HOME/bin
export VCS_TARGET_ARCH="amd64"
# synopsys - verdi
export VERDI_HOME=$SYNOPSYS/verdi/Verdi_O-2018.09-SP2
export PATH=$PATH:$VERDI_HOME/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$VERDI_HOME/share/PLI/VCS/LINUXAMD64

# xilinx
export XILINX_HOME=/opt/xilinx
export XILINXD_LICENSE_FILE=$XILINX_HOME/lic/vivado_lic2037.lic
# xilinx - vivado
export XILINX_VIVADO=$XILINX_HOME/Vivado/2022.2
export PATH=$PATH:$XILINX_VIVADO/bin
alias vivado="LD_PRELOAD=/lib/x86_64-linux-gnu/libudev.so.1 vivado"

#tsmc65 sram compiler
export PATH=$PATH:/workspaces/c4e-workspace/install/TS24CA501-FB-00000-r0p0-00eac0/arm/tsmc/cln65gplus/sram_sp_hdc_svt_rvt_hvt/r0p0-00eac0/bin
export PATH=$PATH:/workspaces/c4e-workspace/install/aci/sram_dp_hdc_svt_rvt_hvt/bin
export PATH=$PATH:/workspaces/c4e-workspace/install/memory_compiler/MC