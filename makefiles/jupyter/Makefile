JUPYTER_NOTEBOOK_DIR  = ~/jupyter-notebook

init:
	which jupyter >/dev/null || pip3 install jupyter

pwd: init
    ifeq ($(wildcard ${HOME}/.jupyter/jupyter_notebook_config.json),)
	    jupyter notebook --generate-config && jupyter notebook password
    endif

up: pwd 
	mkdir -p ${JUPYTER_NOTEBOOK_DIR} && jupyter notebook --ip 0.0.0.0 --notebook-dir ${JUPYTER_NOTEBOOK_DIR} --no-browser --allow-root
