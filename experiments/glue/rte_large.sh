#!/bin/bash
SCRIPT=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT")
cd $SCRIPT_DIR

cache_dir=/tmp/DeBERTa/

function setup_glue_data(){
	task=$1
	mkdir -p $cache_dir
	if [[ ! -e $cache_dir/glue_tasks/${task}/train.tsv ]]; then
		curl -J -L https://raw.githubusercontent.com/nyu-mll/jiant/master/scripts/download_glue_data.py | python3 - --data_dir $cache_dir/glue_tasks 
	fi
}

init=large 
tag=Large
Task=RTE
setup_glue_data $Task
../utils/train.sh -i $init --config config.json -t $Task --data $cache_dir/glue_tasks/$Task --tag $tag -o /tmp/ttonly/$tag/$Task -- --num_train_epochs 8 --accumulative_update 1 --warmup 100 --learning_rate 8e-6 --train_batch_size 32 --max_seq_length 320 --dump 500 --cls_drop 0.50
