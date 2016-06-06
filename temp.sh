#!/bin/bash

. ./cmd.sh ## You'll want to change cmd.sh to something that will work on your system.
           ## This relates to the queue.

. ./path.sh ## Source the tools/utils (import the queue.pl)
# Config:
nj=1
gmmdir=exp/tri4b
data_fmllr=data-fmllr-tri4b
stage=0 # resume training with --stage=N
# End of config.
. utils/parse_options.sh || exit 1;
#


# Train the DNN optimizing per-frame cross-entropy.
dir=exp/dnn5b_pretrain-dbn_dnn
ali=${gmmdir}_ali
feature_transform=exp/dnn5b_pretrain-dbn/final.feature_transform
dbn=exp/dnn5b_pretrain-dbn/6.dbn
(tail --pid=$$ -F $dir/log/train_nnet.log 2>/dev/null)& # forward log
# Train
$train_cmd $dir/log/train_nnet.log steps/nnet/train.sh --feature-transform $feature_transform --dbn $dbn --hid-layers 0 --learn-rate 0.008 $data_fmllr/train $data_fmllr/train data/lang $ali $ali $dir || exit 1;
# Decode (reuse HCLG graph)
steps/nnet/decode.sh --nj 1 --cmd "$decode_cmd" --config conf/decode_dnn.config --acwt 0.1 $gmmdir/graph $data_fmllr/test_1 $dir/decode_1 || exit 1;
steps/nnet/decode.sh --nj 1 --cmd "$decode_cmd" --config conf/decode_dnn.config --acwt 0.1 $gmmdir/graph $data_fmllr/test_2 $dir/decode_2 || exit 1;
