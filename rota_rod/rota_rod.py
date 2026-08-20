import argparse
import sys
from pathlib import Path
import pandas as pd
import subprocess
# 20 Aug 2026
# Lucas Kearns

# Script to wrap assorted rota-rod scripts and provide straightforward argument parsing

###################
## Argument parsing
##################

# Main parsing / arguments
# ------------------------
desc_str = (
    "Collection of data visualization scripts for the rotarod. Note* by running\n"
)
desc_str += (
    "'python rota_rod.py subcommand -h' you can see additional argument required by\n"
)
desc_str += "those data visualization scripts."

parser = argparse.ArgumentParser(description=desc_str)
parser.add_argument(
    "--filename", help="Input .xlsx file containing rotarod data.", required=True
)
parser.add_argument(
    "--sheetname",
    default="Sheet1",
    help="Sheet name for data within xlsx file. (Default: Sheet1)",
    required=True,
)
parser.add_argument(
    "--num_col",
    help="Column containing the numerical data being compared.",
    required=True,
)
parser.add_argument(
    "--sep_col",
    help="Column containing how the comparisons are being split up. EG "
    + "different lines in the line graph",
    required=True,
)
parser.add_argument(
    "--output", help="File path to save output to.", required=True, default="output.pdf"
)

# Sub program specific arguments
# ------------------------------

sp = parser.add_subparsers(dest="subprogram")

b_p = sp.add_parser("boxplot", add_help=False)
b_p.add_argument("-h", action="store_true", dest="help")
b_p.add_argument(
    "--comp_col",
    default="Genotype",
    help="Column containing metadat for generating different boxplots across the separations. (Default: Genotype)",
    required=True,
)
l_p = sp.add_parser("lineplot", add_help=False)
l_p.add_argument(
    "--trial_col",
    default="Trial Number",
    help="Column containing trial data for generating line graph. (Default: trial_col)",
    required=True,
)

# Help strings specific arguments. Necessary to avoid error induced by calling
# parse_args with missing required args.
# ----------------------------------------------------------------------------
if "boxplot" in sys.argv and "-h" in sys.argv:
    print("\n--- Main options---\n")
    parser.print_help()
    print("\n--- boxplot options ---\n")
    b_p.print_help()
    exit()
if "lineplot" in sys.argv and "-h" in sys.argv:
    print("\n--- Main options---\n")
    parser.print_help()
    print("\n--- lineplot options ---\n")
    l_p.print_help()
    exit()

# Parse arguments
# ---------------

args = parser.parse_args()


###############################
## Check arguments for validity
###############################


# Check if input file exists
# --------------------------
if not Path(args.filename).exists():
    raise (ValueError(f"Input filename {args.filename} does not exist."))


# Check if sheetname present in excel spreadsheet
# -----------------------------------------------
i_df = pd.ExcelFile(args.filename)
if args.sheetname not in i_df.sheet_names:
    raise (
        ValueError(
            f"Sheet name {args.sheetname} not present in input file.\n"
            + f"Sheet names present: {i_df.sheet_names}"
        )
    )


# Check if all column supplied are actually present in the excel spreadsheet
# --------------------------------------------------------------------------
xl_df = pd.read_excel(args.filename, sheet_name=args.sheetname)
arg_dict = vars(args)
column_args = [v for v in arg_dict.keys() if v.endswith("_col")]
cols = xl_df.columns.tolist()
for v in column_args:
    if arg_dict[v] not in cols:
        raise (ValueError(f"{v}: {arg_dict[v]} not present in column names."))

# Check if output location exists
# ------------------------------
output_parent = Path(args.output).parent
if not output_parent.exists():
    raise ValueError(
        f"Error. Attempting to write output to a folder that doesn't exist: {output_parent}"
    )


####################################################
## Call the subprograms based on user supplied input
####################################################


script_dir = str(Path(__file__).parent) + "/libs/"


def run_command(cmd):
    print(f"\n\n========\nRunning: {cmd}")
    subprocess.run(cmd, shell=True)


if args.subprogram == "boxplot":
    cmd = "Rscript "
    cmd += f"'{script_dir}/grouped_boxplot.R' "
    cmd += f"'{args.filename}' "
    cmd += f"'{args.sheetname}' "
    cmd += f"'{args.comp_col}' "
    cmd += f"'{args.num_col}' "
    cmd += f"'{args.sep_col}' "
    cmd += f"'{args.output}'"
    run_command(cmd)

elif args.subprogram == "lineplot":
    cmd = "Rscript "
    cmd += f"'{script_dir}/line_plot.R' "
    cmd += f"'{args.filename}' "
    cmd += f"'{args.sheetname}' "
    cmd += f"'{args.trial_col}' "
    cmd += f"'{args.num_col}' "
    cmd += f"'{args.sep_col}' "
    cmd += f"'{args.output}'"
    run_command(cmd)
