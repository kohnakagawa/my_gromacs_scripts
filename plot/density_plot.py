#!/usr/bin/env python
import numpy as np
import matplotlib.pyplot as plt
import argparse
import os
from re import findall
from glob import glob

def set_font():
    plt.rcParams["font.size"] = 20
    plt.rcParams["font.family"] = 'serif'


def set_label(x_name, y_name):
    plt.xlabel(x_name)
    plt.ylabel(y_name)


def set_ticks(x_range, y_range):
    plt.xticks(np.arange(*x_range))
    plt.yticks(np.arange(*y_range))


def plot_carbon_density(data_file, carbon_name, lipid_name):
    raw_data = np.loadtxt(data_file)
    z_cord = raw_data[:,0]
    density = raw_data[:,1]
    if lipid_name != "TSPC":
        density /= 200.0
    plt.plot(z_cord, density, '-', label=carbon_name)


def main(input_dir, legend_pos, lipids, carbons, poss):
    set_font()
    set_label("Relative position from membrane center [nm]", r"Number density [nm$^{-3}$]")

    for l, cs, p in zip(lipids, carbons, poss):
        carbon_names = ["-".join((l, c.replace("c3", "sn1-C").replace("c2", "sn2-C"))) for c in cs]
        fnames = [os.path.join(input_dir, "_".join((l, c, p)) + ".xvg") for c in cs]
        for fname, cname in zip(fnames, carbon_names):
            plot_carbon_density(fname, cname, l)

    plt.tight_layout()
    plt.legend(loc=legend_pos, fontsize=15)
    # plt.legend(loc="upper right", fontsize=18)
    plt.savefig(os.path.join(input_dir, "{}_{}_density.eps".format("_".join(carbon_names), "_".join(poss))))

    # for check
    # plt.show()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Density profile of carbons")
    parser.add_argument('-i', '--input', dest='input_dir', required=True, help="input directory name")
    parser.add_argument('-l', '--lipids', nargs="+", dest='lipids', required=True, help="names of lipids")
    parser.add_argument('-p', '--positions', nargs="+", dest="pos", required=True, help="leaflet positions [hi/lo/tot]")
    parser.add_argument('-c0', '--carbons0', nargs="+", dest='carbons0', required=True,  help="names of carbons0")
    parser.add_argument('-c1', '--carbons1', nargs="+", dest="carbons1", required=False, help="names of carbons1")
    parser.add_argument('-g', '--legend_pos', dest="legend_pos", required=False, default="upper right", help="legend position")
    args = parser.parse_args()
    main(args.input_dir, args.legend_pos, args.lipids, (args.carbons0, args.carbons1), args.pos)
