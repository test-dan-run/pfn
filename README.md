# PFN (Partition Filter Network)
This repository contains codes of the official implementation for the paper [A Partition Filter Network for Joint Entity and Relation Extraction](https://aclanthology.org/2021.emnlp-main.17.pdf) EMNLP 2021

## Quick links
* [Model Overview](#Model-Overview)
  * [Framework](#Framework)
  * [Equation Explanation](#Equation-Explanation)
* [Preparation](#Preparation)
  * [Environment Setup](#Environment-setup)
  * [Data Acquisition and Preprocessing](#Data-Acquisition-and-Preprocessing)
  * [Custom Dataset](#Custom-Dataset)
* [Quick Start](#Quick-Start)
  * [Model Training](#Model-Training)
  * [Evaluation on Pre-trained Model](#Evaluation-on-Pre-trained-Model)
  * [Inference on Customized Input](#Inference-on-Customized-Input)
* [Evaluation on CoNLL04](#Evaluation-on-CoNLL04)
* [Pre-trained Models and Training Logs](#Pre-trained-Models-and-Training-Logs)
  * [Download Links](#Download-Links)
  * [Result Display](#Result-Display)
* [Extension on Ablation Study](#Extension-on-Ablation-Study)
* [Robustness Against Input Perturbation](#Robustness-Against-Input-Perturbation)
* [Citation](#Citation)


## Model Overview

### Framework

![](./fig/model.png)
In this work, we present a new framework equipped with a novel recurrent encoder named **partition
filter encoder** designed for multi-task learning.


### Equation Explanation

The explanation for equation 2 and 3 is displayed here.
![](./fig/gate.png)
![](./fig/partition.png)


## Preparation

### Environment Setup
The experiments were performed using one single NVIDIA-RTX3090 GPU. The dependency packages can be installed with the command:
```
pip install -r requirements.txt
```
Other configurations we use are:  
* python == 3.7.10
* cuda == 11.1
* cudnn == 8


### Data Acquisition and Preprocessing
This is the first work that covers all the mainstream English datasets for evaluation, including **NYT**, **WebNLG**, **ADE**, **ACE05**, **ACE04**, **SCIERC**, **CoNLL04**. 

Please follow the instructions of reademe.md in each dataset folder in ./data/ for data acquisition and preprocessing.  

### Custom Dataset
We suggest that you use **PFN-nested** for other datasets, especially Chinese datasets.  
**PFN-nested** is an enhanced version of PFN. It is better in leveraging entity tail information and capable of handling nested triple prediction.

**---Reasons for Not Using the Original Model**

The orignal one will not be able to decode **triples with head-overlap entities**. For example, if **New York** and **New York City** are both entities, and there exists a RE prediction such as (New, cityof, USA), we cannot know what **New** corresponds to.  

Luckily, the impact on evaluation of English dataset is limited, since such triple is either filtered out (for ADE) or rare (one in test set of SciERC, one in ACE04, zero in other datasets).  

**---Usage**

Replace the files (except for readme.md) in the root directory with the files in the PFN-nested folder, then follow the directions in Quick Start. 


**---Performance comparison in SciERC**


| Model          |   NER       | RE        |
| ----------     |   --------- | --------- |
| **PFN**        |   66.8      | 38.4      |
| **PFN-nested** |   67.9      | 38.7      |





## Quick Start


### Model Training
The training command-line is listed below (command for CONLL04 is in [Evaluation on CoNLL04](#Evaluation-on-CoNLL04)):  
```
python main.py \
--data ${NYT/WEBNLG/ADE/ACE2005/ACE2004/SCIERC} \
--do_train \
--do_eval \
--embed_mode ${bert_cased/albert/scibert} \
--batch_size ${20 (for most datasets) /4 (for SCIERC)} \
--lr ${0.00002 (for most datasets) /0.00001 (for SCIERC)} \
--output_file ${the name of your output files, e.g. ace_test} \
--eval_metric ${micro/macro} 
```

After training, you will obtain three files in the ./save/${output_file}/ directory:     
  * **${output_file}.log** records the logging information.  
  * **${output_file}.txt** records loss, NER and RE results of dev set and test set for each epoch.  
  * **${output_file}.pt** is the saved model with best average F1 results of NER and RE in the dev set.  


### Evaluation on Pre-trained Model

The evaluation command-line is listed as follows:

```
python eval.py \
--data ${NYT/WEBNLG/ADE/ACE2005/ACE2004/SCIERC} \
--eval_metric ${micro/macro} \
--model_file ${the path of saved model you want to evaluate. e.g. save/ace_test.pt} \
--embed_mode ${bert_cased/albert/scibert}
```

### Inference on Customized Input

If you want to evaluate the model with customized input, please run the following code:  

```
python inference.py \
--model_file ${the path of your saved model} \
--sent ${sentence you want to evaluate, str type restricted}
```

**model_file** must contain two kinds of keywords:
* The dataset the model trained on - (web, nyt, ade, ace, sci)
* Pretrained embedding the model uses - (albert, bert, scibert)

For example, model_file could be set as "web_bert.pt"  
 
  
**---Example**

```
input:
python inference.py \
--model_file save/sci_test_scibert.pt \
--sent "In this work , we present a new framework equipped with a novel recurrent encoder   
        named partition filter encoder designed for multi-task learning ."

result:
entity_name: framework, entity type: Generic
entity_name: recurrent encoder, entity type: Method
entity_name: partition filter encoder, entity type: Method
entity_name: multi-task learning, entity type: Task
triple: recurrent encoder, Used-for, framework
triple: recurrent encoder, Part-of, framework
triple: recurrent encoder, Used-for, multi-task learning
triple: partition filter encoder, Hyponym-of, recurrent encoder
triple: partition filter encoder, Used-for, multi-task learning



input:  
python inference.py \
--model_file save/ace_test_albert.pt \
--sent "As Williams was struggling to gain production and an audience for his work in the late 1930s ,  
        he worked at a string of menial jobs that included a stint as caretaker on a chicken ranch in   
        Laguna Beach , California . In 1939 , with the help of his agent Audrey Wood , Williams was 
        awarded a $1,000 grant from the Rockefeller Foundation in recognition of his play Battle of 
        Angels . It was produced in Boston in 1940 and was poorly received ."

result:
entity_name: Williams, entity type: PER
entity_name: audience, entity type: PER
entity_name: his, entity type: PER
entity_name: he, entity type: PER
entity_name: caretaker, entity type: PER
entity_name: ranch, entity type: FAC
entity_name: Laguna Beach, entity type: GPE
entity_name: California, entity type: GPE
entity_name: his, entity type: PER
entity_name: agent, entity type: PER
entity_name: Audrey Wood, entity type: PER
entity_name: Williams, entity type: PER
entity_name: Rockefeller Foundation, entity type: ORG
entity_name: his, entity type: PER
entity_name: Boston, entity type: GPE
triple: caretaker, PHYS, ranch
triple: ranch, PART-WHOLE, Laguna Beach
triple: Laguna Beach, PART-WHOLE, California
```


## Evaluation on CoNLL04
We also run the test on the dataset CoNLL04, and our model surpasses previous SoTA table-sequence in micro/macro RE by 1.4%/0.9%.  

but we did not report the results in our paper due to several reasons:  
* Since the experiment setting is very confusing, we are unsure that the baseline results are reported in the same way as we did. The problems are discussed in detail in [Let's Stop Incorrect Comparisons in End-to-end Relation Extraction!](https://arxiv.org/pdf/2009.10684.pdf).
* Hyper-parameter tuning affects the performance considerably in this dataset.
* Page limits



The command for running CoNLL04 is listed below:

```
python main.py \
--data CONLL04 \
--do_train \
--do_eval \
--embed_mode albert \
--batch_size 10 \
--lr 0.00002 \
--output_file ${the name of your output files} \
--eval_metric micro \
--clip 1.0 \
--epoch 200
```


## Pre-trained Models and Training Logs

### Download Links
Due to limited space in google drive, 10-fold model checkpoints of ADE are not available to you.  


| Dataset               |  File Size | Embedding          | Download                                                                                   |
| --------------------- |  --------- | ----------------   | ------------------------------------------------------------------------------------------ |
| **NYT**               |  393MB     | Bert-base-cased    | [Link](https://drive.google.com/file/d/1hyLDruvg6qBhveGWZQEzJ9_LCDPbLpLw/view?usp=sharing) |
| **WebNLG**            |  393MB     | Bert-base-cased    | [Link](https://drive.google.com/file/d/1Tdw6TYgVKlKbnbKAXyOPBgWbEeXnim3Q/view?usp=sharing) |
| **ACE05**             |  815MB     | Albert-xxlarge-v1  | [Link](https://drive.google.com/file/d/17HcLawF23rZEhWl-6QtN9hg8HMvR4Imf/view?usp=sharing) |
| **ACE04**             |  3.98GB    | Albert-xxlarge-v1  | [Link](https://drive.google.com/file/d/1ViTsEvprcouGozdVqZahtgtg1WNzvQci/view?usp=sharing) |
| **SciERC**            |  399MB     | Scibert-uncased    | [Link](https://drive.google.com/file/d/1KsWRstdhrX0IDpnDqFUi6NAlnlmzlekI/view?usp=sharing) |
| **ADE**               |  214KB     | Bert + Albert      | [Link](https://drive.google.com/file/d/1LexnMMNHY50nLdLku6V8_L_0BBLABVOA/view?usp=sharing) |
| **CoNLL04**           |  815MB     | Albert-xxlarge-v1  | [Link](https://drive.google.com/file/d/1vUqNxck8zYqD63tzcH8-d54iHnB0ZO8-/view?usp=sharing) |

### Result Display
| Dataset    |  Embedding         | Evaluation Metric | NER       | RE        | 
| ---------- |  ---------         | ----------------- | --------- | --------- |
| **NYT**    |  Bert-base-cased   |Micro              | 95.8      | 92.4      |
| **WebNLG** |  Bert-base-cased   |Micro              | 98.0      | 93.6      |
| **ACE05**  |  Albert-xxlarge-v1 |Micro              | 89.0      | 66.8      |
| **ACE04**  |  Albert-xxlarge-v1 |Micro              | 89.3      | 62.5      |
| **SciERC** |  Scibert-uncased   |Micro              | 66.8      | 38.4      |
| **CoNLL04**|  Albert-xxlarge-v1 |Micro/Macro        | 89.6/86.4 | 75.0/76.3 |
| **ADE**    |  Bert/Albert       |Macro              | 89.6/91.3 | 80.0/83.2 |



F1 results on ACE04:
| 5-fold     |  0    |  1  | 2   | 3     |  4      | Average |
| ---------- |  ---- |---- |---- |------ | ------- | ------- |
| Albert-NER |  89.7 |89.9 |89.5 |89.7   |  87.6   | 89.3    |
| Albert-RE  |  65.5 |61.4 |63.4 |61.5   |  60.7   | 62.5    |



F1 results on ADE:
| 10-fold     |  0    |  1  | 2   | 3     |  4      | 5  | 6  | 7  | 8  | 9  | Average |
| -------     | ------|-----|-----|------ |---------|----|----|----|----|----| ------- |
| Bert-NER    |  89.6 |92.3 |90.3 |88.9   |  88.8   |90.2|90.1|88.5|88.0|88.9| 89.6    |
| Bert-RE     |  80.5 |85.8 |79.9 |79.4   |  79.3   |80.5|80.0|78.1|76.2|79.8| 80.0    |
| Albert-NER  |  91.4 |92.9 |91.9 |91.5   |  90.7   |91.6|91.9|89.9|90.6|90.7| 91.3    |
| Albert-RE   |  83.9 |86.8 |82.8 |83.2   |  82.2   |82.4|84.5|82.3|81.9|82.2| 83.2    |


## Extension on Ablation Study
As requested, we release ablation NER/RE results of 5 runs in the category of encoding scheme and decoding strategy.

| Model/seed |  0         |  1       | 2        | 3          |  4         | Mean       | Standard Deviation | 
| ---------- |  --------- |--------- |--------- |----------- | ---------- | ---------- |--------------------|
| Original   | 66.8/38.4  |66.9/36.9 |66.4/36.3 |68.0/38.9   | 67.7/37.7  | 67.2/37.6  | 0.67/1.06          |
| Sequential | 68.7/36.9  |68.0/35.9 |68.5/34.8 |67.7/36.9   | 67.0/36.2  | 68.0/36.1  | 0.68/0.87          |
| Parallel   | 67.0/35.1  |67.2/36.6 |67.9/37.4 |68.0/37.9   | 66.9/34.6  | 67.4/36.3  | 0.51/1.43          |
| Selective  | 68.1/37.4  |67.0/35.9 |67.5/38.5 |66.8/35.1   | 67.7/36.7  | 67.4/36.7  | 0.53/1.32          |


## Robustness Against Input Perturbation
![](./fig/robustness.png)

We use robustness test to evaluate our model under adverse circumstances. In this case, we use the domain transformation methods of NER from [Textflint](https://www.textflint.io/textflint).   

The test files can be found in the folder of ./robustness_data/.  Our reported results are evaluated with the linked **ACE2005-albert** model above. 

For each test file, move it to ./data/ACE2005/ and rename it as **test_triples.json**, then run eval.py with the instructions above. 




## Citation
Please cite our paper if it's helpful to you in your research.

```
@inproceedings{yan-etal-2021-partition,
    title = "A Partition Filter Network for Joint Entity and Relation Extraction",
    author = "Yan, Zhiheng  and  Zhang, Chong  and  Fu, Jinlan  and  Zhang, Qi  and  Wei, Zhongyu",
    booktitle = "Proceedings of the 2021 Conference on Empirical Methods in Natural Language Processing",
    month = nov,
    year = "2021",
    address = "Online and Punta Cana, Dominican Republic",
    publisher = "Association for Computational Linguistics",
    url = "https://aclanthology.org/2021.emnlp-main.17",
    pages = "185--197"
}
```




