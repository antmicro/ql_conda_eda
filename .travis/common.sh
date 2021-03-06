# Some colors, use it like following;
# echo -e "Hello ${YELLOW}yellow${NC}"
GRAY=' \033[0;30m'
RED=' \033[0;31m'
GREEN=' \033[0;32m'
YELLOW=' \033[0;33m'
PURPLE=' \033[0;35m'
NC='\033[0m' # No Color

SPACER="echo -e ${GRAY} - ${NC}"

export -f travis_nanoseconds
export -f travis_fold
export -f travis_time_start
export -f travis_time_finish
export -f travis_wait
export -f travis_jigger

if [ $TRAVIS_OS_NAME = 'osx' ]; then
    DATE_SWITCH="-r "
else
    DATE_SWITCH="--date=@"
fi
if [ -z "$DATE_STR" ]; then
	export DATE_TS="$(git log --format=%ct -n1)"
	export DATE_NUM="$(date ${DATE_SWITCH}${DATE_TS} -u +%Y%m%d%H%M%S)"
	export DATE_STR="$(date ${DATE_SWITCH}${DATE_TS} -u +%Y%m%d_%H%M%S)"
	echo "Setting date number to $DATE_NUM"
	echo "Setting date string to $DATE_STR"
fi

function start_section() {
	travis_fold start "$1"
	travis_time_start
	echo -e "${PURPLE}${PACKAGE}${NC}: - $2${NC}"
	echo -e "${GRAY}-------------------------------------------------------------------${NC}"
}

function end_section() {
	echo -e "${GRAY}-------------------------------------------------------------------${NC}"
	travis_time_finish
	travis_fold end "$1"
}

# Disable this warning;
# xxxx/conda_build/environ.py:377: UserWarning: The environment variable
#     'TRAVIS' is being passed through with value 0.  If you are splitting
#     build and test phases with --no-test, please ensure that this value is
#     also set similarly at test time.
export PYTHONWARNINGS=ignore::UserWarning:conda_build.environ

export BASE_PATH="/tmp/really-long-path"
mkdir -p "$BASE_PATH"
if [ $TRAVIS_OS_NAME = 'windows' ]; then
    export CONDA_PATH='/c/tools/miniconda3'
    export PATH=$CONDA_PATH/Scripts/:$CONDA_PATH/:$PATH
else
    export CONDA_PATH="$BASE_PATH/conda"
    export PATH="$CONDA_PATH/bin:$PATH"
fi

export GIT_SSL_NO_VERIFY=1
export GITREV="$(git describe --long 2>/dev/null || echo "unknown")"
export CONDA_BUILD_ARGS="$EXTRA_BUILD_ARGS $PACKAGE"
export CONDA_TEST_ARGS="--test"
if [ -f "$PACKAGE/conda_build_config.$TOOLCHAIN_ARCH.yaml" ]; then
	export CONDA_BUILD_ARGS="$CONDA_BUILD_ARGS -m $PACKAGE/conda_build_config.$TOOLCHAIN_ARCH.yaml"
fi
export CONDA_OUT="$(conda render --output $CONDA_BUILD_ARGS 2> /dev/null | grep conda-bld | grep tar.bz2 | tail -n 1 | sed -e's/-[0-9]\+\.tar/*.tar/' -e's/-git//')"

echo "          GITREV: $GITREV"
echo "      CONDA_PATH: $CONDA_PATH"
echo "CONDA_BUILD_ARGS: $CONDA_BUILD_ARGS"
echo "       CONDA_OUT: $CONDA_OUT"
