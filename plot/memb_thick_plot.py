#!/usr/bin/env python
import numpy as np
import matplotlib.pyplot as plt
import argparse
import os

def set_font():
    plt.rcParams["font.size"] = 20
    plt.rcParams["font.family"] = 'serif'


def set_label(x_name, y_name):
    plt.xlabel(x_name)
    plt.ylabel(y_name)


def set_ticks(x_range, y_range):
    plt.xticks(np.arange(*x_range))
    plt.yticks(np.arange(*y_range))


def load_density_data(data_file):
    raw_data = np.loadtxt(data_file)
    z_cord = raw_data[:,0]
    density = raw_data[:,1]
    return z_cord, density


def plot_hydrophilic_pos(input_dir):
    data_up_file = os.path.join(input_dir, "phosph_up.xvg")
    data_lo_file = os.path.join(input_dir, "phosph_lo.xvg")
    z_cord, dens_up = load_density_data(data_up_file)
    z_cord, dens_lo = load_density_data(data_lo_file)
    dens_up *= 6
    dens_lo *= 6
    base = np.zeros(z_cord.shape[0])
    plt.fill_between(z_cord, base, dens_up, facecolor='gray', alpha=0.3)
    plt.fill_between(z_cord, base, dens_lo, facecolor='gray', alpha=0.3)


def plot_hydrophilic_pos_lipid(input_dir, lipid):
    data_file = os.path.join(input_dir, "phosph_up_{}.xvg".format(lipid))
    z_cord, dens = load_density_data(data_file)
    if lipid == "SOPC":
        dens /= 90
    plt.plot(z_cord, dens, '-', label="P density of {}".format(lipid))


def plot_carbon_density(input_dir):
    data_up_file = os.path.join(input_dir, "carbon_tot_up.xvg")
    data_lo_file = os.path.join(input_dir, "carbon_tot_lo.xvg")
    z_cord, dens_up = load_density_data(data_up_file)
    z_cord, dens_lo = load_density_data(data_lo_file)
    plt.plot(z_cord, dens_up, '-', label="upper leaflet")
    plt.plot(z_cord, dens_lo, '-', label="lower leaflet")


def main(input_dir, legend_pos):
    set_font()
    set_label("Relative position from membrane center [nm]", r"Number density [nm$^{-3}$]")

    plot_hydrophilic_pos_lipid(input_dir, "SOPC")
    plot_hydrophilic_pos_lipid(input_dir, "TSPC")
    # plot_hydrophilic_pos(input_dir)
    # plot_carbon_density(input_dir)
    plt.tight_layout()
    plt.legend(loc=legend_pos, fontsize=15)
    plt.xlim(0.0, 4.0)
    # plt.savefig(os.path.join(input_dir, "carbon_hydrophil.eps"))
    plt.savefig(os.path.join(input_dir, "hydrophil_{}_{}.eps".format("SOPC", "TSPC")))

    # for check
    # plt.show()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Density profile of carbons")
    parser.add_argument('-i', '--input', dest='input_dir', required=True, help="input directory name")
    parser.add_argument('-g', '--legend_pos', dest="legend_pos", required=False, default="upper right", help="legend position")
    args = parser.parse_args()
    main(args.input_dir, args.legend_pos)
