#!/bin/bash

init() {
    # indicate the following modatory variables
    OUT_DIR=$HOME/sphinx
    SRC_DIR=
    gosu=$(which sudo)

    if [ ! -d "$SRC_DIR" ]; then 
        echo "Please indicate the src path at first."
        exit -1
    fi

    PY=python
    PIP=pip
    if which python3 > /dev/null 2>&1 ; then
        PY=python3
        PIP=pip3
    fi
}

create_apidoc() {
    if [ -e $OUT_DIR/conf.py ]; then
        grep -q 'sphinx_rtd_theme' $OUT_DIR/conf.py && return -1
    fi

    echo "---> create doc"
    $gosu $PIP install sphinx_rtd_theme
    which sphinx-apidoc > /dev/null 2>&1 ||  $gosu $PIP install sphinx

    opts=' -F '
    [ -n "$PROJECT" ] && opts="$opts -H $PROJECT "
    [ -n "$AUTHOR" ] && opts="$opts -A $AUTHOR "
    [ -n "$VERSION" ] && opts="$opts -V $VERSION"
    [ -n "$RELEASE" ] && opts="$opts -R $RELEASE"
    sphinx-apidoc $opts -o $OUT_DIR $SRC_DIR

    sed -i 's/\(html_theme = \).*/\1"sphinx_rtd_theme"/' $OUT_DIR/conf.py
    sed -i 's/^# import/import/g' $OUT_DIR/conf.py
    sed -i 's/^# sys/sys/g' $OUT_DIR/conf.py
}


#first_start_sphinx() {
#    pushd $DOC_PATH
#
#    [ -e conf.py ] || return
#
#    opts=" -q -p $PROJECT -a $AUTHOR "
#    [ -n "$RELEASE" ] && opts=" $opts -r $RELEASE "
#
#    sphinx-quickstart $opts
#    sed -i 's/\(html_theme = \).*/\1"sphinx_rtd_theme"/' conf.py
#
#    popd
#}

update_apidoc() {
    echo "---> update doc"
    sphinx-apidoc -f -o $OUT_DIR $SRC_DIR
}

gen_html() {
    cd $OUT_DIR
    make html && cd _build/html
    if which python3 > /dev/null 2>&1 ; then
        python3 -m http.server 12500
    else
        python -m SimpleHTTPServer 12500
    fi
}

main() {
    init
    create_apidoc || update_apidoc
    gen_html
}

main
