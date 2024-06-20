#!/bin/bash
#SBATCH --cpus-per-task=2
#SBATCH -J 3M_625_1500_seqs                 # Job name
#SBATCH -o /share/kuleshov/emm392/ProteinNPT/watch_logs/3M_subs_%j.out                  # Name of stdout output log file
#SBATCH -e /share/kuleshov/emm392/ProteinNPT/watch_logs/3M_subs_%j.err                  # Name of stderr output log file
#SBATCH -t 72:00:00                          # Time limit (hh:mm:ss)
#SBATCH --partition=gpu             # Request partition for resource allocation
#SBATCH --constraint="gpu-mid|gpu-high"
#SBATCH --mem=64G
#SBATCH --gres=gpu:1
#SBATCH --open-mode=append
#SBATCH --requeue
#SBATCH --array=22,48
# SBATCH --array=22,27,48,53,116,117,118,158,161,196

source ./config.sh
conda activate proteinnpt_env

export model_config_location=$MambaNPT_config_location # [ProteinNPT_config_location|MambaNPT_config_location|Embeddings_MSAT_config_location|Embeddings_Tranception_config_location|Embeddings_ESM1v_config_location|OHE_config_location|OHE_TranceptEVE_config_location]
export sequence_embeddings_folder=$MSAT_embeddings_folder # [MSAT_embeddings_folder|Tranception_embeddings_folder|ESM1v_embeddings_folder]

export fold_variable_name='fold_random_5' #[fold_random_5 | fold_contiguous_5 | fold_modulo_5]
export assay_index=$SLURM_ARRAY_TASK_ID #Replace with index of desired DMS assay in the ProteinGym reference file (`utils/proteingym`)
export train_num_assay=425  #(labeld) assay sequeces  during training
export eval_num_training=1000 #(labled) assay sequences during inference
export num_msa_training=384 #384 #$msa sequences during training
export model_name_suffix='singles_3M_mnpt_'${train_num_assay}'_train_'${eval_num_training}'_eval_seqs_assay_'$assay_index #Give a name to the model


python train.py \
    --data_location ${proteinnpt_data_path} \
    --assay_reference_file_location ${DMS_reference_file_path_subs} \
    --model_config_location ${model_config_location} \
    --fold_variable_name ${fold_variable_name} \
    --assay_index ${assay_index} \
    --target_config_location ${target_config_location_fitness} \
    --zero_shot_fitness_predictions_location ${zero_shot_fitness_predictions_substitutions} \
    --training_fp16 \
    --sequence_embeddings_folder ${sequence_embeddings_folder} \
    --model_name_suffix ${model_name_suffix} \
    --use_wandb \
    --embed_dim 200 \
    --num_protein_npt_layer 3 \
    --training_num_assay_sequences_per_batch_per_gpu ${train_num_assay} \
    --eval_num_training_sequences_per_batch_per_gpu ${eval_num_training} \
    --num_MSA_sequences_per_training_instance ${num_msa_training} \
    --max_learning_rate 0.0001
