# Copyright 2016 Marianna D'Errico, Simone Bna'
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License. 


import numpy as np
from matplotlib import pyplot as plt
import matplotlib.patches as mpatches
from tsne import bh_sne
from tsne import bh_sne
import numpy, pylab,json,re
from numpy import linalg as LA
import random
import argparse

class TSNEReduction(object):


  def __init__(self, word_embedding_filename, label_filename, class_filename, map_class_to_color_filename):
    self.word_embedding = open(word_embedding_filename, 'r')
    self.labels = open(label_filename, 'r').readlines()
    self.classes = open(class_filename, 'r').readlines()
    self.class_list = []
    self.colors = []
    self.classes_to_colors = {}
    self.classfullnames_to_colors = {}

    dims = self.word_embedding.readline()
    dims = dims.split()
    self.nrow = int(dims[0])
    self.ncol = int(dims[1])
    self.w2vec_matrix = numpy.zeros(shape = (self.nrow, self.ncol))
    
    print 'nrow: ' + str(self.nrow)
    print 'ncol: ' + str(self.ncol)

    with open(map_class_to_color_filename, 'r') as f:
      for line in f:
        class_name = line.split()[0]
        color = line.split()[1]
        class_full_name = line.split()[2]
        self.classes_to_colors[class_name] = color
        self.class_list.append(class_full_name)
        self.classfullnames_to_colors[class_full_name] = color
    print self.class_list
    try:
      for v, class_name in enumerate(self.classes):
        color =  self.classes_to_colors[class_name.split()[0]]
        self.colors.insert(v,color)
    except KeyError as e:
      print 'Error: you did not add the ' + e.message + ' word to the class_to_color_map, please add it!'
      exit(1)

  def normalize_word_embedding(self):
    for v, line in enumerate(self.word_embedding):
      nums = line.split()
      vec = np.array(nums,dtype=float)
      vec_l2norm = LA.norm(vec)
      vec_normalized = vec / vec_l2norm
      self.w2vec_matrix[v,] = vec_normalized


  def run_tsne(self):
    self.w2vec_matrix_reduced = bh_sne(self.w2vec_matrix, pca_d=None, d=2, perplexity=10, theta=0.)  #50


  def create_plot_2d_speeches(self, title, output_filename):
    font = {'fontname':'Bitstream Vera Sans', 'fontsize':2.0}
    pylab.subplots_adjust(bottom =0.1)
    legend_entries = []
    for i in self.class_list:
      color = self.classfullnames_to_colors[i]
      legend_entries.append(pylab.scatter(None, None, s = 15, marker = 'o', c = color, cmap = pylab.get_cmap('Spectral')))

    pylab.scatter(self.w2vec_matrix_reduced[:,0], self.w2vec_matrix_reduced[:,1], s = 15, marker = 'o' , c = self.colors, cmap = pylab.get_cmap('Spectral'))
    pylab.title(title)
    for label, x, y in zip(self.labels, self.w2vec_matrix_reduced [:, 0], self.w2vec_matrix_reduced [:, 1]):
      pylab.annotate(label, xy = (x, y), xytext = None, va="bottom", ha="left", **font)
    plt.legend(legend_entries, self.class_list, scatterpoints=1, loc='upper right', ncol=1, fontsize=5)
    pylab.savefig(output_filename, bbox_inches ='tight', dpi = 1000, orientation = 'landscape', papertype = 'a0')
    pylab.close()


if __name__ =='__main__':

  parser = argparse.ArgumentParser(description='TSNE reduction script')
  parser.add_argument('--title', action="store", type=str, dest="title", default="Categorie semantiche")
  parser.add_argument('--word_embedding_filename', action="store", dest="word_embedding_filename", type=str)
  parser.add_argument('--label_filename', action="store", dest="label_filename", type=str)
  parser.add_argument('--class_filename', action="store", dest="class_filename", type=str)
  parser.add_argument('--map_class_to_color_filename', action="store", dest="map_class_to_color_filename", type=str)
  parser.add_argument('--output_filename', action="store", dest="output_filename", type=str, default="plot_with_labels")
  args = parser.parse_args()

  work = TSNEReduction(args.word_embedding_filename, args.label_filename, args.class_filename, args.map_class_to_color_filename)
  work.normalize_word_embedding()
  work.run_tsne()
  work.create_plot_2d_speeches(title=args.title, output_filename=args.output_filename)





