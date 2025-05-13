#!/bin/sh

# use drm/amdgpu AMDgpu driver interface to set amdgpu clock.

dev_path="/sys/class/drm/card0/device/"

dclk_path=${dev_path}"pp_dpm_dclk"
dclk1_path=${dev_path}"pp_dpm_dclk1"
vclk_path=${dev_path}"pp_dpm_vclk"
vclk1_path=${dev_path}"pp_dpm_vclk1"
sclk_path=${dev_path}"pp_dpm_sclk"
socclk_path=${dev_path}"pp_dpm_socclk"
mclk_path=${dev_path}"pp_dpm_mclk"
fclk_path=${dev_path}"pp_dpm_fclk"

performance_level_path=${dev_path}"power_dpm_force_performance_level"
profile_mode_path=${dev_path}"pp_power_profile_mode"

function PrintUsage()
{
    local name=`basename $0 .sh`
    echo "Usage: $name [ setlow | showclk | reset ]"
}

function Print_pp_dpm_clk()
{
    echo "pp_dpm_dclk:   " "$(cat ${dclk_path} | tr "\n" " ")"
    echo "pp_dpm_dclk1:  " "$(cat ${dclk1_path} | tr "\n" " ")"
    echo "pp_dpm_vclk:   " "$(cat ${vclk_path} | tr "\n" " ")"
    echo "pp_dpm_vclk1:  " "$(cat ${vclk1_path} | tr "\n" " ")"
    echo "pp_dpm_sclk:   " "$(cat ${sclk_path} | tr "\n" " ")"
    echo "pp_dpm_socclk: " "$(cat ${socclk_path} | tr "\n" " ")"
    echo "pp_dpm_mclk:   " "$(cat ${mclk_path} | tr "\n" " ")"
    echo "pp_dpm_fclk:   " "$(cat ${fclk_path} | tr "\n" " ")"
}

function PrintPowerSetting()
{
    echo -e "\npp_power_profile_mode:"
    cat "${profile_mode_path}"
    echo -e "\n"
    Print_pp_dpm_clk;
    echo -e "\npower_dpm_force_performance_level: " $(cat ${performance_level_path})
}

function SetLowestPower()
{
    echo manual > ${performance_level_path}
    echo 2 > ${profile_mode_path}
    echo 0 > ${dclk_path}
    echo 0 > ${dclk1_path}
    echo 1 > ${vclk_path}
    echo 1 > ${vclk1_path}
    echo 0 > ${sclk_path}
    echo 0 > ${socclk_path}
    echo 0 > ${mclk_path}
    echo 0 > ${fclk_path}
    PrintPowerSetting;
}

function ResetPowerSetting()
{
    echo 1 > ${profile_mode_path}
    echo auto > ${performance_level_path}
    PrintPowerSetting;
}

gpu_vendor=$(cat ${dev_path}"vendor")
if [ $gpu_vendor == "0x1002" ]; then
    case $1 in
        setlow|reset)
            if [ `whoami` == "root" ]; then
                if [ $1 == "setlow" ]; then
                    SetLowestPower;
                elif [ $1 == "reset" ]; then
                    ResetPowerSetting;
                fi
                exit 0
            else
                echo "Require root privilege."
            fi
            ;;
        showclk)
            Print_pp_dpm_clk;
            exit 0
            ;;
        *)
            PrintUsage;
            ;;
    esac
    PrintPowerSetting;
    exit -1
else
    echo "only support AMD GPU."
fi
