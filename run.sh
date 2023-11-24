#!/bin/bash

. cmd.sh
. path.sh
set -e
mfccdir=`pwd`/mfcc
vaddir=`pwd`/mfcc
valquiria_trials=data/valquiria_test/trials
train_percent=$1
test_percent=$2
stage=0
num_components=2048 # Larger than this doesn't make much of a difference.


if [ $stage -le 0 ]; then
    perl /home/roghe/kaldi/egs/voxceleb/v1/corpus_data.pl /home/roghe/kaldi/egs/voxceleb/v1/audio /home/roghe/CorpusV /home/roghe/kaldi/egs/voxceleb/v1/data $train_percent $test_percent
fi

echo "Pass stage 0"

if [ $stage -le 1 ]; then
    for name in train test; do
        utils/fix_data_dir.sh data/${name}
        steps/make_mfcc.sh --write-utt2num-frames true \
            --mfcc-config conf/mfcc.conf --nj 8 --cmd "$train_cmd" \
            data/${name} exp/make_mfcc $mfccdir
        utils/fix_data_dir.sh data/${name}
        sid/compute_vad_decision.sh --nj 8 --cmd "$train_cmd" \
            data/${name} exp/make_vad $vaddir
        utils/fix_data_dir.sh data/${name}
    done
fi

echo "Pass stage 1"

if [ $stage -le 2 ]; then
    sid/tran_diag_ubm.sh --cmd "$train_cmd" \
        --nj 8 --num-threads 8 \
        data/train 2048 \
        exp/diag_ubm

    sid/train_full_ubm.sh --cmd "$train_cmd" \
        --nj 8 --remove-low-count-gaussians false \
        data/train \
        exp/diag_ubm exp/full_ubm
fi

echo "Pass stage 2"

if [ $stage -le 3 ]; then
    utils/subset_data_dir.sh \
        --utt-list <(sort -n -k 2 data/train/utt2num_frames | tail -n 100000) \
        data/train /data/train_100k

    sid/train_ivector_extractor.sh --cmd "$train_cmd" \
        --nj 1 --ivector-dim 400 --num-iters 5 \
        exp/full_ubm/final.ubm data/train_100k \
        exp/extractor
fi

echo "Pass stage 3"

if [ $stage -le 4 ]; then
    sid/extract_ivectors.sh --cmd "$train_cmd" --nj 1 \
        exp/extractor data/train \
        exp/ivectors_train

    sid/extract_ivectors.sh --cmd "$trains_cmd" --nj 1 \
        exp/extractor data/test \
        exp/ivectors_test
fi

echo "Pass stage 4"

if [ $stage -le 5 ]; then
    $train_cmd exp/ivectors_train/log/compute_mean.log \
        ivector-mean scp:exp/ivectors_train/ivecto.scp \
        exp/ivectors_train/mean.vec || exit 1;

    lda_dim=200
    $train_cmd exp/ivectors_train/log/lda.log \
        ivector-compute-lda --total-covariance-factor=0.0 --dim=$lda_dim \
        "ark:ivector-subtract-global-mean scp:exp/ivectors_train/ivector.scp ark:- |" \
        ark:data/train/utt2spk exp/ivectors_train/transform.mat || exit 1;

    $train_cmd exp/ivectors_train/log/plda.log \
        ivector-compute-plda ark:data/train/spk2utt \
        "ark:ivector-subtract-global-mean scp:exp/ivectors_train/ivector.scp ark:- |" \
        exp/ivectors_train/plda || exit 1;
fi

echo "Pass stage 5"

if [ $stage -le 6 ]; then
    $train_cmd exp/scores/log/test_scoring.log \
        ivector-plda-scoring --normalize-length=true \
        "ivector-copy-plda --smoothing=0.0 exp/ivectors_train/plda -|" \
        "ark:ivector-subtract-global-mean exp/ivectors_train/mean.vec scp:exp/ivectors_test/ivector.scp ark: -| transform-vec exp/ivectors_train/transform.mat" \
        "ark:ivector-subtract-global-mean exp/ivectors_train/mean.vec scp:exp/ivectors_test/ivector.scp ark: -| transform-vec exp/ivectors_train/transform.mat" \
        "cat '$valquiria_trials' | cut -d\ --fields=1,2 |" exp/scores_test || exit 1;
fi

echo "Pass stage 6"

if [ $stage -le 7 ]; then
    eer ='compute-eer <(local/prepare_for_eer.py $valquiria_trials exp/scores_test) 2> /dev/null'
    mindcf1='sid/compute_min_dcf.py --p-target 0.01 exp/scores_test $valquiria_trials  2> /dev/null'
    mindcf2='sid/compute_min_dcf.py --p-target 0.001 exp/scores_test $valquiria_trials 2> /dev/null'
    echo "ERR: $eer%"
    echo "minDCF(p-target=0.01): $mindcf1"
    echo "minDCF(p-target=0.001): $mindcf2" 
fi
#GMM-2048 CDS eer : 15.39
#GMM-2048 LDA+CDS eer : 8.103
#GMM-2048 PLDA eer : 5.446