#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH -J dumpemb                 # Job name
#SBATCH -o /home/emm392/slurm_return/dumpemb_%j.out                  # Name of stdout output log file
#SBATCH -e /home/emm392/slurm_return/dumpemb_%j.err                  # Name of stderr output log file
#SBATCH --mail-user=emarro@cs.cornell.edu    # Mail info to me
#SBATCH --mail-type=all                      # The type of stuff to email me about
#SBATCH -t 72:00:00                          # Time limit (hh:mm:ss)
#SBATCH --partition=gpu             # Request partition for resource allocation
#SBATCH --constraint="gpu-mid|gpu-high"
#SBATCH --mem=64G
#SBATCH --gres=gpu:1
#SBATCH --open-mode=append
#SBATCH --requeue
#SBATCH --array=0-250
source ./config.sh
conda activate proteinnpt_env

export assay_index=$SLURM_ARRAY_TASK_ID #Replace with index of desired DMS assay in the ProteinGym reference file (`utils/proteingym`)
export batch_size=1
export max_positions=1024

export model_type='MSA_Transformer' # [MSA_Transformer|Tranception|ESM1v]
export model_location=$MSA_Transformer_location # [MSA_Transformer_location|Tranception_location|ESM1v_location]
export num_MSA_sequences=384 # Used in MSA Transformer only
export embeddings_folder=$embeddings_indels_data_folder/$model_type

python embeddings.py \
    --assay_reference_file_location ${DMS_reference_file_path_indels} \
    --assay_index ${assay_index} \
    --model_type ${model_type} \
    --model_location ${model_location} \
    --input_data_location ${CV_indels_data_folder} \
    --output_data_location ${embeddings_folder} \
    --batch_size ${batch_size} \
    --max_positions ${max_positions} \
    --num_MSA_sequences ${num_MSA_sequences} \
    --MSA_data_folder ${DMS_MSA_data_folder} \
    --MSA_weight_data_folder ${DMS_MSA_weights_folder} \
    --path_to_hhfilter ${path_to_hhfilter} \
    --path_to_clustalomega ${path_to_clustalomega} \
    --indel_mode
