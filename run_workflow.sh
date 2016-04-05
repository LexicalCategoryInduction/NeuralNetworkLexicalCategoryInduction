#!/bin/bash
# Copyright 2016 Marianna D'Errico, Simone Bna'
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# name of the corpus
CORPUS="./coris/CORIS4word2vecNOMWE_APO.txt"
#CORPUS="./trunk/text8"

# path of neural network
WORD2VECBIN_PATH="./trunk/word2vec"

# relative path of the word list
WORDLIST_ABS_NAME="./wordlist/word_list_serena_articolo1.txt"

# map classes to colors and legend name
MAP_CLASS_TO_COLOR_LABEL_ABS_NAME="./wordlist/mappa_serena_1.mat"

# number of iteration
ITER=7

#
CBOW=1

# size
SIZE=100

# window
WINDOW=5

# negative
NEGATIVE=25

# min count
MIN_COUNT=0

# hs
HS=0

# sample
SAMPLE=1e-4

# number of cluster for cluto
NCLUSTER=27

# fig name
FIG_NAME="fig1.ps"
FIG_NAME_PDF="fig1.pdf"

OUTPUT_WITH_STAT_CLUTOPROGRAM_NAME="cluto_output_with_statistics.txt"
OUTPUT_WITH_CLASSES_CLUTOPROGRAM_NAME="cluto_output_with_classes.txt"

PLOT_NAME="2Dvisualization"
TITLE="Categorie sintattiche"

# --------------------------------------------------------------------------------------------------------------------------------------------------------------

# output file name of word2vec
OUTPUT_NAME_WORDVEC="vec_iter${ITER}_size${SIZE}_cbow${CBOW}_window${WINDOW}_negative${NEGATIVE}_sample${SAMPLE}_hs${HS}_min_count${MIN_COUNT}.txt"

# folder name
OUTPUT_FOLDER_WORDVEC="./results/vec_iter${ITER}_size${SIZE}_cbow${CBOW}_window${WINDOW}_negative${NEGATIVE}_sample${SAMPLE}_hs${HS}_min_count${MIN_COUNT}/"


OUTPUT_ABS_NAME_WORDVEC=${OUTPUT_FOLDER_WORDVEC}${OUTPUT_NAME_WORDVEC}


echo ${OUTPUT_ABS_NAME_WORDVEC}


if [ ! -f ${OUTPUT_ABS_NAME_WORDVEC} ]; then

  echo "running the following command"
  
  # create word vector 
  WORD2VEC_COMMAND="${WORD2VECBIN_PATH} -train ${CORPUS} -output ${OUTPUT_NAME_WORDVEC} -cbow ${CBOW} -min-count ${MIN_COUNT} -size ${SIZE} -window ${WINDOW} -negative ${NEGATIVE} -hs ${HS} -sample ${SAMPLE} -threads 20 -binary 0 -iter ${ITER}"

  echo ${WORD2VEC_COMMAND}

  time ${WORD2VEC_COMMAND}

  mkdir -p ${OUTPUT_FOLDER_WORDVEC}
  
  mv ${OUTPUT_NAME_WORDVEC} ${OUTPUT_FOLDER_WORDVEC}

else
   echo "word2vec: nothing to be done."
fi


WORDLIST_BASENAME_WITHOUT_EXTENSION=$(basename ${WORDLIST_ABS_NAME} .txt)

MATRIX_NAME_WORDVEC="vec_iter${ITER}_size${SIZE}_cbow${CBOW}_window${WINDOW}_negative${NEGATIVE}_sample${SAMPLE}_hs${HS}_${WORDLIST_BASENAME_WITHOUT_EXTENSION}.mat"

LABEL_NAME_WORDVEC="label_iter${ITER}_size${SIZE}_cbow${CBOW}_window${WINDOW}_negative${NEGATIVE}_sample${SAMPLE}_hs${HS}_${WORDLIST_BASENAME_WITHOUT_EXTENSION}.mat"

CLASS_LABEL_NAME_WORDVEC="class_label_iter${ITER}_size${SIZE}_cbow${CBOW}_window${WINDOW}_negative${NEGATIVE}_sample${SAMPLE}_hs${HS}_${WORDLIST_BASENAME_WITHOUT_EXTENSION}.mat"

OUTPUT_FOLDER_WORDVECTOCLUTO=${OUTPUT_FOLDER_WORDVEC}"run_with_"${WORDLIST_BASENAME_WITHOUT_EXTENSION}"/"

MATRIX_ABS_NAME=${OUTPUT_FOLDER_WORDVECTOCLUTO}${MATRIX_NAME_WORDVEC}

LABEL_ABS_NAME=${OUTPUT_FOLDER_WORDVECTOCLUTO}${LABEL_NAME_WORDVEC}

CLASS_LABEL_ABS_NAME=${OUTPUT_FOLDER_WORDVECTOCLUTO}${CLASS_LABEL_NAME_WORDVEC}

if [ ! -f ${MATRIX_ABS_NAME} ]; then

  echo ${OUTPUT_FOLDER_WORDVECTOCLUTO}

  mkdir -p ${OUTPUT_FOLDER_WORDVECTOCLUTO}

  echo "running word2vec2cluto..."
  
  ./word2vectocluto/word2vectocluto -input_vector ${OUTPUT_ABS_NAME_WORDVEC} -input_word_list ${WORDLIST_ABS_NAME} -output_matrix ${MATRIX_ABS_NAME} -output_label ${LABEL_ABS_NAME} -output_class_label ${CLASS_LABEL_ABS_NAME}
  
else
   echo "word2vectocluto: nothing to be done."
fi


FIG_ABS_NAME=${OUTPUT_FOLDER_WORDVECTOCLUTO}${FIG_NAME}

OUTPUT_WITH_STAT_CLUTOPROGRAM_REL_NAME=${OUTPUT_FOLDER_WORDVECTOCLUTO}${OUTPUT_WITH_STAT_CLUTOPROGRAM_NAME}

OUTPUT_WITH_CLASSES_CLUTOPROGRAM_REL_NAME=${OUTPUT_FOLDER_WORDVECTOCLUTO}${OUTPUT_WITH_CLASSES_CLUTOPROGRAM_NAME}

# run cluto
./cluto-2.1.1/Linux/vcluster -clmethod=agglo -sim=cos -plottree=${FIG_ABS_NAME} -plotformat=ps -rlabelfile=${LABEL_ABS_NAME}  -showtree -labeltree ${MATRIX_ABS_NAME} ${NCLUSTER} 2>&1 | tee ${OUTPUT_WITH_STAT_CLUTOPROGRAM_REL_NAME}

./cluto-2.1.1/Linux/vcluster -clmethod=agglo -sim=cos -plottree=${FIG_ABS_NAME} -plotformat=ps -rlabelfile=${LABEL_ABS_NAME} -rclassfile=${CLASS_LABEL_ABS_NAME} -showtree ${MATRIX_ABS_NAME} ${NCLUSTER} 2>&1 | tee ${OUTPUT_WITH_CLASSES_CLUTOPROGRAM_REL_NAME}

# run ps2pdf to convert the ps image into a pdf one for acrobat reader
ps2pdf c ${OUTPUT_FOLDER_WORDVECTOCLUTO}${FIG_NAME_PDF}


# run tsne reduction
PYTHON_ENV="/home/marianna/Devel/env/bin/activate"
source ${PYTHON_ENV}
python ./tsne_reduction/tsne_reduction.py  --title "${TITLE}"  --output_filename ${OUTPUT_FOLDER_WORDVECTOCLUTO}${PLOT_NAME}  --word_embedding_filename ${MATRIX_ABS_NAME}  --label_filename ${LABEL_ABS_NAME}  --class_filename ${CLASS_LABEL_ABS_NAME}  --map_class_to_color_filename ${MAP_CLASS_TO_COLOR_LABEL_ABS_NAME} 





