# Initialize development environment
#
# Use like `. ./init_env.sh`.
#
# Note that venv will be created in current working directory as opposed to the
# directory in which this script resides.

PROJECT_PATH="$(pwd)"

if [ ! -d "venv" ]; then
  echo "Creating venv"
  python -m venv --prompt "mkhelp" venv
  . "venv/bin/activate"
else
  echo "Reusing venv"
  . "venv/bin/activate"
fi
export PATH="${PROJECT_PATH}/bin/:${PATH}"
